local M = {}

local DIR_MODE = 448 -- 0700
local FILE_MODE = 384 -- 0600
local STALE_TTL_MS = 60 * 60 * 1000
local REQUEST_ID_PATTERN =
	"^pi_%d%d%d%d%d%d%d%d%d%d%d%d%d_%d+_[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]$"

local ACK_STATUSES = {
	opened = true,
	committed = true,
	aborted = true,
	error = true,
}

local FINAL_STATUSES = {
	committed = true,
	aborted = true,
	error = true,
}

local state = {
	root = nil,
	requests_dir = nil,
	acks_dir = nil,
	temp_counter = 0,
	request_buffers = {},
	finalized_ids = {},
}

local function trim(value)
	return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function now_epoch_ms()
	local ok, seconds, microseconds = pcall(vim.uv.gettimeofday)
	if ok and type(seconds) == "number" and type(microseconds) == "number" then
		return (seconds * 1000) + math.floor(microseconds / 1000)
	end
	return os.time() * 1000
end

local function join_path(parent, child)
	if parent:sub(-1) == "/" then
		return parent .. child
	end
	return parent .. "/" .. child
end

local function is_valid_request_id(request_id)
	if type(request_id) ~= "string" then
		return false
	end
	return request_id:match(REQUEST_ID_PATTERN) ~= nil
end

local function initialize_paths()
	if type(state.root) == "string" and state.root ~= "" then
		return
	end

	local xdg_state_home = vim.env.XDG_STATE_HOME
	local state_home
	if type(xdg_state_home) == "string" and xdg_state_home ~= "" then
		state_home = xdg_state_home
	else
		local home = vim.env.HOME
		if type(home) == "string" and home ~= "" then
			state_home = home .. "/.local/state"
		else
			state_home = vim.fn.expand("~/.local/state")
		end
	end

	state.root = join_path(state_home, "pi-nvim-rpc")
	state.requests_dir = join_path(state.root, "requests")
	state.acks_dir = join_path(state.root, "acks")
end

local function request_file_path(request_id)
	return join_path(state.requests_dir, request_id .. ".json")
end

local function ack_file_path(request_id)
	return join_path(state.acks_dir, request_id .. ".json")
end

local function ensure_dir(path)
	local stat = vim.uv.fs_stat(path)
	if stat then
		if stat.type ~= "directory" then
			return false
		end
		vim.uv.fs_chmod(path, DIR_MODE)
		return true
	end

	local mkdir_result = vim.fn.mkdir(path, "p", DIR_MODE)
	if mkdir_result == 0 then
		return false
	end

	vim.uv.fs_chmod(path, DIR_MODE)
	return true
end

local function ensure_state_dirs()
	initialize_paths()
	local root_ok = ensure_dir(state.root)
	local requests_ok = ensure_dir(state.requests_dir)
	local acks_ok = ensure_dir(state.acks_dir)
	return root_ok and requests_ok and acks_ok
end

local function read_text_file(path)
	local descriptor, open_err = vim.uv.fs_open(path, "r", 0)
	if not descriptor then
		return nil, open_err or "failed to open file"
	end

	local stat, stat_err = vim.uv.fs_fstat(descriptor)
	if not stat then
		vim.uv.fs_close(descriptor)
		return nil, stat_err or "failed to stat file"
	end

	local content = ""
	if stat.size > 0 then
		local read_content, read_err = vim.uv.fs_read(descriptor, stat.size, 0)
		if read_content == nil then
			vim.uv.fs_close(descriptor)
			return nil, read_err or "failed to read file"
		end
		content = read_content
	end

	vim.uv.fs_close(descriptor)
	return content, nil
end

local function next_temp_path(path)
	state.temp_counter = state.temp_counter + 1
	local dir = vim.fs.dirname(path)
	local name = vim.fs.basename(path)
	return join_path(dir, string.format(".%s.tmp.%d.%d", name, vim.fn.getpid(), state.temp_counter))
end

