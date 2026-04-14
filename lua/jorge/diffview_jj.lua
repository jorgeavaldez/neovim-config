--- Diffview integration for jj workspaces.
---
--- Manages GIT_DIR / GIT_WORK_TREE env vars per-tab so that diffview
--- can operate inside jj workspaces that lack a .git directory.
--- Uses jorge.jj_env for workspace detection and baseline resolution.

local jj_env = require("jorge.jj_env")

local M = {}

local state = {
	env_by_tab = {},
	pending = nil,
	suspend_hooks = false,
	is_setup = false,
}

--- Baseline env: the workspace-level env (or nil when not in a jj workspace).
--- Dynamic so it stays correct regardless of plugin load order.
---@return JjGitEnv|nil
local function get_baseline()
	return jj_env.resolve()
end

local function apply_env(env)
	local baseline = get_baseline()
	vim.env.GIT_DIR = env and env.GIT_DIR or (baseline and baseline.GIT_DIR or nil)
	vim.env.GIT_WORK_TREE = env and env.GIT_WORK_TREE or (baseline and baseline.GIT_WORK_TREE or nil)
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

	return vim.uv.cwd()
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

--- Resolve env for a diffview command, supporting the -C flag.
---@param args? table
---@return JjGitEnv|nil
local function resolve_diffview_env(args)
	local start_dir = normalize_start_dir(get_cpath(args))
	if not start_dir or start_dir == "" then
		return nil
	end

	return jj_env.resolve_for_path(start_dir)
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
