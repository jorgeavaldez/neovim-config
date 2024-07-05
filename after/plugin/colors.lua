function ColorMePretty(color)
    -- color = color or "tokyonight-night"
    color = color or "catppuccin-latte"
    -- color = color or "catppuccin-mocha"
    vim.cmd.colorscheme(color)

    --[[
    local oxocarbon = require("oxocarbon")
    vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = oxocarbon.blend, bg = oxocarbon.blend })
    vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = oxocarbon.base02, bg = oxocarbon.base02 })
    vim.api.nvim_set_hl(0, "TelescopePromptNormal", { fg = oxocarbon.base05, bg = oxocarbon.base02 })
    vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = oxocarbon.base08, bg = oxocarbon.base02 })
    vim.api.nvim_set_hl(0, "TelescopeNormal", { fg = oxocarbon.none, bg = oxocarbon.blend })
    vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = oxocarbon.base02, bg = oxocarbon.base12 })
    vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = oxocarbon.base02, bg = oxocarbon.base11 })
    vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = oxocarbon.blend, bg = oxocarbon.blend })
    vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = oxocarbon.none, bg = oxocarbon.base02 })
    vim.api.nvim_set_hl(0, "TelescopePreviewLine", { fg = oxocarbon.none, bg = oxocarbon.base01 })

    -- LSP semantic highlights broke oxocarbon :(
    -- https://www.reddit.com/r/neovim/comments/12gvms4/this_is_why_your_higlights_look_different_in_90/
    local links = {
        ['@lsp.type.namespace'] = '@namespace',
        ['@lsp.type.type'] = '@type',
        ['@lsp.type.class'] = '@type',
        ['@lsp.type.enum'] = '@type',
        ['@lsp.type.interface'] = '@type',
        ['@lsp.type.struct'] = '@structure',
        ['@lsp.type.parameter'] = '@parameter',
        ['@lsp.type.variable'] = '@variable',
        ['@lsp.type.property'] = '@property',
        ['@lsp.type.enumMember'] = '@constant',
        ['@lsp.type.function'] = '@function',
        ['@lsp.type.method'] = '@method',
        ['@lsp.type.macro'] = '@macro',
        ['@lsp.type.decorator'] = '@function',
    }

    for newgroup, oldgroup in pairs(links) do
        vim.api.nvim_set_hl(0, newgroup, { link = oldgroup, default = true })
    end

    -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    --]]
end

ColorMePretty()
