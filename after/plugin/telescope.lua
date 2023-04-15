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
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>/', builtin.live_grep, {});
vim.keymap.set("n", "<leader>h", builtin.help_tags, {})
vim.keymap.set("n", "<leader>bb", builtin.buffers, {})
