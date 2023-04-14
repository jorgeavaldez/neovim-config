local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>/', function()
  builtin.grep_string({ search = vim.fn.input("search> ") });
end)
vim.keymap.set("n", "<leader>h", builtin.help_tags, {})

