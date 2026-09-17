local is_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
local is_termux = vim.env.TERMUX_VERSION ~= nil

return {
	{
		"f-person/auto-dark-mode.nvim",
		priority = 1000,
		lazy = false,
		enabled = not is_ssh and not is_termux,
		dependencies = { "catppuccin/nvim" },
		config = {
			update_interval = 1000,
			set_dark_mode = function()
				if vim.g.colors_name ~= "catppuccin-mocha" then
					vim.cmd.colorscheme("catppuccin-mocha")
				end
			end,
			set_light_mode = function()
				if vim.g.colors_name ~= "catppuccin-latte" then
					vim.cmd.colorscheme("catppuccin-latte")
				end
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

			-- WezTerm already detected the appearance before starting this process.
			local appearance = vim.env.WEZTERM_APPEARANCE
			if is_ssh or is_termux or appearance == "dark" then
				vim.cmd.colorscheme("catppuccin-mocha")
			elseif appearance == "light" then
				vim.cmd.colorscheme("catppuccin-latte")
			end
		end,
	},
}