local function write_text_file_atomic(path, content)
	local parent_dir = vim.fs.dirname(path)
	if type(parent_dir) ~= "string" or parent_dir == "" then
		return false, "invalid parent directory"
	end

	if not ensure_dir(parent_dir) then
		return false, "failed to create parent directory"
	end

	local temp_path = next_temp_path(path)
	local descriptor, open_err = vim.uv.fs_open(temp_path, "w", FILE_MODE)
	if not descriptor then
		return false, open_err or "failed to open temp file"
	end

	local write_result, write_err = vim.uv.fs_write(descriptor, content, 0)
	local close_ok, close_err = vim.uv.fs_close(descriptor)
	if write_result == nil or close_ok == nil then
		vim.uv.fs_unlink(temp_path)
		return false, write_err or close_err or "failed to write temp file"
	end

	vim.uv.fs_chmod(temp_path, FILE_MODE)
	local rename_ok, rename_err = vim.uv.fs_rename(temp_path, path)
	if not rename_ok then
		vim.uv.fs_unlink(temp_path)
		return false, rename_err or "failed to rename temp file"
	end

	vim.uv.fs_chmod(path, FILE_MODE)
	return true, nil
end

local function decode_json_object(content)
	local decode_ok, decoded = pcall(vim.json.decode, content)
	if not decode_ok or type(decoded) ~= "table" then
		return nil, "invalid JSON object"
	end
	return decoded, nil
end

local function validate_request(request_id, payload)
	if type(payload) ~= "table" then
		return nil, "request payload must be a JSON object"
	end

	if tonumber(payload.version) ~= 1 then
		return nil, "request version must be 1"
	end

	if type(payload.id) ~= "string" or payload.id == "" then
		return nil, "missing required field: id"
	end
	if payload.id ~= request_id then
		return nil, "request id mismatch"
	end

	if type(payload.targetPath) ~= "string" or payload.targetPath == "" then
		return nil, "missing required field: targetPath"
	end
	if payload.targetPath:sub(1, 1) ~= "/" then
		return nil, "targetPath must be absolute"
	end

	local created_at_epoch_ms = tonumber(payload.createdAtEpochMs)
	if not created_at_epoch_ms then
		return nil, "missing required field: createdAtEpochMs"
	end

	local client_pid = tonumber(payload.clientPid)
	if not client_pid or client_pid <= 0 then
		return nil, "missing required field: clientPid"
	end

	local cursor_line = nil
	if payload.cursorLine ~= nil then
		cursor_line = tonumber(payload.cursorLine)
		if cursor_line then
			cursor_line = math.floor(cursor_line)
		end
	end

	return {
		version = 1,
		id = payload.id,
		targetPath = payload.targetPath,
		cursorLine = cursor_line,
		createdAtEpochMs = math.floor(created_at_epoch_ms),
		clientPid = math.floor(client_pid),
	}
end

local function load_request(request_id)
	local content, read_err = read_text_file(request_file_path(request_id))
	if not content then
		return nil, "request file error: " .. tostring(read_err)
	end

	local payload, decode_err = decode_json_object(content)
	if not payload then
		return nil, decode_err
	end

	local request, validation_err = validate_request(request_id, payload)
	if not request then
		return nil, validation_err
	end

	return request, nil
end

local function load_ack(request_id)
	local path = ack_file_path(request_id)
	if not vim.uv.fs_stat(path) then
		return nil, nil
	end

	local content, read_err = read_text_file(path)
	if not content then
		return nil, "ack file error: " .. tostring(read_err)
	end

	local payload, decode_err = decode_json_object(content)
	if not payload then
		return nil, decode_err
	end

	if tonumber(payload.version) ~= 1 then
		return nil, "ack version must be 1"
	end
	if payload.id ~= request_id then
		return nil, "ack id mismatch"
	end
	if type(payload.status) ~= "string" or not ACK_STATUSES[payload.status] then
		return nil, "invalid ack status"
	end

	return payload, nil
end

local function is_transition_allowed(previous_status, next_status)
	if previous_status == nil then
		return next_status == "opened" or FINAL_STATUSES[next_status] == true
	end

	if previous_status == "opened" then
		return FINAL_STATUSES[next_status] == true
	end

	return false
end

