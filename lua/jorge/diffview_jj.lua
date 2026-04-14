local M = {}

local state = {
	baseline = {
		GIT_DIR = vim.env.GIT_DIR,
		GIT_WORK_TREE = vim.env.GIT_WORK_TREE,
	},
	env_by_tab = {},
	pending = nil,
	suspend_hooks = false,
	is_setup = false,
}

local function trim(s)
	return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function run_system(cmd, opts)
	local options = vim.tbl_extend("force", { text = true }, opts or {})
	local ok, completed = pcall(function()
		local system_obj = vim.system(cmd, options)
		local wait = system_obj["wait"]
		if type(wait) ~= "function" then
			return { code = 1, stdout = "", stderr = "vim.system wait() unavailable" }
		end
		return wait(system_obj)
	end)

	if not ok then
		return {
			code = 1,
			stdout = "",
			stderr = tostring(completed),
		}
	end

	return {
		code = tonumber(completed["code"]) or 1,
		stdout = trim(completed["stdout"]),
		stderr = trim(completed["stderr"]),
	}
end

local function apply_env(env)
	vim.env.GIT_DIR = env and env.GIT_DIR or state.baseline.GIT_DIR
	vim.env.GIT_WORK_TREE = env and env.GIT_WORK_TREE or state.baseline.GIT_WORK_TREE
end

local function get_current_tab_env()
	return state.env_by_tab[vim.api.nvim_get_current_tabpage()]
end

local function sync_current_env()
	if state.suspend_hooks then
		return
	end

	apply_env(get_current_tab_env())
end

local function path_exists(path)
	return vim.fn.isdirectory(path) == 1 or vim.fn.filereadable(path) == 1
end

local function normalize_start_dir(path)
	if path and path ~= "" then
		local absolute = vim.fn.fnamemodify(path, ":p")
		if vim.fn.isdirectory(absolute) == 1 then
			return absolute
		end
		return vim.fn.fnamemodify(absolute, ":h")
	end

	local buf_name = vim.api.nvim_buf_get_name(0)
	if buf_name ~= "" then
		return normalize_start_dir(buf_name)
	end

	return vim.loop.cwd()
end

local function get_cpath(args)
	local ok, arg_parser = pcall(require, "diffview.arg_parser")
	if not ok then
		return nil
	end

	local argo = arg_parser.parse(args or {})
	return argo:get_flag("C", {
		plain = false,
		expect_list = false,
		expect_string = true,
		no_empty = true,
		expand = true,
	})
end

local function resolve_diffview_env(args)
	local start_dir = normalize_start_dir(get_cpath(args))
	if not start_dir or start_dir == "" then
		return nil
	end

	local jj_root = run_system({ "jj", "root" }, { cwd = start_dir })
	if jj_root.code ~= 0 or jj_root.stdout == "" then
		return nil
	end

	local workspace_root = jj_root.stdout
	if path_exists(workspace_root .. "/.git") then
		return nil
	end

	local git_root = run_system({ "jj", "git", "root" }, { cwd = workspace_root })
	if git_root.code ~= 0 or git_root.stdout == "" then
		return nil
	end

	return {
		GIT_DIR = git_root.stdout,
		GIT_WORK_TREE = workspace_root,
	}
end

local function with_diffview_env(args, fn)
	local pending = { env = resolve_diffview_env(args) }

	state.pending = pending
	state.suspend_hooks = true
	apply_env(pending.env)

	local ok, result = pcall(fn)

	state.suspend_hooks = false

	if state.pending == pending then
		state.pending = nil
		sync_current_env()
	end

	if not ok then
		error(result)
	end

	return result
end

function M.hooks()
	return {
		view_opened = function(view)
			local pending = state.pending
			if not pending then
				return
			end

			state.pending = nil
			state.env_by_tab[view.tabpage] = pending.env
		end,
		view_enter = function(view)
			if state.suspend_hooks then
				return
			end

			apply_env(state.env_by_tab[view.tabpage])
		end,
		view_leave = function(_)
			if state.suspend_hooks then
				return
			end

			apply_env(nil)
		end,
		view_closed = function(view)
			state.env_by_tab[view.tabpage] = nil
			sync_current_env()
		end,
	}
end

function M.setup()
	if state.is_setup then
		return
	end

	state.is_setup = true

	local diffview = require("diffview")
	local original_open = diffview.open
	local original_file_history = diffview.file_history

	diffview.open = function(args)
		return with_diffview_env(args, function()
			return original_open(args)
		end)
	end

	diffview.file_history = function(range, args)
		return with_diffview_env(args, function()
			return original_file_history(range, args)
		end)
	end

	local group = vim.api.nvim_create_augroup("JorgeDiffviewJjEnv", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "TabEnter" }, {
		group = group,
		callback = sync_current_env,
	})
end

return M
