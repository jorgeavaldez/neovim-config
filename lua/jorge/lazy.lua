local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local commands = require("jorge.commands")

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
			config = function()
				vim.cmd.colorscheme("catppuccin-latte")
				-- vim.cmd.colorscheme("catppuccin-mocha")
			end,
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
		"mbbill/undotree",
		"tpope/vim-fugitive",

		{
			"hrsh7th/nvim-cmp",
			dependencies = {
				{ "hrsh7th/cmp-nvim-lsp" }, -- Required
				{ "L3MON4D3/LuaSnip" }, -- Required
				{ "L3MON4D3/LuaSnip" }, -- Required
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
				"nvim-treesitter/nvim-treesitter", -- optional
				"nvim-tree/nvim-web-devicons", -- optional
			},
		},
		"mfussenegger/nvim-dap",
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
			{ "<leader>oN", ":Obsidian new ", desc = "New Obsidian Note with name", mode = "n" },
			{ "<leader>on", "<cmd>Obsidian new<CR>", desc = "New Obsidian note", mode = "n" },
			{ "<leader>op", "<cmd>ObsidianNewPrompt<CR>", desc = "New Obsidian prompt", mode = "n" },
			{ "<leader>o/", "<cmd>Obsidian search<CR>", desc = "Search Obsidian notes", mode = "n" },
			{ "<leader>of", "<cmd>Obsidian quick_switch<CR>", desc = "Quick switch notes", mode = "n" },
			{ "<leader>ob", "<cmd>Obsidian backlinks<CR>", desc = "Show backlinks", mode = "n" },
			{ "<leader>oL", ":Obsidian link ", desc = "Link to note (with query)", mode = "n" },
			{ "<leader>oln", ":Obsidian link_new ", desc = "Link to new note (with title)", mode = "n" },
			{ "<leader>olN", "<cmd>Obsidian link_new<CR>", desc = "Link to new note", mode = "n" },
			{ "<leader>ol", "<cmd>Obsidian link<CR>", desc = "Link to note", mode = "n" },
			{ "<leader><CR>", "<cmd>Obsidian follow_link<CR>", desc = "Follow link", mode = "n" },
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
				local client = require("obsidian").get_client()
				local vault_path = client.dir
				local prompts_dir = vault_path / "prompts"

				prompts_dir:mkdir({ parents = true, exist_ok = true })

				vim.ui.input({ prompt = "Prompt note title: " }, function(title)
					if title and title ~= "" then
						local note = client:create_note({ title = title, dir = prompts_dir })
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
		"tpope/vim-sleuth",
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
		--[[
	{
		"OXY2DEV/markview.nvim",
		lazy = false,
	},
	--]]
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
			-- commit = "e295fe82f0714188615a524604bdaccd266ced35",
			version = false,
			dev = false, -- set to true to load from local source
			---@module 'avante'
			---@type avante.Config
			opts = {
				debug = false, -- set to true for logs
				-- provider = "openrouter",
				provider = "gemini",
				web_search_engine = {
					provider = "searxng",
				},
				gemini = {
					model = "gemini-2.5-pro-preview-05-06",
					max_tokens = 1000000,
				},
				vendors = {
					openrouter = {
						__inherited_from = "openai",
						endpoint = "https://openrouter.ai/api/v1",
						api_key_name = "AVANTE_OPENROUTER_API_KEY",
						model = "anthropic/claude-3.7-sonnet",
						-- model = "google/gemini-2.5-pro-preview-03-25",
						-- model = "google/gemini-2.5-pro-exp-03-25:free",
					},
				},
				--[[
				system_prompt = function()
					local hub = require("mcphub").get_hub_instance()
					if hub ~= nil then
						return hub:get_active_servers_prompt()
					end
				end,
				custom_tools = function()
					return {
						require("mcphub.extensions.avante").mcp_tool(),
					}
				end,
				-- disabled because we can use the mcp hub neovim server
				disabled_tools = {
					"list_files",
					"search_files",
					"read_file",
					"create_file",
					"rename_file",
					"delete_file",
					"create_dir",
					"rename_dir",
					"delete_dir",
					"bash",
				},
				--]]
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
				-- "zbirenbaum/copilot.lua", -- for providers='copilot'
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
			"ravitemer/mcphub.nvim",
			enabled = false,
			dependencies = {
				"nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
			},
			-- comment the following line to ensure hub will be ready at the earliest
			cmd = "MCPHub",                                                  -- lazy load by default
			build = "mise install npm:mcp-hub@latest && mise use npm:mcp-hub@latest", -- Installs required mcp-hub npm module
			-- uncomment this if you don't want mcp-hub to be available globally or can't use -g
			-- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
			config = function()
				vim.fn.setenv("MCP_PROJECT_ROOT_PATH", commands.get_project_root())
				require("mcphub").setup({
					config = vim.fn.expand("~/dots/mcphub/servers.json"),
					extensions = {
						avante = {
							make_slash_commands = true,
						},
						codecompanion = {
							callback = "mcphub.extensions.codecompanion",
							opts = {
								make_vars = true,
								make_slash_commands = true,
								show_result_in_chat = true,
							},
						},
					},
				})
			end,
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
						require("sidekick.cli").select_prompt()
					end,
					desc = "Sidekick ask prompt",
					mode = { "n", "v" },
				},
			},
		},
	},
})
