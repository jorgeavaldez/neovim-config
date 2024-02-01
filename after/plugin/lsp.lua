vim.filetype.add({ extension = { templ = "templ" } })

local lsp = require('lsp-zero')

lsp.set_preferences({
    suggest_lsp_servers = true,
});

lsp.preset("recommended");

local lspconfig = require('lspconfig')

local function rename_file()
    -- https://github.com/neovim/neovim/issues/20784#issuecomment-1288085253
    local source_file = vim.api.nvim_buf_get_name(0)
    local target_file

    vim.ui.input({
            prompt = "Target : ",
            completion = "file",
            default = source_file
        },
        function(input)
            target_file = input
        end
    )

    --[[
    local params = {
        command = "_typescript.applyRenameFile",
        arguments = {
            {
                sourceUri = source_file,
                targetUri = target_file,
            },
        },
        title = ""
    }
    --]]

    vim.lsp.util.rename(source_file, target_file, {})
    -- vim.lsp.buf.execute_command(params)
end

local function default_on_attach(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    -- vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts);
    vim.keymap.set("n", "<leader>k", function() vim.lsp.buf.hover() end, opts);
    -- vim.keymap.set("n", "<leader>s", function() vim.lsp.buf.document_symbol() end, opts);
    vim.keymap.set("n", "<leader>d", function() vim.diagnostic.open_float() end, opts);
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts);
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts);
    vim.keymap.set("n", "<leader>a", function() vim.lsp.buf.code_action() end, opts);
    -- vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts);
    vim.keymap.set("n", "<leader>r", function() vim.lsp.buf.rename() end, opts);
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts);
    vim.keymap.set("n", "<leader>fR", rename_file, opts);

    -- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/quick-recipes.md#setup-with-nvim-navic
    if client.server_capabilities.documentSymbolProvider then
        require('nvim-navic').attach(client, bufnr)
    end
end

lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({ buffer = bufnr });
    -- these are only set in an lsp buffer
    -- we can add remaps in here

    default_on_attach(client, bufnr)
end)

lsp.skip_server_setup({ 'tsserver' })

lsp.ensure_installed({
    -- "tsserver",
    "tailwindcss",
    "eslint",
    "pyright",
    "rust_analyzer",
    "lua_ls",
    "gopls",
    "html",
});

-- (Optional) Configure lua language server for neovim
lspconfig.lua_ls.setup(lsp.nvim_lua_ls());

-- configure templ
lspconfig.html.setup({
    filetypes = { "html", "templ" }
});

lsp.setup();

-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/quick-recipes.md#setup-with-typescriptnvim
require('typescript').setup({
    server = {
        on_attach = function(client, bufnr)
            default_on_attach(client, bufnr)

            vim.keymap.set("n", "<leader>fR", "<cmd>TypescriptRenameFile<cr>", { buffer = bufnr, remap = false });
        end
    }
})
require('go').setup({
    lsp_cfg = true,
    lsp_on_attach = default_on_attach,
    lsp_keymaps = false,
})

vim.diagnostic.config({
    virtual_text = true
});

-- Autocomplete and Snippets

local cmp = require('cmp');
-- local cmp_action = lsp.cmp_action();

cmp.setup({
    mapping = {
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<C-Space>"] = cmp.mapping.complete(),
        --[[
        ["<Tab>"] = cmp_action.luasnip_supertab(),
        ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
        ]] --
    },
    preselect = 'item',
    --[[
    completion = {
        completeopt = 'menu,menuone,noinsert'
    },
    ]] --
});

local null_ls = require("null-ls");

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.djhtml,
        null_ls.builtins.formatting.djlint,
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort,
        null_ls.builtins.diagnostics.flake8,

        null_ls.builtins.formatting.jq,
        null_ls.builtins.formatting.prismaFmt,
        null_ls.builtins.formatting.prettier,

        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.formatting.yamlfmt,

        -- https://github.com/jose-elias-alvarez/typescript.nvim#setup-1
        require("typescript.extensions.null-ls.code-actions"),
    },
});
