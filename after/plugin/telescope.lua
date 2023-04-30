local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', function()
    -- show hidden files but exclude .git
    builtin.find_files {
        find_command = {
            "rg",
            "--files",
            "--hidden",
            "-g",
            "!.git",
        },
    }
end, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = "List git files" });
vim.keymap.set('n', '<leader>/', builtin.live_grep, { desc = "Grep across project" });
vim.keymap.set('n', '<leader>*', builtin.grep_string, { desc = "Grep for line under cursor across project" });
-- vim.keymap.set("n", "<leader>h", builtin.help_tags, { desc = "list all help tags" });
vim.keymap.set("n", "<leader>bb", builtin.buffers, { desc = "list buffers" });
vim.keymap.set("n", "<leader>s", builtin.lsp_document_symbols, { desc = "Show symbols in document" });
vim.keymap.set("n", "<leader>ps", builtin.lsp_dynamic_workspace_symbols, { desc = "Dynamically show workspace symbols" });
-- vim.keymap.set("n", "<leader>d", builtin.diagnostics, { desc = "List diagnostics" });
vim.keymap.set("n", "gr", builtin.lsp_references, { desc = "Go to references" });
vim.keymap.set("n", "gd", builtin.lsp_definitions, { desc = "Go to definitions" });
vim.keymap.set("n", "gi", builtin.lsp_implementations, { desc = "Go to Implementations" });
vim.keymap.set("n", "<leader>T", function()
    builtin.colorscheme({ enable_preview = true })
end, { desc = "Theme picker" });
