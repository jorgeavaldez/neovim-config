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
			dependencies = { "nvim-lua/plenary.nvim" },
		},
		{
			"catppuccin/nvim",
			name = "catppuccin",
			priority = 1000,
			setup = {
				cmp = true,
				gitsigns = true,
				nvimtree = true,
				treesitter = true,
				notify = true,
				diffview = true,
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
		},
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
			},
		},
		{ "nvim-lua/plenary.nvim" },
		{ "mbbill/undotree" },
		{ "tpope/vim-fugitive" },
		{
			"hrsh7th/nvim-cmp",
			dependencies = {
				{ "hrsh7th/cmp-nvim-lsp" },
				{ "L3MON4D3/LuaSnip" },
				{ "L3MON4D3/LuaSnip" },
				{ "onsails/lspkind.nvim" },
			}
		},
		{
			"mason-org/mason.nvim",
		},
		{
			"mason-org/mason-lspconfig.nvim",
			dependencies = { "mason-org/mason.nvim" },
		},
		{
			"nvimtools/none-ls.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
		},
		{
			"nvimdev/lspsaga.nvim",
			config = function()
				require("lspsaga").setup({})
			end,
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"nvim-tree/nvim-web-devicons",
			},
		},
		{ "mfussenegger/nvim-dap" },
		{
			"mfussenegger/nvim-dap-python",
			dependencies = { "mfussenegger/nvim-dap" },
		},
		{
			"rcarriga/nvim-dap-ui",
			dependencies = {
				"mfussenegger/nvim-dap",
				"nvim-neotest/nvim-nio",
			},
		},
		{
			"j-hui/fidget.nvim",
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
		},
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			init = function()
				vim.o.timeout = true
				vim.o.timeoutlen = 300
			end,
		},
		{
			"kylechui/nvim-surround",
			version = "*",
			event = "VeryLazy",
			config = true,
		},
		{
			"sindrets/diffview.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
			opts = {
				diff_binaries = false,
				enhanced_diff_hl = true,
				git_cmd = { "git" },
				use_icons = true,
				show_help_hints = true,
				watch_index = true,
				icons = {
					folder_closed = "",
					folder_open = "",
				},
				signs = {
					fold_closed = "",
					fold_open = "",
					done = "✓",
				},
				view = {
					default = {
						layout = "diff2_horizontal",
						winbar_info = false,
					},
					merge_tool = {
						layout = "diff3_horizontal",
						disable_diagnostics = true,
						winbar_info = true,
					},
					file_history = {
						layout = "diff2_horizontal",
						winbar_info = false,
					},
				},
			},
		},
		{
			"lewis6991/gitsigns.nvim",
			event = { "BufReadPre", "BufNewFile" },
			opts = {
				signs = {
					add = { text = "▎" },
					change = { text = "▎" },
					delete = { text = "" },
					topdelete = { text = "" },
					changedelete = { text = "▎" },
					untracked = { text = "▎" },
				},
				-- Keymaps configured in lua/jorge/git.lua
				on_attach = function(bufnr)
					require("jorge.git").setup_gitsigns_keymaps(bufnr)
				end,
			},
		},
		{
			"gelguy/wilder.nvim",
			config = function()
				local wilder = require("wilder")
				wilder.setup({ modes = { ":", "/", "?" } })

				wilder.set_option("pipeline", {
					wilder.branch(
						wilder.cmdline_pipeline({
							fuzzy = 1,
							fuzzy_filter = wilder.lua_fzy_filter(),
						}),
						wilder.vim_search_pipeline()
					),
				})

				wilder.set_option(
					"renderer",
					wilder.renderer_mux({
						[":"] = wilder.popupmenu_renderer({
							highlighter = wilder.lua_fzy_highlighter(),
						}),
						["/"] = wilder.wildmenu_renderer({
							highlighter = wilder.lua_fzy_highlighter(),
						}),
					})
				)
			end,
			dependencies = {
				"romgrk/fzy-lua-native",
			},
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
			dependencies = {
				"ray-x/guihua.lua",
				"nvim-treesitter/nvim-treesitter",
			},
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
		{ "windwp/nvim-ts-autotag" },
		{
			"supermaven-inc/supermaven-nvim",
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
			---@type oil.SetupOpts
			opts = {
				view_options = {
					show_hidden = true,
				},
			},
			-- Optional dependencies
			dependencies = { { "echasnovski/mini.icons", opts = {} } },
			-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
			-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
			-- use the `-` key to go up a directory
			lazy = false,
		},
		{
			"olimorris/codecompanion.nvim",
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
			"stevearc/overseer.nvim",
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
	},
})
