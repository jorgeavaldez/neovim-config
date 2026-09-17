return {
	{
		"folke/trouble.nvim",
		opts = {
			modes = {
				lsp_references = {
					auto_refresh = false,
				},
			},
		},
		cmd = "Trouble",
		keys = {
			{ "<leader>xx", "<cmd>Trouble<cr>", desc = "Trouble" },
			{ "<leader>xw", "<cmd>Trouble diagnostics<cr>", desc = "Trouble diagnostics" },
			{ "<leader>xl", "<cmd>Trouble loclist<cr>", desc = "Trouble loclist" },
			{ "<leader>xq", "<cmd>Trouble quickfix<cr>", desc = "Trouble quickfix" },
			{ "gR", "<cmd>Trouble lsp_references<cr>", desc = "Trouble references" },
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		config = function()
			local wk = require("which-key")
			wk.setup({})
			wk.add({
				{ "<leader>a", group = "AI/Assistant" },
				{ "<leader>b", group = "Buffers" },
				{ "<leader>bc", group = "Breadcrumbs" },
				{ "<leader>c", group = "Config" },
				{ "<leader>ca", desc = "Code action (LSP)" },
				{ "<leader>ce", desc = "Open config directory" },
				{ "<leader>d", desc = "Open diagnostic float" },
				{ "<leader>m", group = "Debug" },
				{ "<leader>md", desc = "Toggle debugger" },
				{ "<leader>k", desc = "Hover documentation (LSP)" },
				{ "<leader>r", desc = "Rename symbol (LSP)" },
				{ "<leader>f", group = "Files" },
				{ "<leader>G", group = "Github" },
				{ "<leader>ff", desc = "Format buffer" },
				{ "<leader>fc", desc = "Copy file path" },
				{ "<leader>fD", desc = "Delete buffer contents" },
				{ "<leader>fR", desc = "Rename file (LSP)" },
				{ "<leader>j", group = "JJ (jujutsu)" },
				{ "<leader>o", group = "Notes" },
				{ "<leader>p", group = "Project" },
				{ "<leader>pF", desc = "FFF find files near current buffer" },
				{ "<leader>pf", desc = "FFF find files" },
				{ "<leader>pm", desc = "FFF find modified files" },
				{ "<leader>ps", desc = "Workspace symbols" },
				{ "<leader>pv", desc = "Open file explorer (Oil)" },
				{ "<leader>q", group = "Quit" },
				{ "<leader>qq", desc = "Save and quit all" },
				{ "<leader>QQ", desc = "Quit all (force)" },
				{ "<leader>s", group = "Search/Symbols" },
				{ "<leader>sd", desc = "Document symbols" },
				{ "<leader>sf", desc = "FFF fuzzy grep" },
				{ "<leader>sm", desc = "FFF grep modified files" },
				{ "<leader>ss", desc = "FFF live grep near current buffer" },
				{ "<leader>/", desc = "FFF live grep in project" },
				{ "<leader>*", desc = "FFF grep word under cursor" },
				{ "<leader>t", group = "Tabs" },
				{ "<leader>T", group = "Theme" },
				{ "<leader>Tt", desc = "Theme picker" },
				{ "<leader>w", group = "Windows" },
				{ "<leader>wf", group = "Workflow Files" },
				{ "<leader>y", desc = "Yank to clipboard" },
				{ "<leader>Y", desc = "Yank line to clipboard" },
				{ "<leader>$", desc = "Open terminal" },
				{ "<leader>u", desc = "Toggle undo tree" },
				{ "<leader>x", group = "Trouble" },
				{ "<C-p>", desc = "FFF find files" },
				{ "<C-h>", desc = "Signature help (LSP)", mode = "i" },
				{ "gd", desc = "Go to definition" },
				{ "gr", desc = "Go to references" },
				{ "gi", desc = "Go to implementations" },
				{ "gR", desc = "Trouble references" },
			})
		end,
	},
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = true,
	},
	{
		"nvim-mini/mini.cmdline",
		name = "mini.cmdline",
		version = "*",
		event = "CmdlineEnter",
		config = function()
			require("mini.cmdline").setup({})
		end,
	},
	{
		"stevearc/oil.nvim",
		---@module 'oil'
		---@type oil.SetupOpts|fun():oil.SetupOpts
		opts = function()
			local detail = false

			return {
				view_options = {
					show_hidden = true,
					case_insensitive = true,
					sort = {
						{ "mtime", "desc" },
						{ "name", "asc" },
						{ "type", "asc" },
					},
				},
				watch_for_changes = true,
				delete_to_trash = true,
				keymaps = {
					["gd"] = {
						desc = "Toggle file detail view",
						callback = function()
							detail = not detail
							if detail then
								require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
							else
								require("oil").set_columns({ "icon" })
							end
						end,
					},
				},
			}
		end,
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		lazy = false,
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {
			file_types = { "markdown" },
			latex = { enabled = false },
		},
		event = { "BufReadPre *.md", "BufReadPre *.markdown", "BufNewFile *.md", "BufNewFile *.markdown" },
	},
	{
		"Bekaboo/dropbar.nvim",
		event = "VeryLazy",
		-- No dependencies required, works with builtin LSP and treesitter
	},
	{ "folke/zen-mode.nvim", event = "VeryLazy" },
}
