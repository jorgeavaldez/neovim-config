local function current_buffer_dir_or_cwd()
	local buf_path = vim.api.nvim_buf_get_name(0)
	if buf_path == "" then
		return vim.fn.getcwd()
	end

	local dir = vim.fs.dirname(buf_path)
	if dir == nil or dir == "" then
		return vim.fn.getcwd()
	end

	return dir
end

return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		cmd = "Telescope",
		keys = {
			{
				"<leader>pf",
				function()
					require("telescope.builtin").find_files({
						find_command = {
							"rg",
							"--files",
							"--hidden",
							"--no-require-git",
							"-g",
							"!.git",
							"-g",
							"!.jj",
						},
					})
				end,
				desc = "Find files (incl. hidden)",
			},
			{
				"<leader>pF",
				function()
					require("telescope.builtin").find_files({
						cwd = current_buffer_dir_or_cwd(),
						find_command = {
							"rg",
							"--files",
							"--hidden",
							"--no-require-git",
							"-g",
							"!.git",
							"-g",
							"!.jj",
						},
					})
				end,
				desc = "Find files near current buffer",
			},
			{
				"<C-p>",
				function()
					local ok = pcall(function()
						require("telescope").extensions.jj.files()
					end)
					if not ok then
						require("telescope.builtin").git_files()
					end
				end,
				desc = "Find files (jj/git)",
			},
			{
				"<leader>/",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Live grep in project",
			},
			{
				"<leader>ss",
				function()
					require("telescope.builtin").live_grep({ cwd = current_buffer_dir_or_cwd() })
				end,
				desc = "Live grep near current buffer",
			},
			{
				"<leader>*",
				function()
					require("telescope.builtin").grep_string()
				end,
				desc = "Grep word under cursor",
			},
			{
				"<leader>bb",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "List buffers",
			},
			{
				"<leader>sd",
				function()
					require("telescope.builtin").lsp_document_symbols()
				end,
				desc = "Show symbols in document",
			},
			{
				"<leader>ps",
				function()
					require("telescope.builtin").lsp_dynamic_workspace_symbols()
				end,
				desc = "Workspace symbols",
			},
			{
				"gr",
				function()
					require("telescope.builtin").lsp_references()
				end,
				desc = "Go to references",
			},
			{
				"gi",
				function()
					require("telescope.builtin").lsp_implementations()
				end,
				desc = "Go to implementations",
			},
			{
				"<leader>Tt",
				function()
					require("telescope.builtin").colorscheme({ enable_preview = true })
				end,
				desc = "Theme picker",
			},
			{
				"<leader><leader>",
				function()
					require("telescope.builtin").commands()
				end,
				desc = "Command palette",
			},
			{
				"<leader>?",
				function()
					require("telescope.builtin").keymaps()
				end,
				desc = "Search keymaps",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"zschreur/telescope-jj.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local telescope_actions = require("telescope.actions")
			local ok_trouble, trouble = pcall(require, "trouble.sources.telescope")

			local mappings = {
				i = {},
				n = {
					["J"] = telescope_actions.results_scrolling_down,
					["K"] = telescope_actions.results_scrolling_up,
					["gg"] = telescope_actions.move_to_top,
					["G"] = telescope_actions.move_to_bottom,
				},
			}
			if ok_trouble then
				mappings.i["<c-t>"] = trouble.open
				mappings.n["<c-t>"] = trouble.open
			end

			telescope.setup({
				defaults = {
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--no-require-git",
					},
					results_title = false,
					selection_caret = "▶ ",
					entry_prefix = "  ",
					mappings = mappings,
				},
				pickers = {
					buffers = {
						mappings = {
							i = {
								["<c-d>"] = telescope_actions.delete_buffer + telescope_actions.move_to_top,
							},
						},
					},
				},
			})

			pcall(telescope.load_extension, "jj")
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"windwp/nvim-ts-autotag",
		},
		config = function()
			---@type table<string, table>
			local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			parser_config.org = {
				install_info = {
					url = "https://github.com/milisims/tree-sitter-org",
					revision = "main",
					files = { "src/parser.c", "src/scanner.c" },
				},
				filetype = "org",
			}
			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"javascript",
					"typescript",
					"lua",
					"vim",
					"vimdoc",
					"rust",
					"markdown",
					"markdown_inline",
					"org",
					"terraform",
					"hcl",
				},
				sync_install = false,
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = { "org" },
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
							["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
						},
						selection_modes = {
							["@parameter.outer"] = "v",
							["@function.outer"] = "V",
							["@class.outer"] = "<c-v>",
						},
						include_surrounding_whitespace = true,
					},
					swap = {
						enable = true,
						swap_next = {
							["<leader>J"] = "@parameter.inner",
						},
						swap_previous = {
							["<leader>K"] = "@parameter.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["]f"] = { query = "@function.outer", desc = "Next function" },
							["]c"] = { query = "@class.outer", desc = "Next class" },
							["]l"] = { query = "@loop.*", desc = "Next loop" },
							["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
							["]z"] = { query = "@fold", query_group = "folds", desc = "Next folds" },
						},
						goto_next_end = {
							["]F"] = { query = "@function.outer", desc = "Next function" },
							["]C"] = { query = "@class.outer", desc = "Next class" },
						},
						goto_previous_start = {
							["[f"] = { query = "@function.outer", desc = "Previous function" },
							["[c"] = { query = "@class.outer", desc = "Previous class" },
							["[s"] = { query = "@scope", query_group = "locals", desc = "Prevoius scope" },
						},
						goto_previous_end = {
							["[F"] = { query = "@function.outer", desc = "Previous function" },
							["[C"] = { query = "@class.outer", desc = "Previous class" },
						},
						goto_next = {
							["]i"] = { query = "@conditional.outer", desc = "Next conditional" },
						},
						goto_previous = {
							["[i"] = { query = "@conditional.outer", desc = "Previous conditional" },
						},
					},
					lsp_interop = {
						enable = true,
						border = "none",
						floating_preview_opts = {},
						peek_definition_code = {
							["<leader>df"] = "@function.outer",
							["<leader>dc"] = "@class.outer",
						},
					},
				},
			})

			require("nvim-ts-autotag").setup({
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = false,
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		lazy = true,
	},
	{
		"windwp/nvim-ts-autotag",
		lazy = true,
	},
}
