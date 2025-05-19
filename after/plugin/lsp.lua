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

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local opts = { buffer = args.buf, remap = false }

		vim.keymap.set("n", "<leader>k", function()
			vim.lsp.buf.hover()
		end, opts)
		-- vim.keymap.set("n", "<leader>s", function() vim.lsp.buf.document_symbol() end, opts);
		vim.keymap.set("n", "<leader>d", function()
			vim.diagnostic.open_float()
		end, opts)
		vim.keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = 1 })
		end, opts)
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.jump({
				count = -1,
			})
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
	end,
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
	automatic_enable = {
		exclude = {
			"ts_ls",
		},
	},
})

lspconfig.biome.setup({
	cmd = { "bunx", "biome", "lsp-proxy" },
})

-- configure templ
lspconfig.html.setup({
	filetypes = { "html", "templ" },
})

require("go").setup({
	lsp_cfg = true,
	-- TODO: check this works w/ the global on_attach
	-- lsp_on_attach = default_on_attach,
	lsp_keymaps = false,
})

vim.diagnostic.config({
	virtual_text = true,
})

-- Autocomplete and Snippets

local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")

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
		format = lspkind.cmp_format(),
	},
	mapping = default_mapping,
	preselect = "item",
	sources = {
		{
			name = "lazydev",
			-- set to 0 to skip loading luals completions
			group_index = 1,
		},
		-- { name = "minuet" },
		{ name = "supermaven" },
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		per_filetype = {
			codecompanion = { "codecompanion" },
		},
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
		-- null_ls.builtins.formatting.stylua,
	},
})

local fidget = require("fidget")
fidget.setup({})
