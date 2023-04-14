vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.1',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    use {
        'folke/tokyonight.nvim',
        as = "tokyonight",
    }
    use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
    use('nvim-treesitter/playground')
    use({
        "nvim-treesitter/nvim-treesitter-textobjects",
        after = "nvim-treesitter",
        requires = "nvim-treesitter/nvim-treesitter",
    })
    use("nvim-lua/plenary.nvim")
    use("ThePrimeagen/harpoon")
    use("mbbill/undotree")
    use("tpope/vim-fugitive")
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},             -- Required
            {                                      -- Optional
                'williamboman/mason.nvim',
                run = function()
                    pcall(vim.cmd, 'MasonUpdate')
                end,
            },
            {'williamboman/mason-lspconfig.nvim'}, -- Optional

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},     -- Required
            {'hrsh7th/cmp-nvim-lsp'}, -- Required
            {'L3MON4D3/LuaSnip'},     -- Required
        }
    }

    use('folke/which-key.nvim')

    use({
        "epwalsh/obsidian.nvim",
        config = function ()
            require("obsidian").setup({
                dir = "~/obsidian/delvaze",
                completion = {
                    nvim_cmp = true
                },
                daily_notes = {
                    folder = "daily"
                },
                templates = {
                    subdir = "templates",
                    date_format = "%Y-%M-%D",
                    time_format = "%H:%M",
                }
            })
        end
    })
end)