local function emit_ack(request_id, status, message)
	if not ACK_STATUSES[status] then
		return false, "unsupported ack status: " .. tostring(status)
	end

	if not ensure_state_dirs() then
		return false, "failed to initialize state directory"
	end

	local existing_ack, existing_err = load_ack(request_id)
	if existing_err then
		return false, existing_err
	end

	local previous_status = nil
	if existing_ack then
		previous_status = existing_ack.status
		if previous_status == status then
			if FINAL_STATUSES[status] then
				state.finalized_ids[request_id] = true
			end
			return true, nil
		end
	end

	if not is_transition_allowed(previous_status, status) then
		return false, string.format("invalid ack transition: %s -> %s", tostring(previous_status), status)
	end

	local payload = {
		version = 1,
		id = request_id,
		status = status,
		updatedAtEpochMs = now_epoch_ms(),
	}
	if type(message) == "string" and message ~= "" then
		payload.message = message
	end

	local encode_ok, encoded = pcall(vim.json.encode, payload)
	if not encode_ok then
		return false, "failed to encode ack JSON"
	end

	local write_ok, write_err = write_text_file_atomic(ack_file_path(request_id), encoded .. "\n")
	if not write_ok then
		return false, write_err
	end

	if FINAL_STATUSES[status] then
		state.finalized_ids[request_id] = true
	end

	return true, nil
end

local function emit_error_ack(request_id, message)
	local ack_ok, ack_err = emit_ack(request_id, "error", message)
	if not ack_ok then
		vim.notify("PiEditOpen: failed to write error ack: " .. tostring(ack_err), vim.log.levels.ERROR)
	end
end

local function get_file_mtime_ms(path)
	local stat = vim.uv.fs_stat(path)
	if not stat or type(stat.mtime) ~= "table" then
		return nil
	end

	local seconds = tonumber(stat.mtime.sec)
	if not seconds then
		return nil
	end

	local nanoseconds = tonumber(stat.mtime.nsec) or 0
	return (seconds * 1000) + math.floor(nanoseconds / 1000000)
end

local function is_stale_file(path, cutoff_ms)
	local mtime_ms = get_file_mtime_ms(path)
	if not mtime_ms then
		return false
	end
	return mtime_ms < cutoff_ms
end

local function is_pid_active(pid)
	if type(pid) ~= "number" or pid <= 0 then
		return false
	end

	local call_ok, result, err, err_name = pcall(vim.uv.kill, pid, 0)
	if not call_ok then
		return false
	end
	if result == 0 or result == true then
		return true
	end
	if err == "EPERM" or err_name == "EPERM" then
		return true
	end
	return false
end

local function get_request_client_pid(request_id)
	local content = read_text_file(request_file_path(request_id))
	if not content then
		return nil
	end

	local payload = decode_json_object(content)
	if not payload then
		return nil
	end

	local client_pid = tonumber(payload.clientPid)
	if not client_pid or client_pid <= 0 then
		return nil
	end

	return math.floor(client_pid)
end

local function cleanup_stale_json_dir(dir_path, cutoff_ms, pid_cache)
	local scanner = vim.uv.fs_scandir(dir_path)
	if not scanner then
		return
	end

	while true do
		local entry_name, entry_type = vim.uv.fs_scandir_next(scanner)
		if not entry_name then
			break
		end

		if entry_type == "file" and entry_name:sub(-5) == ".json" then
			local file_path = join_path(dir_path, entry_name)
			if is_stale_file(file_path, cutoff_ms) then
				local request_id = entry_name:sub(1, -6)
				local keep_file = false

				if is_valid_request_id(request_id) then
					local client_pid = get_request_client_pid(request_id)
					if client_pid then
						if pid_cache[client_pid] == nil then
							pid_cache[client_pid] = is_pid_active(client_pid)
						end
						keep_file = pid_cache[client_pid]
					end
				end

				if not keep_file then
					vim.uv.fs_unlink(file_path)
				end
			end
		end
	end
end

local function cleanup_stale_files()
	if not ensure_state_dirs() then
		return
	end

	local cutoff_ms = now_epoch_ms() - STALE_TTL_MS
	local pid_cache = {}
	cleanup_stale_json_dir(state.requests_dir, cutoff_ms, pid_cache)
	cleanup_stale_json_dir(state.acks_dir, cutoff_ms, pid_cache)
end

local function get_buffer_var(bufnr, var_name)
	local ok, value = pcall(vim.api.nvim_buf_get_var, bufnr, var_name)
	if not ok then
		return nil
	end
	return value
end

local function set_buffer_var(bufnr, var_name, value)
	pcall(vim.api.nvim_buf_set_var, bufnr, var_name, value)
end

