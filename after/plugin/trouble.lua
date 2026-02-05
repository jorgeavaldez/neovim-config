local trouble = require("trouble.sources.telescope")

local telescope = require("telescope")
local telescope_actions = require("telescope.actions")

telescope.setup({
    defaults = {
        results_title = false, -- cleaner look, count shows in prompt
        selection_caret = "▶ ",
        entry_prefix = "  ",
        mappings = {
            i = { ["<c-t>"] = trouble.open },
            n = {
                ["<c-t>"] = trouble.open,
                ["J"] = telescope_actions.results_scrolling_down,
                ["K"] = telescope_actions.results_scrolling_up,
                ["gg"] = telescope_actions.move_to_top,
                ["G"] = telescope_actions.move_to_bottom,
            },
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
