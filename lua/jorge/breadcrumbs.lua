local M = {}

local state = {
	tracked_files = {},
	seen_files = {},
	is_tracking = false,
	prefix = "",
}

local excluded_filetypes = { "oil", "fugitive", "help", "qf", "netrw", "telescope", "lazy", "mason" }
local excluded_buftypes = { "terminal", "nofile", "quickfix", "prompt", "help" }

local function get_project_root()
	return require("jorge.commands").get_project_root()
end

local function get_relative_path(bufnr)
	local abs_path = vim.api.nvim_buf_get_name(bufnr)

	if abs_path == "" or abs_path == nil then
		return nil
	end

	if not vim.fn.filereadable(abs_path) == 1 then
		return nil
	end

	local project_root = get_project_root()

	if not abs_path:find(project_root, 1, true) then
		return nil
	end

	local rel_path = abs_path:sub(#project_root + 2)

	return rel_path
end

local function is_trackable_buffer(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end

	local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
	local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
	local name = vim.api.nvim_buf_get_name(bufnr)

	if name == "" or name == nil then
		return false
	end

	for _, ft in ipairs(excluded_filetypes) do
		if filetype == ft then
			return false
		end
	end

	for _, bt in ipairs(excluded_buftypes) do
		if buftype == bt then
			return false
		end
	end

	if name:match("^fugitive://") or name:match("^oil://") or name:match("^term://") then
		return false
	end

	return true
end

local function track_file()
	if not state.is_tracking then
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()

	if not is_trackable_buffer(bufnr) then
		return
	end

	local rel_path = get_relative_path(bufnr)

	if not rel_path then
		return
	end

	if state.seen_files[rel_path] then
		for i, path in ipairs(state.tracked_files) do
			if path == rel_path then
				table.remove(state.tracked_files, i)
				break
			end
		end
	end

	table.insert(state.tracked_files, rel_path)
	state.seen_files[rel_path] = true
end

M.start_tracking = function()
	state.is_tracking = true
	vim.notify("Breadcrumbs tracking started", vim.log.levels.INFO)
end

M.stop_tracking = function()
	state.is_tracking = false
	vim.notify("Breadcrumbs tracking stopped", vim.log.levels.INFO)
end

M.toggle_tracking = function()
	if state.is_tracking then
		M.stop_tracking()
	else
		M.start_tracking()
	end
end

M.clear_tracked = function()
	local count = #state.tracked_files
	state.tracked_files = {}
	state.seen_files = {}
	vim.notify(string.format("Cleared %d breadcrumbs", count), vim.log.levels.INFO)
end

M.delete_file = function(path)
	if state.seen_files[path] then
		for i, p in ipairs(state.tracked_files) do
			if p == path then
				table.remove(state.tracked_files, i)
				break
			end
		end
		state.seen_files[path] = nil
		vim.notify(string.format("Removed: %s", path), vim.log.levels.INFO)
	end
end

M.yank_files = function(paths)
	if #paths == 0 then
		vim.notify("No breadcrumbs to yank", vim.log.levels.WARN)
		return
	end

	local prefixed_paths = {}
	for _, path in ipairs(paths) do
		local prefixed = state.prefix ~= "" and (state.prefix .. path) or path
		table.insert(prefixed_paths, prefixed)
	end

	local text = table.concat(prefixed_paths, "\n")
	vim.fn.setreg("+", text)
	vim.notify(string.format("Yanked %d file(s) to clipboard", #paths), vim.log.levels.INFO)
end

M.yank_all = function()
	M.yank_files(state.tracked_files)
end

M.yank_and_clear = function()
	M.yank_files(state.tracked_files)
	M.clear_tracked()
end

M.get_status = function()
	local status = state.is_tracking and "ON" or "OFF"
	local count = #state.tracked_files
	local prefix_info = state.prefix ~= "" and string.format(" | Prefix: '%s'", state.prefix) or ""
	local msg = string.format("Breadcrumbs: %s | Files: %d%s", status, count, prefix_info)
	vim.notify(msg, vim.log.levels.INFO)
end

M.set_prefix = function(prefix)
	state.prefix = prefix or ""
	local msg = state.prefix ~= "" and string.format("Prefix set to: '%s'", state.prefix) or "Prefix cleared"
	vim.notify(msg, vim.log.levels.INFO)
end

M.clear_prefix = function()
	state.prefix = ""
	vim.notify("Prefix cleared", vim.log.levels.INFO)
end

M.get_prefix = function()
	local msg = state.prefix ~= "" and string.format("Current prefix: '%s'", state.prefix) or "No prefix set"
	vim.notify(msg, vim.log.levels.INFO)
end

M.show_tracked_files = function()
	local has_telescope, _ = pcall(require, "telescope")

	if not has_telescope then
		vim.notify("Telescope not available", vim.log.levels.ERROR)
		return
	end

	if #state.tracked_files == 0 then
		vim.notify("No breadcrumbs", vim.log.levels.WARN)
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local reversed_files = {}
	for i = #state.tracked_files, 1, -1 do
		table.insert(reversed_files, state.tracked_files[i])
	end

	pickers
		.new({}, {
			prompt_title = "Breadcrumbs (newest first)",
			finder = finders.new_table({
				results = reversed_files,
			}),
			sorter = conf.generic_sorter({}),
			previewer = conf.file_previewer({}),
			attach_mappings = function(prompt_bufnr, map)
				local function yank_selected()
					local picker = action_state.get_current_picker(prompt_bufnr)
					local selections = picker:get_multi_selection()

					local paths = {}
					if #selections > 0 then
						for _, entry in ipairs(selections) do
							table.insert(paths, entry[1])
						end
					else
						paths = state.tracked_files
					end

					actions.close(prompt_bufnr)
					M.yank_files(paths)
				end

				local function delete_selected()
					local selection = action_state.get_selected_entry()

					if selection then
						M.delete_file(selection[1])
						local current_picker = action_state.get_current_picker(prompt_bufnr)
						current_picker:refresh(finders.new_table({
							results = (function()
								local reversed = {}
								for i = #state.tracked_files, 1, -1 do
									table.insert(reversed, state.tracked_files[i])
								end
								return reversed
							end)(),
						}))
					end
				end

				actions.select_default:replace(yank_selected)
				map("i", "<esc>", yank_selected)
				map("n", "<esc>", yank_selected)
				map("i", "<C-d>", delete_selected)
				map("n", "<C-d>", delete_selected)

				return true
			end,
		})
		:find()
end

M.setup = function(opts)
	opts = opts or {}
	state.prefix = opts.prefix or ""

	local augroup = vim.api.nvim_create_augroup("Breadcrumbs", { clear = true })
	vim.api.nvim_create_autocmd("BufEnter", {
		group = augroup,
		callback = track_file,
	})

	vim.api.nvim_create_user_command("BCStart", M.start_tracking, {})
	vim.api.nvim_create_user_command("BCStop", M.stop_tracking, {})
	vim.api.nvim_create_user_command("BCToggle", M.toggle_tracking, {})
	vim.api.nvim_create_user_command("BCList", M.show_tracked_files, {})
	vim.api.nvim_create_user_command("BCYank", M.yank_all, {})
	vim.api.nvim_create_user_command("BCYankClear", M.yank_and_clear, {})
	vim.api.nvim_create_user_command("BCClear", M.clear_tracked, {})
	vim.api.nvim_create_user_command("BCStatus", M.get_status, {})
	vim.api.nvim_create_user_command("BCSetPrefix", function(cmd_opts)
		M.set_prefix(cmd_opts.args)
	end, { nargs = 1, desc = "Set prefix for yanked files" })
	vim.api.nvim_create_user_command("BCClearPrefix", M.clear_prefix, {})
	vim.api.nvim_create_user_command("BCGetPrefix", M.get_prefix, {})

	vim.keymap.set("n", "<leader>bcs", M.start_tracking, { desc = "Breadcrumbs: start" })
	vim.keymap.set("n", "<leader>bce", M.stop_tracking, { desc = "Breadcrumbs: stop" })
	vim.keymap.set("n", "<leader>bct", M.toggle_tracking, { desc = "Breadcrumbs: toggle" })
	vim.keymap.set("n", "<leader>bcl", M.show_tracked_files, { desc = "Breadcrumbs: list" })
	vim.keymap.set("n", "<leader>bcy", M.yank_all, { desc = "Breadcrumbs: yank all" })
	vim.keymap.set("n", "<leader>bcY", M.yank_and_clear, { desc = "Breadcrumbs: yank and clear" })
	vim.keymap.set("n", "<leader>bcD", M.clear_tracked, { desc = "Breadcrumbs: clear" })
end

return M