local function request_context_for_buffer(bufnr)
	local context = state.request_buffers[bufnr]
	if context then
		return context
	end

	local request_id = get_buffer_var(bufnr, "pi_edit_request_id")
	if not is_valid_request_id(request_id) then
		return nil
	end

	context = {
		request_id = request_id,
		written = get_buffer_var(bufnr, "pi_edit_written") == true,
		finalized = get_buffer_var(bufnr, "pi_edit_finalized") == true,
	}
	state.request_buffers[bufnr] = context
	return context
end

local function initialize_request_buffer(bufnr, request_id)
	state.finalized_ids[request_id] = nil
	state.request_buffers[bufnr] = {
		request_id = request_id,
		written = false,
		finalized = false,
	}
	set_buffer_var(bufnr, "pi_edit_request_id", request_id)
	set_buffer_var(bufnr, "pi_edit_written", false)
	set_buffer_var(bufnr, "pi_edit_finalized", false)
end

local function set_buffer_written(bufnr, written)
	local context = request_context_for_buffer(bufnr)
	if not context then
		return
	end

	context.written = written == true
	set_buffer_var(bufnr, "pi_edit_written", context.written)
end

local function set_buffer_finalized(bufnr, finalized)
	local context = request_context_for_buffer(bufnr)
	if not context then
		return
	end

	context.finalized = finalized == true
	set_buffer_var(bufnr, "pi_edit_finalized", context.finalized)
end

local function normalize_cursor_line(cursor_line, bufnr)
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	if line_count <= 0 then
		line_count = 1
	end

	local requested_line = tonumber(cursor_line)
	if not requested_line then
		return 1
	end

	requested_line = math.floor(requested_line)
	if requested_line <= 0 or requested_line > line_count then
		return 1
	end

	return requested_line
end

local function finalize_buffer_once(bufnr, forced_status)
	local context = request_context_for_buffer(bufnr)
	if not context then
		return false, "current buffer is not a PiEdit request buffer"
	end
	if context.finalized then
		return true, nil
	end

	local status = forced_status
	if not status then
		if context.written then
			status = "committed"
		else
			status = "aborted"
		end
	end

	if not FINAL_STATUSES[status] then
		return false, "invalid final status: " .. tostring(status)
	end

	if state.finalized_ids[context.request_id] then
		set_buffer_finalized(bufnr, true)
		if status == "committed" then
			set_buffer_written(bufnr, true)
		end
		return true, nil
	end

	local ack_ok, ack_err = emit_ack(context.request_id, status)
	if not ack_ok then
		return false, ack_err
	end

	set_buffer_finalized(bufnr, true)
	if status == "committed" then
		set_buffer_written(bufnr, true)
	end
	return true, nil
end

local function open_request_by_id(raw_request_id)
	local request_id = trim(raw_request_id)
	if not is_valid_request_id(request_id) then
		vim.notify("PiEditOpen: invalid request id", vim.log.levels.ERROR)
		return
	end

	if not ensure_state_dirs() then
		local message = "failed to initialize RPC state directory"
		emit_error_ack(request_id, message)
		vim.notify("PiEditOpen: " .. message, vim.log.levels.ERROR)
		return
	end

	cleanup_stale_files()

	local request, request_err = load_request(request_id)
	if not request then
		local message = "failed to load request: " .. tostring(request_err)
		emit_error_ack(request_id, message)
		vim.notify("PiEditOpen: " .. message, vim.log.levels.ERROR)
		return
	end

	local open_ok, open_err = pcall(function()
		vim.cmd("tabedit " .. vim.fn.fnameescape(request.targetPath))
	end)
	if not open_ok then
		local message = "failed to open target file: " .. tostring(open_err)
		emit_error_ack(request_id, message)
		vim.notify("PiEditOpen: " .. message, vim.log.levels.ERROR)
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	initialize_request_buffer(bufnr, request_id)

	local cursor_line = normalize_cursor_line(request.cursorLine, bufnr)
	local cursor_ok = pcall(vim.api.nvim_win_set_cursor, 0, { cursor_line, 0 })
	if not cursor_ok then
		vim.notify("PiEditOpen: failed to set cursor position", vim.log.levels.WARN)
	end

	local ack_ok, ack_err = emit_ack(request_id, "opened")
	if not ack_ok then
		vim.notify("PiEditOpen: failed to write opened ack: " .. tostring(ack_err), vim.log.levels.ERROR)
	end
end

