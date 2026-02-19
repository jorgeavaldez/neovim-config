local M = {}

M.split = function(s, sep)
	local fields = {}

	local separator = sep or " "
	local pattern = string.format("([^%s]+)", separator)
	local _ = string.gsub(s, pattern, function(c)
		fields[#fields + 1] = c
	end)

	return fields
end

vim.api.nvim_create_user_command("SortWords", function(_)
	local s_start = vim.fn.getcharpos("'<")
	local s_end = vim.fn.getcharpos("'>")

	local n_lines = math.abs(s_end[2] - s_start[2]) + 1
	if n_lines > 1 then
		vim.print("You can only select one line")
		return
	end

	local line = vim.api.nvim_buf_get_text(0, s_start[2] - 1, s_start[3] - 1, s_end[2] - 1, s_end[3], {})[1]

	local words = M.split(line, ", ")

	table.sort(words, function(a, b)
		return a:upper() < b:upper()
	end)

	local new_value = table.concat(words, ", ")

	vim.api.nvim_buf_set_text(0, s_start[2] - 1, s_start[3] - 1, s_end[2] - 1, s_end[3], { new_value })
end, { range = true })

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

	local code = tonumber(completed["code"]) or 1
	local stdout = trim(completed["stdout"])
	local stderr = trim(completed["stderr"])
	return {
		code = code,
		stdout = stdout,
		stderr = stderr,
	}
end

M.get_project_root = function()
	-- Try to get jj root first
	local jj = run_system({ "jj", "root" })
	if jj.code == 0 and jj.stdout ~= "" then
		return jj.stdout
	end

	-- Fall back to git root
	local git = run_system({ "git", "rev-parse", "--show-toplevel" })
	if git.code == 0 and git.stdout ~= "" then
		return git.stdout
	end

	-- Fall back to current working directory
	return vim.fn.getcwd()
end

local function get_git_root(start_dir)
	local result = run_system({ "git", "rev-parse", "--show-toplevel" }, { cwd = start_dir })
	if result.code ~= 0 or result.stdout == "" then
		return nil
	end

	return result.stdout
end

local function parse_github_remote(remote_url)
	local host, path = remote_url:match("^https?://([^/]+)/(.+)$")
	if not host then
		host, path = remote_url:match("^git@([^:]+):(.+)$")
	end
	if not host then
		host, path = remote_url:match("^ssh://git@([^/]+)/(.+)$")
	end
	if not host then
		host, path = remote_url:match("^git://([^/]+)/(.+)$")
	end

	if host ~= "github.com" or not path then
		return nil
	end

	path = path:gsub("%.git$", ""):gsub("/+$", "")
	return "https://github.com/" .. path
end

M.open_current_file_in_github = function(opts)
	opts = opts or {}

	local file_path = vim.api.nvim_buf_get_name(0)
	if file_path == "" then
		vim.notify("Current buffer is not a file", vim.log.levels.ERROR)
		return
	end

	local file_dir = vim.fn.fnamemodify(file_path, ":p:h")
	local git_root = get_git_root(file_dir)
	if not git_root then
		vim.notify("No git repository detected", vim.log.levels.ERROR)
		return
	end

	local remote = run_system({ "git", "config", "--get", "remote.origin.url" }, { cwd = git_root })
	local remote_url = remote.stdout
	if remote.code ~= 0 or remote_url == "" then
		vim.notify("No git remote 'origin' configured", vim.log.levels.ERROR)
		return
	end

	local github_repo = parse_github_remote(remote_url)
	if not github_repo then
		vim.notify("Remote origin is not a GitHub repository", vim.log.levels.ERROR)
		return
	end

	local git_ref_result = run_system({ "git", "rev-parse", "--abbrev-ref", "HEAD" }, { cwd = git_root })
	local git_ref = git_ref_result.stdout
	if git_ref_result.code ~= 0 or git_ref == "" or git_ref == "HEAD" then
		local sha_result = run_system({ "git", "rev-parse", "HEAD" }, { cwd = git_root })
		git_ref = sha_result.stdout
		if sha_result.code ~= 0 or git_ref == "" then
			vim.notify("Could not determine git ref", vim.log.levels.ERROR)
			return
		end
	end

	local absolute_path = vim.fn.fnamemodify(file_path, ":p")
	local repo_prefix = git_root .. "/"
	if absolute_path:sub(1, #repo_prefix) ~= repo_prefix then
		vim.notify("Current file is outside the repository root", vim.log.levels.ERROR)
		return
	end

	local relative_path = absolute_path:sub(#repo_prefix + 1)
	local line_fragment

	local start_line = opts.start_line
	local end_line = opts.end_line

	if (not start_line or not end_line) and opts.use_visual_range then
		start_line = vim.fn.getpos("'<")[2]
		end_line = vim.fn.getpos("'>")[2]
	end

	if start_line and end_line and start_line > 0 and end_line > 0 then
		if start_line > end_line then
			start_line, end_line = end_line, start_line
		end
		if start_line == end_line then
			line_fragment = string.format("#L%d", start_line)
		else
			line_fragment = string.format("#L%d-L%d", start_line, end_line)
		end
	end

	if not line_fragment then
		local line_number = vim.api.nvim_win_get_cursor(0)[1]
		line_fragment = string.format("#L%d", line_number)
	end

	local url = string.format("%s/blob/%s/%s%s", github_repo, git_ref, relative_path, line_fragment)

	local ok, err = pcall(vim.ui.open, url)
	if not ok then
		vim.notify("Failed to open URL: " .. tostring(err), vim.log.levels.ERROR)
	end
end

vim.api.nvim_create_user_command("OpenCurrentFileInGitHub", function(_)
	M.open_current_file_in_github()
end, { desc = "Open current file on GitHub" })

vim.api.nvim_create_user_command("OpenCurrentSelectionInGitHub", function(_)
	M.open_current_file_in_github({ use_visual_range = true })
end, { desc = "Open current selection on GitHub" })

vim.api.nvim_create_user_command("GetProjectRoot", function(_)
	print(M.get_project_root())
end, {})

vim.api.nvim_create_user_command("StripLogPrefixes", function(_)
	vim.cmd([[%s/\d\{4\}-\d\{2\}-\d\{2\} \d*:\d*:\d*.\d* | .*| //g]])
end, {})

return M
