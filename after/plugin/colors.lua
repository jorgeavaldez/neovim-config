--[[
local auto_dark_mode = require("auto-dark-mode")

auto_dark_mode.setup({
	update_interval = 3000,
	set_dark_mode = function()
		vim.cmd.colorscheme("catppuccin-mocha")
		require('avante_lib').load()
	end,
	set_light_mode = function()
		vim.cmd.colorscheme("catppuccin-latte")
		require('avante_lib').load()
	end,
})

--]]
vim.cmd.colorscheme("catppuccin-mocha")
