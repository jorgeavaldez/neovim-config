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
