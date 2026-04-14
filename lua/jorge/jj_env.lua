--- Shared jj workspace git environment detection.
---
--- In a jj workspace (no .git at workspace root), git commands fail because
--- git can't discover the repo. This module detects that situation and provides
--- GIT_DIR / GIT_WORK_TREE values pointing at the jj backing git store.
---
--- Results are cached after first resolution per path (or cwd).

local M = {}

---@class JjGitEnv
---@field GIT_DIR string
---@field GIT_WORK_TREE string

---@type table<string, JjGitEnv|false>
local cache = {}

local function trim(s)
	return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

---@param cmd string[]
---@param opts? table
---@return { code: integer, stdout: string, stderr: string }
function M.run_system(cmd, opts)
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

---@param path string
---@return boolean
function M.path_exists(path)
	return vim.fn.isdirectory(path) == 1 or vim.fn.filereadable(path) == 1
end

--- Resolve git env vars for a jj workspace rooted at (or containing) `start_dir`.
--- Returns nil when env vars are not needed (colocated repo, non-jj directory).
--- Results are cached per resolved workspace root.
---@param start_dir? string  directory to probe (defaults to cwd)
---@return JjGitEnv|nil
function M.resolve_for_path(start_dir)
	local dir = start_dir or vim.uv.cwd() or vim.fn.getcwd()

	-- Fast path: already resolved for this directory.
	local cached = cache[dir]
	if cached ~= nil then
		return cached or nil -- false → previously resolved as not-needed
	end

	local jj_root = M.run_system({ "jj", "root" }, { cwd = dir })
	if jj_root.code ~= 0 or jj_root.stdout == "" then
		cache[dir] = false
		return nil
	end

	local workspace_root = jj_root.stdout

	-- Check the workspace-root-level cache (start_dir may be a subdirectory).
	local ws_cached = cache[workspace_root]
	if ws_cached ~= nil then
		cache[dir] = ws_cached
		return ws_cached or nil
	end

	-- Colocated repo has .git at workspace root — git works natively.
	if M.path_exists(workspace_root .. "/.git") then
		cache[workspace_root] = false
		cache[dir] = false
		return nil
	end

	local git_root = M.run_system({ "jj", "git", "root" }, { cwd = workspace_root })
	if git_root.code ~= 0 or git_root.stdout == "" then
		cache[workspace_root] = false
		cache[dir] = false
		return nil
	end

	---@type JjGitEnv
	local env = {
		GIT_DIR = git_root.stdout,
		GIT_WORK_TREE = workspace_root,
	}

	cache[workspace_root] = env
	cache[dir] = env
	return env
end

--- Resolve git env vars for the current working directory.
--- Cached after first call.
---@return JjGitEnv|nil
function M.resolve()
	return M.resolve_for_path(nil)
end

--- Set GIT_DIR / GIT_WORK_TREE in vim.env if we're in a jj workspace.
--- No-op in colocated repos or non-jj directories. Idempotent.
function M.ensure()
	local env = M.resolve()
	if env then
		vim.env.GIT_DIR = env.GIT_DIR
		vim.env.GIT_WORK_TREE = env.GIT_WORK_TREE
	end
end

return M
