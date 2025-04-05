-- vim.filetype.add({ extension = { templ = "templ" } })

local lsp = require("lsp-zero")
local lspconfig = require("lspconfig")

local function rename_file()
	-- https://github.com/neovim/neovim/issues/20784#issuecomment-1288085253
	local source_file = vim.api.nvim_buf_get_name(0)
	local target_file

	vim.ui.input({
		prompt = "Target : ",
		completion = "file",
		default = source_file,
	}, function(input)
		target_file = input
	end)

	vim.lsp.util.rename(source_file, target_file, {})
end

local function default_on_attach(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	-- vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts);
	vim.keymap.set("n", "<leader>k", function()
		vim.lsp.buf.hover()
	end, opts)
	-- vim.keymap.set("n", "<leader>s", function() vim.lsp.buf.document_symbol() end, opts);
	vim.keymap.set("n", "<leader>d", function()
		vim.diagnostic.open_float()
	end, opts)
	vim.keymap.set("n", "]d", function()
		vim.diagnostic.goto_next()
	end, opts)
	vim.keymap.set("n", "[d", function()
		vim.diagnostic.goto_prev()
	end, opts)
	vim.keymap.set("n", "<leader>ca", function()
		vim.lsp.buf.code_action()
	end, opts)
	-- vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts);
	vim.keymap.set("n", "<leader>r", function()
		vim.lsp.buf.rename()
	end, opts)
	vim.keymap.set("i", "<C-h>", function()
		vim.lsp.buf.signature_help()
	end, opts)
	vim.keymap.set("n", "<leader>fR", rename_file, opts)

	-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/quick-recipes.md#setup-with-nvim-navic
	if client.server_capabilities.documentSymbolProvider then
		require("nvim-navic").attach(client, bufnr)
	end
end

--[[
lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({ buffer = bufnr });
    -- these are only set in an lsp buffer
    -- we can add remaps in here

    default_on_attach(client, bufnr)
end)
--]]
--
lsp.extend_lspconfig({
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
	lsp_attach = function(client, bufnr)
		lsp.default_keymaps({ buffer = bufnr })
		-- these are only set in an lsp buffer
		-- we can add remaps in here

		default_on_attach(client, bufnr)
	end,
	float_border = "rounded",
	sign_text = true,
})
require("typescript-tools").setup({})

require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = {
		-- "ts_ls",
		"tailwindcss",
		"eslint",
		"pyright",
		"rust_analyzer",
		"lua_ls",
		"gopls",
		"html",
		"bashls",
	},
	lua_ls = function()
		lspconfig.lua_ls.setup({
			on_init = function(client)
				lsp.nvim_lua_settings(client, {
					Lua = {
						runtime = {
							version = "LuaJIT",
							special = { reload = "require" },
						},
						workspace = {
							library = {
								vim.fn.expand("$VIMRUNTIME/lua"),
								vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
								vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
							},
						},
					},
				})
			end,
		})
	end,
	handlers = {
		function(server_name)
			-- we're using typescript-tools instead
			if server_name ~= "ts_ls" then
				require("lspconfig")[server_name].setup({})
			end
		end,
	},
})

lspconfig.biome.setup({
	cmd = { "bunx", "biome", "lsp-proxy" },
})

-- (Optional) Configure lua language server for neovim
lspconfig.lua_ls.setup(lsp.nvim_lua_ls())

-- configure templ
lspconfig.html.setup({
	filetypes = { "html", "templ" },
})

require("go").setup({
	lsp_cfg = true,
	lsp_on_attach = default_on_attach,
	lsp_keymaps = false,
})

vim.diagnostic.config({
	virtual_text = true,
})

-- Autocomplete and Snippets

local cmp = require("cmp")
local cmp_action = lsp.cmp_action()

local default_mapping = cmp.mapping.preset.insert({
	["<CR>"] = cmp.mapping.confirm({ select = false }),
	["<C-Space>"] = cmp.mapping.complete(),

	["<Tab>"] = cmp_action.luasnip_supertab(),
	["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
})

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	formatting = lsp.cmp_format({ details = true }),
	mapping = default_mapping,
	preselect = "item",
	sources = {
		{
			name = "lazydev",
			-- set to 0 to skip loading luals completions
			group_index = 0,
		},
		{ name = "minuet" },
		{ name = "supermaven" },
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	},
	performance = {
		fetching_timeout = 1000,
	},
	completion = {
		completeopt = "menu,menuone,noinsert",
	},
})

local null_ls = require("null-ls")

null_ls.setup({
	debug = true,
	sources = {
		null_ls.builtins.formatting.djhtml,
		null_ls.builtins.formatting.djlint,
		null_ls.builtins.formatting.black,
		null_ls.builtins.formatting.isort,

		--[[
        null_ls.builtins.diagnostics.flake8,
        null_ls.builtins.formatting.jq,
        null_ls.builtins.formatting.prismaFmt,
        ]]
		--

		null_ls.builtins.formatting.biome,

		null_ls.builtins.diagnostics.yamllint,
		null_ls.builtins.formatting.yamlfmt,

		null_ls.builtins.formatting.sqlfmt,
		null_ls.builtins.formatting.stylua,
	},
})

local fidget = require("fidget")
fidget.setup({})
