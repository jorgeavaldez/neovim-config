local trouble = require("trouble.sources.telescope")

local telescope = require("telescope")
local telescope_actions = require("telescope.actions")

telescope.setup({
    defaults = {
        mappings = {
            i = { ["<c-t>"] = trouble.open },
            n = { ["<c-t>"] = trouble.open },
        },
    },
    pickers = {
        buffers = {
            mappings = {
                i = {
                    ["<c-d>"] = telescope_actions.delete_buffer + telescope_actions.move_to_top,
                }
            }
        }
    }
})

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble<cr>",
    { silent = true, noremap = true }
)

vim.keymap.set("n", "<leader>xw", "<cmd>Trouble diagnostics<cr>",
    { silent = true, noremap = true }
)

vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist<cr>",
    { silent = true, noremap = true }
)

vim.keymap.set("n", "<leader>xq", "<cmd>Trouble quickfix<cr>",
    { silent = true, noremap = true }
)

vim.keymap.set("n", "gR", "<cmd>Trouble lsp_references<cr>",
    { silent = true, noremap = true }
)
