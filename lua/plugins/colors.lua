return {
	{
		"f-person/auto-dark-mode.nvim",
		priority = 1000,
		lazy = false,
		dependencies = { "catppuccin/nvim" },
		config = {
			update_interval = 1000,
			set_dark_mode = function()
				vim.cmd.colorscheme("catppuccin-mocha")
			end,
			set_light_mode = function()
				vim.cmd.colorscheme("catppuccin-latte")
			end,
		},
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		setup = {
			cmp = true,
			nvimtree = true,
			treesitter = true,
			notify = true,
			fidget = true,
			harpoon = true,
			lsp_saga = true,
			markdown = true,
			mason = true,
			render_markdown = true,
			which_key = true,
		},
	},
}
