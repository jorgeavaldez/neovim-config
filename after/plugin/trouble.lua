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

vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>",
    { silent = true, noremap = true }
)

vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>",
    { silent = true, noremap = true }
)

vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>",
    { silent = true, noremap = true }
)

vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>",
    { silent = true, noremap = true }
)

vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",
    { silent = true, noremap = true }
)

vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>",
    { silent = true, noremap = true }
)
