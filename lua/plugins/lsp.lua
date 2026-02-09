return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		cmd = "LazyDev",
		opts = {
			dependencies = {
				-- Manage libuv types with lazy. Plugin will never be loaded
				{ "Bilal2453/luvit-meta", lazy = true },
			},
			library = {
				-- load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "~/proj/avante.nvim/lua", words = { "avante" } },
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
				-- 'oil.nvim',
			},
		},
	},
	{
		"hrsh7th/nvim-cmp",
		lazy = true,
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp", lazy = true },
			{ "L3MON4D3/LuaSnip", lazy = true },
			{ "onsails/lspkind.nvim", lazy = true },
		},
	},
	{
		"mason-org/mason.nvim",
		lazy = true,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		lazy = true,
		dependencies = { "mason-org/mason.nvim" },
	},
	{
		"nvimtools/none-ls.nvim",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"nvimdev/lspsaga.nvim",
		lazy = true,
		config = function()
			require("lspsaga").setup({
				-- Disable lspsaga's winbar, use dropbar.nvim instead
				symbol_in_winbar = {
					enable = false,
				},
			})
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"j-hui/fidget.nvim",
		lazy = true,
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("jorge.lsp").setup()
		end,
	},
	{
		"ray-x/go.nvim",
		ft = { "go", "gomod", "gowork", "gotmpl" },
		dependencies = {
			"ray-x/guihua.lua",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.general.positionEncodings = { "utf-16", "utf-8" }
			require("go").setup({
				lsp_cfg = {
					capabilities = capabilities,
				},
				lsp_keymaps = false,
			})
		end,
	},
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.general.positionEncodings = { "utf-16", "utf-8" }
			require("typescript-tools").setup({
				capabilities = capabilities,
			})
		end,
	},
}
