local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	---@diagnostic disable-next-line: assign-type-mismatch
	dev = {
		path = "~/proj",
	},
	spec = {
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
					{ path = "${3rd}/luv/library",     words = { "vim%.uv" } },
					{ path = "~/proj/avante.nvim/lua", words = { "avante" } },
					{ path = "luvit-meta/library",     words = { "vim%.uv" } },
					-- 'oil.nvim',
				},
			},
		},
		{
			'f-person/auto-dark-mode.nvim',
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
				{ "<leader>/", function() require("telescope.builtin").live_grep() end, desc = "Live grep in project" },
				{ "<leader>*", function() require("telescope.builtin").grep_string() end, desc = "Grep word under cursor" },
				{ "<leader>bb", function() require("telescope.builtin").buffers() end, desc = "List buffers" },
				{ "<leader>s", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Show symbols in document" },
				{ "<leader>ps", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, desc = "Workspace symbols" },
				{ "gr", function() require("telescope.builtin").lsp_references() end, desc = "Go to references" },
				{ "gi", function() require("telescope.builtin").lsp_implementations() end, desc = "Go to implementations" },
				{
					"<leader>Tt",
					function()
						require("telescope.builtin").colorscheme({ enable_preview = true })
					end,
					desc = "Theme picker",
				},
				{ "<leader><leader>", function() require("telescope.builtin").commands() end, desc = "Command palette" },
				{ "<leader>?", function() require("telescope.builtin").keymaps() end, desc = "Search keymaps" },
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
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			event = { "BufReadPost", "BufNewFile" },
			dependencies = {
				"nvim-treesitter/nvim-treesitter-textobjects",
				"windwp/nvim-ts-autotag",
			},
			config = function()
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
						"terraform",
						"hcl",
					},
					sync_install = false,
					auto_install = true,
					highlight = {
						enable = true,
						additional_vim_regex_highlighting = false,
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
		{ "nvim-lua/plenary.nvim" },
		{
			"mbbill/undotree",
			keys = {
				{ "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle undo tree" },
			},
		},
		-- JJ (Jujutsu) plugins
		{
			"NicolasGB/jj.nvim",
			version = "*",
			cmd = { "J", "Jdiff" },
			config = function()
				require("jj").setup({})
			end,
		},
		{
			"julienvincent/hunk.nvim",
			cmd = { "DiffEditor" },
			dependencies = { "MunifTanjim/nui.nvim" },
			config = function()
				require("hunk").setup()
			end,
		},
		{
			"evanphx/jjsigns.nvim",
			event = { "BufReadPre", "BufNewFile" },
			config = function()
				require("jjsigns").setup()
			end,
		},
		{
			"zschreur/telescope-jj.nvim",
			lazy = true,
		},
		{
			"hrsh7th/nvim-cmp",
			lazy = true,
			dependencies = {
				{ "hrsh7th/cmp-nvim-lsp", lazy = true },
				{ "L3MON4D3/LuaSnip", lazy = true },
				{ "onsails/lspkind.nvim", lazy = true },
			}
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
		{ "mfussenegger/nvim-dap", lazy = true },
		{
			"mfussenegger/nvim-dap-python",
			lazy = true,
			dependencies = { "mfussenegger/nvim-dap" },
		},
		{
			"rcarriga/nvim-dap-ui",
			lazy = true,
			dependencies = {
				"mfussenegger/nvim-dap",
				"mfussenegger/nvim-dap-python",
				"nvim-neotest/nvim-nio",
			},
			keys = {
				{
					"<leader>md",
					function()
						require("dapui").toggle()
					end,
					desc = "Toggle debugger",
				},
			},
			config = function()
				require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")
				require("dapui").setup()
			end,
		},
		{
			"j-hui/fidget.nvim",
			lazy = true,
		},
		{
			"neovim/nvim-lspconfig",
			event = { "BufReadPre", "BufNewFile" },
			config = function()
				require("jorge.plugins.lsp").setup()
			end,
		},
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
					{ "<leader>ff", desc = "Format buffer" },
					{ "<leader>fc", desc = "Copy file path" },
					{ "<leader>fD", desc = "Delete buffer contents" },
					{ "<leader>fR", desc = "Rename file (LSP)" },
					{ "<leader>j", group = "JJ (jujutsu)" },
					{ "<leader>o", group = "Obsidian" },
					{ "<leader>p", group = "Project" },
					{ "<leader>pf", desc = "Find files (incl. hidden)" },
					{ "<leader>ps", desc = "Workspace symbols" },
					{ "<leader>pv", desc = "Open file explorer (Oil)" },
					{ "<leader>s", desc = "Document symbols" },
					{ "<leader>/", desc = "Live grep in project" },
					{ "<leader>*", desc = "Grep word under cursor" },
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
					{ "<C-p>", desc = "Find files (jj/git)" },
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
			"git@github.com:nvim-mini/mini.cmdline.git",
			name = "mini.cmdline",
			version = "*",
			event = "CmdlineEnter",
			config = function()
				require("mini.cmdline").setup({})
			end,
		},
		{
			"obsidian-nvim/obsidian.nvim",
			version = "*",
			lazy = true,
			-- Event-based loading: Only load plugin when opening markdown files in the vault
			-- Commands (via cmd) still work globally for quick capture from anywhere
			event = {
				"BufReadPre " .. vim.fn.expand("~") .. "/obsidian/delvaze/*.md",
				"BufNewFile " .. vim.fn.expand("~") .. "/obsidian/delvaze/*.md",
			},
			-- Global keymaps: Work anywhere, not just in Obsidian buffers
			-- Useful for referencing or searching notes while browsing code
			keys = {
				{ "<leader>od",   "<cmd>Obsidian today<CR>",        desc = "Open daily note",                          mode = "n" },
				{ "<leader>oN",   ":Obsidian new ",                 desc = "New Obsidian Note with name",              mode = "n" },
				{ "<leader>on",   "<cmd>Obsidian new<CR>",          desc = "New Obsidian note",                        mode = "n" },
				{ "<leader>op",   "<cmd>ObsidianNewPrompt<CR>",     desc = "New Obsidian prompt",                      mode = "n" },
				{ "<leader>o/",   "<cmd>Obsidian search<CR>",       desc = "Search Obsidian notes",                    mode = "n" },
				{ "<leader>of",   "<cmd>Obsidian quick_switch<CR>", desc = "Quick switch notes",                       mode = "n" },
				{ "<leader>ot",   "<cmd>Obsidian template<CR>",     desc = "insert template from templates directory", mode = "n" },
				{ "<leader>ob",   "<cmd>Obsidian backlinks<CR>",    desc = "Show backlinks",                           mode = "n" },
				{ "<leader>oL",   ":Obsidian link ",                desc = "Link to note (with query)",                mode = "n" },
				{ "<leader>oln",  ":Obsidian link_new ",            desc = "Link to new note (with title)",            mode = "n" },
				{ "<leader>olN",  "<cmd>Obsidian link_new<CR>",     desc = "Link to new note",                         mode = "n" },
				{ "<leader>ol",   "<cmd>Obsidian link<CR>",         desc = "Link to note",                             mode = "n" },
				{ "<leader><CR>", "<cmd>Obsidian follow_link<CR>",  desc = "Follow link",                              mode = "n" },
			},
			-- Allow commands to load plugin on-demand for quick capture
			cmd = { "Obsidian", "ObsidianNewPrompt" },
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
			opts = {
				workspaces = {
					{
						name = "personal",
						path = "~/obsidian/delvaze",
					},
				},
				ui = {
					enable = false,
				},
				completion = {
					nvim_cmp = true,
					min_chars = 2,
				},
				daily_notes = {
					folder = "daily",
				},
				templates = {
					folder = "templates",
					date_format = "%Y-%m-%d",
					time_format = "%H:%M",
				},
				-- Use new command format (Obsidian <subcommand>) instead of legacy (ObsidianSubcommand)
				legacy_commands = false,
				footer = {
					enabled = true,
				},
			},
			config = function(_, opts)
				require("obsidian").setup(opts)

				vim.api.nvim_create_user_command("ObsidianNewPrompt", function()
					local obsidian = require("obsidian")
					local vault_path = Obsidian.dir
					local prompts_dir = vault_path / "prompts"

					prompts_dir:mkdir({ parents = true, exist_ok = true })

					vim.ui.input({ prompt = "Prompt note title: " }, function(title)
						if title and title ~= "" then
							local note = obsidian.Note.create({
								title = title,
								id = title,
								dir = tostring(prompts_dir),
							})
							vim.cmd("edit " .. tostring(note.path))
						end
					end)
				end, { desc = "Create new Obsidian prompt note" })

				vim.keymap.set(
					"n",
					"gf",
					function()
						local ok, obsidian = pcall(require, "obsidian")
						if not ok then
							return "gf"
						end
						if obsidian.util.cursor_on_markdown_link() then
							return "<cmd>Obsidian follow_link<CR>"
						else
							return "gf"
						end
					end,
					{ noremap = false, expr = true, desc = "Follow obsidian link or file" }
				)
			end,
		},
		{ "tpope/vim-sleuth" },
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
		{ "windwp/nvim-ts-autotag", lazy = true },
		{
			"Exafunction/windsurf.nvim",
			event = "InsertEnter",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"hrsh7th/nvim-cmp",
			},
			config = function()
				require("codeium").setup({})
			end
		},
		{
			"supermaven-inc/supermaven-nvim",
			enabled = false,
			config = function()
				require("supermaven-nvim").setup({
					keymaps = {
						accept_suggestion = "<C-.>",
						clear_suggestion = "<C-]>",
						-- accept_word = "<C-j>",
					},
					log_level = "info", -- set to "off" to disable logging completely
					disable_inline_completion = true, -- disables inline completion for use with cmp
					disable_keymaps = true, -- disables built in keymaps for more manual control
					condition = function()
						return false
					end, -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
				})
			end,
		},
		{
			"milanglacier/minuet-ai.nvim",
			enabled = false,
			config = function()
				require("minuet").setup({
					provider = "openai_compatible",
					request_timeout = 2.5,
					throttle = 800, -- Increase to reduce costs and avoid rate limits
					debounce = 600, -- Increase to reduce costs and avoid rate limits
					provider_options = {
						openai_compatible = {
							api_key = "AVANTE_OPENROUTER_API_KEY",
							end_point = "https://openrouter.ai/api/v1/chat/completions",
							model = "google/gemini-2.0-flash-001",
							name = "Openrouter",
							optional = {
								-- max_tokens = 128,
								-- top_p = 0.9,
								provider = {
									-- Prioritize throughput for faster completion
									sort = "throughput",
								},
							},
						},
					},
				})
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
							{ "name",  "asc" },
							{ "type",  "asc" },
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
			-- Optional dependencies
			dependencies = { { "echasnovski/mini.icons", opts = {} } },
			-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
			-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
			-- use the `-` key to go up a directory
			lazy = false,
		},
		{
			"olimorris/codecompanion.nvim",
			enabled = false,
			config = function()
				require("codecompanion").setup({
					-- Ensure Anthropic is the default provider for all strategies
					strategies = {
						chat = { adapter = "anthropic" },
						inline = { adapter = "anthropic" },
					},
					extensions = {
						mcphub = {
							enabled = false,
							callback = "mcphub.extensions.codecompanion",
							opts = {
								make_vars = true,
								make_slash_commands = true,
								show_result_in_chat = true,
							},
						},
						history = {
							enabled = true,
							opts = {
								-- Keymap to open history from chat buffer (default: gh)
								keymap = "gh",
								-- Keymap to save the current chat manually (when auto_save is disabled)
								save_chat_keymap = "sc",
								-- Save all chats by default (disable to save only manually using 'sc')
								auto_save = true,
								-- Number of days after which chats are automatically deleted (0 to disable)
								expiration_days = 0,
								-- Picker interface ("telescope" or "snacks" or "fzf-lua" or "default")
								picker = "telescope",
								---Automatically generate titles for new chats
								auto_generate_title = true,
								title_generation_opts = {
									---Adapter for generating titles (defaults to current chat adapter)
									adapter = nil, -- "copilot"
									---Model for generating titles (defaults to current chat model)
									model = nil, -- "gpt-4o"
								},
								---On exiting and entering neovim, loads the last chat on opening chat
								continue_last_chat = false,
								---When chat is cleared with `gx` delete the chat from history
								delete_on_clearing_chat = false,
								---Directory path to save the chats
								dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
								---Enable detailed logging for history extension
								enable_logging = false,
							},
						},
					},
				})
			end,
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-treesitter/nvim-treesitter",
				"ravitemer/mcphub.nvim",
				"ravitemer/codecompanion-history.nvim",
			},
		},
		{
			"yetone/avante.nvim",
			enabled = false,
			event = "VeryLazy",
			version = false,
			dev = false, -- set to true to load from local source
			opts = {
				debug = false, -- set to true for logs
				provider = "gemini",
				web_search_engine = {
					provider = "searxng",
				},
				gemini = {
					model = "gemini-2.5-pro-preview-05-06",
					max_tokens = 1000000,
				},
			},
			build = "make",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"stevearc/dressing.nvim",
				"nvim-lua/plenary.nvim",
				"MunifTanjim/nui.nvim",
				--- The below dependencies are optional,
				"echasnovski/mini.pick", -- for file_selector provider mini.pick
				"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
				"hrsh7th/nvim-cmp",  -- autocompletion for avante commands and mentions
				"ibhagwan/fzf-lua",  -- for file_selector provider fzf
				"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
				{
					-- support for image pasting
					"HakonHarnes/img-clip.nvim",
					event = "VeryLazy",
					opts = {
						-- recommended settings
						default = {
							embed_image_as_base64 = false,
							prompt_for_file_name = false,
							drag_and_drop = {
								insert_mode = true,
							},
							-- required for Windows users
							use_absolute_path = true,
						},
					},
				},
			},
		},
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown" },
			},
			ft = { "markdown" },
		},
		{
			"Bekaboo/dropbar.nvim",
			event = "VeryLazy",
			-- No dependencies required, works with builtin LSP and treesitter
		},
		{
			"stevearc/overseer.nvim",
			cmd = { "OverseerRun", "OverseerToggle", "OverseerOpen", "OverseerQuickAction" },
			opts = {},
		},
		{
			"folke/sidekick.nvim",
			opts = {
				-- I don't use copilot
				nes = {
					enabled = false,
				},
			},
			keys = {
				{
					"<leader>ac",
					function()
						require("sidekick.cli").toggle({ name = "claude", focus = true })
					end,
					desc = "Sidekick toggle claude",
					mode = { "n", "v" },
				},
				{
					"<leader>ai",
					function()
						require("sidekick.cli").toggle({ name = "opencode", focus = true })
					end,
					desc = "Sidekick toggle opencode",
					mode = { "n", "v" },
				},
				{
					"<leader>ao",
					function()
						require("sidekick.cli").toggle({ name = "opencode", focus = true })
					end,
					desc = "Sidekick toggle opencode",
					mode = { "n", "v" },
				},
				{
					"<leader>ag",
					function()
						require("sidekick.cli").toggle({ name = "codex", focus = true })
					end,
					desc = "Sidekick toggle codex",
					mode = { "n", "v" },
				},
				{
					"<leader>ap",
					function()
						require("sidekick.cli").prompt()
					end,
					desc = "Sidekick ask prompt",
					mode = { "n", "v" },
				},
			},
		},
		{
			"https://codeberg.org/ziglang/zig.vim",
		},
	},
})