local function commit_current_buffer()
	local bufnr = vim.api.nvim_get_current_buf()
	if not request_context_for_buffer(bufnr) then
		vim.notify("PiEditCommit: current buffer is not a PiEdit request buffer", vim.log.levels.ERROR)
		return
	end

	local write_ok, write_err = pcall(vim.cmd, "write!")
	if not write_ok then
		vim.notify("PiEditCommit: failed to write buffer: " .. tostring(write_err), vim.log.levels.ERROR)
		return
	end

	set_buffer_written(bufnr, true)
	local finalize_ok, finalize_err = finalize_buffer_once(bufnr, "committed")
	if not finalize_ok then
		vim.notify("PiEditCommit: " .. tostring(finalize_err), vim.log.levels.ERROR)
		return
	end

	local close_ok, close_err = pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
	if not close_ok then
		vim.notify("PiEditCommit: failed to close buffer: " .. tostring(close_err), vim.log.levels.ERROR)
	end
end

local function abort_current_buffer()
	local bufnr = vim.api.nvim_get_current_buf()
	if not request_context_for_buffer(bufnr) then
		vim.notify("PiEditAbort: current buffer is not a PiEdit request buffer", vim.log.levels.ERROR)
		return
	end

	local finalize_ok, finalize_err = finalize_buffer_once(bufnr, "aborted")
	if not finalize_ok then
		vim.notify("PiEditAbort: " .. tostring(finalize_err), vim.log.levels.ERROR)
		return
	end

	local close_ok, close_err = pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
	if not close_ok then
		vim.notify("PiEditAbort: failed to close buffer: " .. tostring(close_err), vim.log.levels.ERROR)
	end
end

local function on_buf_write_post(args)
	if request_context_for_buffer(args.buf) then
		set_buffer_written(args.buf, true)
	end
end

local function finalize_if_no_windows(bufnr)
	local context = request_context_for_buffer(bufnr)
	if not context or context.finalized then
		return
	end

	local windows = vim.fn.win_findbuf(bufnr)
	if type(windows) == "table" and #windows > 0 then
		return
	end

	local finalize_ok, finalize_err = finalize_buffer_once(bufnr)
	if not finalize_ok then
		vim.notify(
			"PiEdit RPC: failed to finalize hidden buffer " .. context.request_id .. ": " .. tostring(finalize_err),
			vim.log.levels.ERROR
		)
		return
	end

	if vim.api.nvim_buf_is_valid(bufnr) then
		local delete_ok, delete_err = pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
		if not delete_ok then
			vim.notify(
				"PiEdit RPC: failed to wipe finalized hidden buffer "
					.. context.request_id
					.. ": "
					.. tostring(delete_err),
				vim.log.levels.WARN
			)
		end
	end
end

local function on_buf_win_leave(args)
	local bufnr = args.buf
	vim.schedule(function()
		finalize_if_no_windows(bufnr)
	end)
end

local function on_buf_removed(args)
	local context = request_context_for_buffer(args.buf)
	if not context then
		return
	end

	local finalize_ok, finalize_err = finalize_buffer_once(args.buf)
	if not finalize_ok then
		vim.notify(
			"PiEdit RPC: failed to finalize " .. context.request_id .. ": " .. tostring(finalize_err),
			vim.log.levels.ERROR
		)
	end

	state.request_buffers[args.buf] = nil
end

local function replace_command(name, callback, opts)
	pcall(vim.api.nvim_del_user_command, name)
	vim.api.nvim_create_user_command(name, callback, opts)
end

function M.setup()
	if not ensure_state_dirs() then
		vim.notify("PiEdit RPC: failed to initialize state directory", vim.log.levels.WARN)
	end

	local augroup = vim.api.nvim_create_augroup("PiEditRpc", { clear = true })
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = augroup,
		callback = on_buf_write_post,
	})
	vim.api.nvim_create_autocmd("BufWinLeave", {
		group = augroup,
		callback = on_buf_win_leave,
	})
	vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
		group = augroup,
		callback = on_buf_removed,
	})

	replace_command("PiEditOpen", function(command_opts)
		open_request_by_id(command_opts.args)
	end, {
		nargs = 1,
		desc = "Open Pi RPC edit request",
	})

	replace_command("PiEditCommit", function()
		commit_current_buffer()
	end, {
		nargs = 0,
		desc = "Commit current Pi RPC edit request",
	})

	replace_command("PiEditAbort", function()
		abort_current_buffer()
	end, {
		nargs = 0,
		desc = "Abort current Pi RPC edit request",
	})
end

return M
