local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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

require('lazy').setup({

    { "folke/neodev.nvim",               config = true },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },

    { "catppuccin/nvim",                 name = "catppuccin", priority = 1000 },

    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = {
            "nvim-treesitter/nvim-treesitter"
        }
    },

    "nvim-lua/plenary.nvim",
    { "ThePrimeagen/harpoon", branch = "harpoon2",                                                dependencies = { "nvim-lua/plenary.nvim" } },
    "mbbill/undotree",
    "tpope/vim-fugitive",

    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' }, -- Required
            {
                -- Optional
                'williamboman/mason.nvim',
            },
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },     -- Required
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            { 'L3MON4D3/LuaSnip' },     -- Required
        }
    },

    {
        "nvimtools/none-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    -- "jose-elias-alvarez/typescript.nvim",
    {
        "SmiteshP/nvim-navic",
        dependencies = { "neovim/nvim-lspconfig" }
    },

    {
        'nvimdev/lspsaga.nvim',
        event = 'LspAttach',
        config = function()
            require('lspsaga').setup({})
        end,
        dependencies = {
            'nvim-treesitter/nvim-treesitter', -- optional
            'nvim-tree/nvim-web-devicons'      -- optional
        }
    },

    'mfussenegger/nvim-dap',
    {
        'mfussenegger/nvim-dap-python',
        dependencies = { 'mfussenegger/nvim-dap' },
    },

    { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },

    {
        'j-hui/fidget.nvim',
        -- config = true,
        dependencies = { 'VonHeikemen/lsp-zero.nvim' },
    },

    {
        "folke/trouble.nvim",
        opts = {},
        cmd = "Trouble",
    },

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    },

    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = true
    },

    { 'sindrets/diffview.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },

    { 'gelguy/wilder.nvim' },

    {
        "epwalsh/obsidian.nvim",
        version = "*",
        lazy = true,
        ft = "markdown",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        opts = {
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
            },
            mappings = {
                ["gf"] = {
                    action = function()
                        return require("obsidian").util.gf_passthrough()
                    end,
                    opts = { noremap = false, expr = true, buffer = true },
                },
            },
        },
    },

    "tpope/vim-sleuth",
    {
        'ray-x/go.nvim',
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
    },
})
