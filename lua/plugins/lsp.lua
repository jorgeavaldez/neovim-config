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
		"stevearc/conform.nvim",
		cmd = "ConformInfo",
		opts = {
			default_format_opts = {
				lsp_format = "fallback",
				timeout_ms = 1000,
				async = false,
				quiet = false,
			},
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "biome" },
				javascriptreact = { "biome" },
				typescript = { "biome" },
				typescriptreact = { "biome" },
				json = { "biome" },
				jsonc = { "biome" },
				markdown = { "prettier" },
				yaml = { "yamlfmt" },
				sql = { "sqlfmt" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },
				django = { "djlint" },
				["jinja.html"] = { "djlint" },
				htmldjango = { "djlint" },
			},
		},
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				yaml = { "yamllint" },
				sh = { "shellcheck" },
				bash = { "shellcheck" },
				zsh = { "shellcheck" },
				django = { "djlint" },
				htmldjango = { "djlint" },
				["jinja.html"] = { "djlint" },
			}

			local js_filetypes = {
				javascript = true,
				javascriptreact = true,
				typescript = true,
				typescriptreact = true,
			}

			local biome_markers = {
				"biome.json",
				"biome.jsonc",
			}

			local eslint_markers = {
				"eslint.config.js",
				"eslint.config.mjs",
				"eslint.config.cjs",
				"eslint.config.ts",
				"eslint.config.mts",
				"eslint.config.cts",
				".eslintrc",
				".eslintrc.js",
				".eslintrc.cjs",
				".eslintrc.yaml",
				".eslintrc.yml",
				".eslintrc.json",
			}

			local project_markers = {
				"package.json",
				".git",
			}

			local function find_up(markers, start_path)
				return vim.fs.find(markers, { path = start_path, upward = true })[1]
			end

			local function get_buf_dir(bufnr)
				local filename = vim.api.nvim_buf_get_name(bufnr)
				if filename == "" then
					return vim.fn.getcwd()
				end

				return vim.fs.dirname(filename)
			end

			local function resolve_bin(root, binary)
				local local_bin = root and (root .. "/node_modules/.bin/" .. binary) or nil
				if local_bin and vim.uv.fs_stat(local_bin) then
					return local_bin, "local"
				end

				if vim.fn.executable(binary) == 1 then
					local global_bin = vim.fn.exepath(binary)
					return global_bin ~= "" and global_bin or binary, "global"
				end

				return nil, nil
			end

			local function select_linters(bufnr)
				local filetype = vim.bo[bufnr].filetype
				local dir = get_buf_dir(bufnr)
				local names = nil
				local cwd = dir
				local reason = "filetype linters"

				if js_filetypes[filetype] then
					local biome_config = find_up(biome_markers, dir)
					local eslint_config = find_up(eslint_markers, dir)

					if biome_config then
						cwd = vim.fs.dirname(biome_config)
						local biome_clients = vim.lsp.get_clients({ bufnr = bufnr, name = "biome" })
						if #biome_clients > 0 then
							names = {}
							reason =
								"biome config found and biome LSP attached; skip biomejs to avoid duplicate diagnostics"
						else
							names = { "biomejs" }
							reason = "biome config found but biome LSP not attached: " .. biome_config
						end
					elseif eslint_config then
						local eslint_root = vim.fs.dirname(eslint_config)
						local eslint_d_bin, eslint_d_scope = resolve_bin(eslint_root, "eslint_d")
						if eslint_d_bin then
							names = { "eslint_d" }
							reason = "eslint config found (" .. eslint_d_scope .. " eslint_d): " .. eslint_config
						else
							local eslint_bin, eslint_scope = resolve_bin(eslint_root, "eslint")
							if eslint_bin then
								names = { "eslint" }
								reason = "eslint config found (" .. eslint_scope .. " eslint): " .. eslint_config
							else
								names = { "biomejs" }
								reason = "eslint config found but no eslint binary; fallback to biomejs"
							end
						end
						cwd = eslint_root
					else
						names = { "biomejs" }
						local project_root = find_up(project_markers, dir)
						cwd = project_root and vim.fs.dirname(project_root) or dir
						reason = "no biome/eslint config found; fallback to biomejs"
					end
				end

				if names == nil then
					names = lint._resolve_linter_by_ft(filetype)
				end
				names = names or {}

				return {
					names = names,
					cwd = cwd,
					reason = reason,
					filetype = filetype,
					dir = dir,
				}
			end

			local function lint_buffer(bufnr)
				if not vim.api.nvim_buf_is_valid(bufnr) then
					return
				end

				if not vim.bo[bufnr].modifiable or vim.bo[bufnr].buftype ~= "" then
					return
				end

				local selected = select_linters(bufnr)
				if #selected.names == 0 then
					return
				end

				vim.api.nvim_buf_call(bufnr, function()
					lint.try_lint(selected.names, { cwd = selected.cwd })
				end)
			end

			pcall(vim.api.nvim_del_user_command, "LintInfo")
			vim.api.nvim_create_user_command("LintInfo", function(opts)
				local bufnr = opts.args ~= "" and tonumber(opts.args) or vim.api.nvim_get_current_buf()
				if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
					vim.notify("LintInfo: invalid buffer", vim.log.levels.ERROR)
					return
				end

				local selected = select_linters(bufnr)
				local filename = vim.api.nvim_buf_get_name(bufnr)
				local lines = {
					"Buffer: " .. bufnr,
					"File: " .. (filename ~= "" and filename or "[No Name]"),
					"Filetype: " .. selected.filetype,
					"CWD: " .. selected.cwd,
					"Reason: " .. selected.reason,
					"Linters: " .. (#selected.names > 0 and table.concat(selected.names, ", ") or "<none>"),
				}

				if #selected.names == 1 and selected.names[1] == "biomejs" then
					local bin, scope = resolve_bin(selected.cwd, "biome")
					table.insert(lines, "Biome binary: " .. (bin and (scope .. " -> " .. bin) or "not found"))
				elseif #selected.names == 1 and selected.names[1] == "eslint_d" then
					local bin, scope = resolve_bin(selected.cwd, "eslint_d")
					table.insert(lines, "ESLint_d binary: " .. (bin and (scope .. " -> " .. bin) or "not found"))
				elseif #selected.names == 1 and selected.names[1] == "eslint" then
					local bin, scope = resolve_bin(selected.cwd, "eslint")
					table.insert(lines, "ESLint binary: " .. (bin and (scope .. " -> " .. bin) or "not found"))
				end

				vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "LintInfo" })
			end, { nargs = "?" })

			vim.api.nvim_create_autocmd({ "BufReadPost", "InsertLeave", "BufWritePost" }, {
				group = vim.api.nvim_create_augroup("jorge_nvim_lint", { clear = true }),
				callback = function(args)
					lint_buffer(args.buf)
				end,
			})
		end,
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
