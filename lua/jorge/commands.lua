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

M.get_project_root = function()
	-- Try to get jj root first
	local jj_root = vim.fn.system("jj root 2>/dev/null"):gsub("\n$", "")
	if jj_root ~= "" and vim.v.shell_error == 0 then
		return jj_root
	end

	-- Fall back to git root
	local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n$", "")
	if git_root ~= "" and vim.v.shell_error == 0 then
		return git_root
	end

	-- Fall back to current working directory
	return vim.fn.getcwd()
end

vim.api.nvim_create_user_command("GetProjectRoot", function (_)
	print(M.get_project_root())
end, {})

vim.api.nvim_create_user_command("StripLogPrefixes", function(_)
	vim.cmd([[%s/\d\{4\}-\d\{2\}-\d\{2\} \d*:\d*:\d*.\d* | .*| //g]])
end, {})

return M
