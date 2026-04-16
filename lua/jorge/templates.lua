--- Lightweight template insertion via Telescope.
--- Reads plain-text template files from a directory and inserts at cursor.

local M = {}

--- @type string
M.dir = vim.fs.normalize("~/.config/nvim/templates")

--- Insert the contents of a template file at the current cursor position.
---@param path string Absolute path to the template file.
local function insert_template(path)
	local lines = {}
	for line in io.lines(path) do
		lines[#lines + 1] = line
	end
	if #lines == 0 then
		return
	end

	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, lines)
end

--- Open Telescope to pick and insert a template.
function M.pick()
	local ok, telescope = pcall(require, "telescope.builtin")
	if not ok then
		vim.notify("Telescope is required for template picker", vim.log.levels.ERROR)
		return
	end

	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	telescope.find_files({
		prompt_title = "Templates",
		cwd = M.dir,
		attach_mappings = function(prompt_bufnr, _)
			actions.select_default:replace(function()
				local entry = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if entry then
					insert_template(entry.path or (M.dir .. "/" .. entry[1]))
				end
			end)
			return true
		end,
	})
end

return M
