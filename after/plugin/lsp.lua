local lspconfig = require("lspconfig")

vim.diagnostic.config({ jump = { float = true } })

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

	local params = {
		oldUri = vim.uri_from_fname(source_file),
		newUri = vim.uri_from_fname(target_file),
	}
	vim.lsp.buf_request(0, "workspace/willRenameFiles", {
		files = { params }
	}, function(err, result)
		if err then
			vim.notify("Error renaming file: " .. err.message, vim.log.levels.ERROR)
			return
		end
		if result then
			vim.lsp.util.apply_workspace_edit(result, "utf-16")
		end
	end)
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

		vim.keymap.set("n", "gd", function()
			vim.lsp.buf.definition()
		end, opts)
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client == nil then
			return
		end

		if client.name == 'ruff' then
			-- disable hover for ruff in favor of pyright
			client.server_capabilities.hoverProvider = false
		end
	end,
	desc = 'LSP: Disable ruff hover capability',
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.general.positionEncodings = { "utf-16", "utf-8" }

require("typescript-tools").setup({
	capabilities = capabilities,
})

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
		"terraformls",
	},
	automatic_enable = {
		exclude = {
			"ts_ls",
		},
	},
	handlers = {
		function(server_name)
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.general.positionEncodings = { "utf-16", "utf-8" }
			lspconfig[server_name].setup({
				capabilities = capabilities,
			})
		end,
	},
})

lspconfig.biome.setup({
	cmd = { "bunx", "biome", "lsp-proxy" },
	capabilities = capabilities,
})

-- configure templ
lspconfig.html.setup({
	filetypes = { "html", "templ" },
	capabilities = capabilities,
})

lspconfig.pyright.setup({
	settings = {
		pyright = {
			-- use ruff's import organizer
			disableOrganizeImports = true,
		},
	},
	capabilities = capabilities,
})

lspconfig.ruff.setup({
	capabilities = capabilities,
})

vim.lsp.enable('ruff')

require("go").setup({
	lsp_cfg = {
		capabilities = capabilities,
	},
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
			group_index = 0,
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

		--[[ ruff takes care of this
		null_ls.builtins.formatting.isort,
        null_ls.builtins.diagnostics.flake8,
        null_ls.builtins.formatting.jq,
        null_ls.builtins.formatting.prismaFmt,
        ]]
		--

		null_ls.builtins.formatting.biome,

		null_ls.builtins.diagnostics.yamllint,
		null_ls.builtins.formatting.yamlfmt,

		null_ls.builtins.formatting.sqlfmt,
		null_ls.builtins.formatting.shfmt.with({
			filetypes = { "sh", "bash", "zsh" },
		}),
		-- null_ls.builtins.formatting.stylua,
	},
})

local fidget = require("fidget")
fidget.setup({})
