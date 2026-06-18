local is_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil

return {
	{
		"f-person/auto-dark-mode.nvim",
		priority = 1000,
		lazy = false,
		enabled = not is_ssh,
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
		lazy = false,
		opts = {
			integrations = {
				cmp = true,
				nvimtree = true,
				treesitter = true,
				notify = true,
				fidget = true,
				harpoon = true,
				markdown = true,
				mason = true,
				render_markdown = true,
				which_key = true,
			},
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)

			if is_ssh then
				vim.cmd.colorscheme("catppuccin-mocha")
			end
		end,
	},
}
