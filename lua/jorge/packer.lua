local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    use "folke/neodev.nvim"

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.1',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    use {
        'folke/tokyonight.nvim',
        as = "tokyonight",
    }
    use { 'nyoom-engineering/oxocarbon.nvim' }
    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
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
            { 'neovim/nvim-lspconfig' }, -- Required
            {
                -- Optional
                'williamboman/mason.nvim',
                run = function()
                    pcall(vim.cmd, "MasonUpdate")
                end
            },
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },     -- Required
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            { 'L3MON4D3/LuaSnip' },     -- Required
        }
    }

    use({
        "jose-elias-alvarez/null-ls.nvim",
        requires = { "nvim-lua/plenary.nvim" },
    })

    use "jose-elias-alvarez/typescript.nvim"
    use {
        "SmiteshP/nvim-navic",
        requires = "neovim/nvim-lspconfig"
    }

    use 'mfussenegger/nvim-dap'
    use({
        'mfussenegger/nvim-dap-python',
        requires = { 'mfussenegger/nvim-dap' },
    })
    use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }

    use {
        'j-hui/fidget.nvim',
        tag = "legacy",
        requires = 'VonHeikemen/lsp-zero.nvim',
        config = function()
            require("fidget").setup()
        end
    }

    use {
        "folke/trouble.nvim",
        requires = {
            { "nvim-telescope/telescope.nvim" },
            { "nvim-tree/nvim-web-devicons" },
        },
    }

    use('folke/which-key.nvim')

    use({
        "kylechui/nvim-surround",
        tag = "*", -- Use for stability; omit to use `main` branch for the latest features
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    })

    use({ 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' })

    use({ 'gelguy/wilder.nvim' })

    use({
        "epwalsh/obsidian.nvim",
        config = function()
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

    use "tpope/vim-sleuth"
    use 'ray-x/go.nvim'

    if packer_bootstrap then
        require("packer").sync()
    end
end)
