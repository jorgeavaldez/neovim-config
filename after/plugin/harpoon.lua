local harpoon = require('harpoon')
harpoon:setup()

local function toggle_telescope(harpoon_files)
    local conf = require("telescope.config").values
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
            results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
    }):find()
end

vim.keymap.set("n", "<leader>pa", function() harpoon:list():append() end, { desc = "Harpoon file" })
vim.keymap.set("n", "<leader>ph", function()
    toggle_telescope(harpoon:list())
end, { desc = "Harpoon ui" })
