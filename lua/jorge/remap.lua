vim.g.mapleader = ' '

vim.keymap.set('', '<Space>', '<Nop>')

-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>", { desc = 'Open file view' })

-- move selected lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

vim.keymap.set("n", "<leader>ff", function()
    vim.lsp.buf.format()
end)

vim.keymap.set("n", "<leader>fc", ":call setreg('+', expand('%:.'))<CR>", { desc = "Copy file path" })
vim.keymap.set("n", "<leader>fD", ":%d<CR>", { desc = "Delete contents of current buffer/file" })

vim.keymap.set("n", "<C-k>", ":noh<CR>", { desc = "Clear search results" })
vim.keymap.set("n", "<leader>ce", ":e " .. vim.fn.expand("$HOME/.config/nvim/") .. "<CR>", { desc = "Open config dir" })

-- windows
vim.keymap.set("n", "<leader>wv", vim.cmd.vsplit)
vim.keymap.set("n", "<leader>ws", vim.cmd.split)
vim.keymap.set("n", "<leader>wh", "<C-w>h")
vim.keymap.set("n", "<leader>wl", "<C-w>l")
vim.keymap.set("n", "<leader>wj", "<C-w>j")
vim.keymap.set("n", "<leader>wk", "<C-w>k")
vim.keymap.set("n", "<leader>wr", "<C-w>r")
vim.keymap.set("n", "<leader>wq", ":q<CR>")
vim.keymap.set("n", "<leader>wm", ":wincmd _<Bar>wincmd <Bar><CR>", { desc = "Maximize buffer" })
vim.keymap.set("n", "<leader>wM", "<C-w>=", { desc = "Minimize buffer" })
vim.keymap.set("n", "<leader>wT", "<C-w>T", { desc = "Move window to new tab" })
vim.keymap.set("n", "<leader>wt", ":tab split<CR>", { desc = "Open buffer in new tab, maintain state" })

-- Tabs
vim.keymap.set("n", "<leader>tn", ":tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<leader>tp", ":tabprevious<CR>", { desc = "Previous tab" })

-- buffers
vim.keymap.set("n", "<leader>bc", ":bp<bar>sp<bar>bn<bar>bd<CR>", { desc = "Close Buffer" })
vim.keymap.set("n", "<leader>bd", ":bp<bar>sp<bar>bn<bar>bd<CR>", { desc = "Close Buffer" })
vim.keymap.set("n", "<leader>bp", ":bp<CR>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<leader>bn", ":bn<CR>", { desc = "Next Buffer" })

-- terminal
vim.keymap.set("n", "<leader>$", ":terminal<CR>")
-- vim.keymap.set("t", "<C-;><C-n>", "<C-\\><C-n>")



-- obsidian
vim.keymap.set(
    "n",
    "gf",
    function()
        if require("obsidian").util.cursor_on_markdown_link() then
            return "<cmd>ObsidianFollowLink<CR>"
        else
            return "gf"
        end
    end,
    { noremap = false, expr = true }
)

vim.keymap.set("n", "<leader>oN", ":ObsidianNew ", { desc = "New Obsidian Note with name" })
vim.keymap.set("n", "<leader>on", "<cmd>ObsidianNew<CR>")
vim.keymap.set("n", "<leader>o/", "<cmd>ObsidianSearch<CR>")
vim.keymap.set("n", "<leader>of", "<cmd>ObsidianQuickSwitch<CR>")
vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>")
vim.keymap.set("n", "<leader>oL", "<cmd>ObsidianLink")
vim.keymap.set("n", "<leader>oln", "<cmd>ObsidianLinkNew")
vim.keymap.set("n", "<leader>olN", "<cmd>ObsidianLinkNew<CR>")
vim.keymap.set("n", "<leader>ol", "<cmd>ObsidianLink<CR>")
vim.keymap.set("n", "<leader><CR>", "<cmd>ObsidianFollowLink<CR>")
