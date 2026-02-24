local M = {}

function M.setup()
	if vim.g.jorge_lsp_setup_done then
		return
	end
	vim.g.jorge_lsp_setup_done = true

	vim.diagnostic.config({ jump = { float = true } })

	local function rename_file()
		-- https://github.com/neovim/neovim/issues/20784#issuecomment-1288085253
		local source_file = vim.api.nvim_buf_get_name(0)
		if source_file == "" then
			vim.notify("Current buffer is not a file", vim.log.levels.ERROR)
			return
		end

		vim.ui.input({
			prompt = "Target : ",
			completion = "file",
			default = source_file,
		}, function(input)
			local target_file = vim.trim(input or "")
			if target_file == "" or target_file == source_file then
				return
			end

			local params = {
				oldUri = vim.uri_from_fname(source_file),
				newUri = vim.uri_from_fname(target_file),
			}

			vim.lsp.buf_request(0, "workspace/willRenameFiles", {
				files = { params },
			}, function(err, result, ctx)
				if err then
					vim.notify("Error renaming file: " .. err.message, vim.log.levels.ERROR)
					return
				end
				if result then
					local client = ctx and vim.lsp.get_client_by_id(ctx.client_id) or nil
					local offset_encoding = client and client.offset_encoding or "utf-16"
					vim.lsp.util.apply_workspace_edit(result, offset_encoding)
				end
			end)
		end)
	end

	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local opts = { buffer = args.buf, remap = false }

			vim.keymap.set("n", "<leader>k", function()
				vim.lsp.buf.hover()
			end, opts)

			vim.keymap.set("n", "<leader>d", function()
				vim.diagnostic.open_float()
			end, opts)

			vim.keymap.set("n", "<leader>ca", function()
				vim.lsp.buf.code_action()
			end, opts)

			vim.keymap.set("n", "<leader>r", function()
				vim.lsp.buf.rename()
			end, opts)

			vim.keymap.set("i", "<C-h>", function()
				vim.lsp.buf.signature_help()
			end, opts)

			vim.keymap.set("n", "<leader>fR", rename_file, opts)

			vim.keymap.set("n", "gd", function()
				vim.lsp.buf.definition()
			end, opts)
		end,
	})

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client == nil then
				return
			end

			if client.name == "ruff" then
				-- disable hover for ruff in favor of pyright
				client.server_capabilities.hoverProvider = false
			end
		end,
		desc = "LSP: Disable ruff hover capability",
	})

	-- Global LSP capabilities for all servers
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.general.positionEncodings = { "utf-16", "utf-8" }
	vim.lsp.config("*", {
		capabilities = capabilities,
	})

	require("mason").setup({})

	-- Biome formatter/linter + code actions
	vim.lsp.config("biome", {
		cmd = { "bunx", "biome", "lsp-proxy" },
	})

	-- HTML with templ support
	vim.lsp.config("html", {
		filetypes = { "html", "templ" },
	})

	-- LuaLS extras for external Lua projects (like WezTerm config)
	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				workspace = {
					checkThirdParty = false,
					library = {
						vim.fn.stdpath("data") .. "/lazy/wezterm-types/lua",
						vim.fn.stdpath("data") .. "/lazy/wezterm-types/lua/wezterm/types",
					},
				},
			},
		},
	})

	-- Python LSP (pyright)
	vim.lsp.config("pyright", {
		settings = {
			pyright = {
				-- use ruff's import organizer
				disableOrganizeImports = true,
			},
		},
	})

	-- don't show parse errors in a separate window
	vim.g.zig_fmt_parse_errors = 0
	-- disable format-on-save from `ziglang/zig.vim`
	vim.g.zig_fmt_autosave = 0

	vim.lsp.config("zls", {
		settings = {
			zls = {
				semantic_tokens = "partial",
			},
		},
	})

	-- Python linter/formatter (ruff)
	vim.lsp.config("ruff", {})

	local servers_to_enable = {
		"bashls",
		"biome",
		"html",
		"lua_ls",
		"pyright",
		"ruff",
		"rust_analyzer",
		"tailwindcss",
		"terraformls",
		"zls",
	}

	for _, server in ipairs(servers_to_enable) do
		vim.lsp.enable(server)
	end

	vim.diagnostic.config({
		virtual_text = true,
	})

	-- Autocomplete and Snippets
	local cmp = require("cmp")
	local luasnip = require("luasnip")
	local lspkind = require("lspkind")
	---@diagnostic disable-next-line: redundant-parameter
	lspkind.init({
		mode = "symbol",
		symbol_map = {
			Codeium = "",
		},
	})

	local default_mapping = cmp.mapping.preset.insert({
		["<CR>"] = cmp.mapping.confirm({ select = false }),
		["<C-Space>"] = cmp.mapping.complete(),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.locally_jumpable(1) then
				luasnip.jump(1)
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	})

	cmp.setup({
		snippet = {
			expand = function(args)
				require("luasnip").lsp_expand(args.body)
			end,
		},
		formatting = {
			format = lspkind.cmp_format({
				maxwidth = 50,
				ellipsis_char = "...",
			}),
		},
		mapping = default_mapping,
		preselect = "item",
		sources = {
			{
				name = "lazydev",
				group_index = 0,
			},
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			{ name = "codeium" },
		},
		performance = {
			fetching_timeout = 1000,
			debounce = 60,
			throttle = 30,
			filtering_context_budget = 3,
			confirm_resolve_timeout = 80,
			async_budget = 1,
			max_view_entries = 200,
		},
		completion = {
			completeopt = "menu,menuone,noinsert",
		},
	})

	cmp.setup.filetype("jjdescription", {
		sources = {},
	})

	cmp.setup.filetype("oil", {
		sources = {
			{
				name = "lazydev",
				group_index = 0,
			},
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
		},
	})

	require("fidget").setup({})
end

return M
