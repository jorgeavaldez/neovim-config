vim.g.mapleader = " "

vim.keymap.set("", "<Space>", "<Nop>")

-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>", { desc = "Open file view" })

-- move selected lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

vim.keymap.set("n", "<leader>ff", function()
	require("conform").format({ lsp_format = "fallback" })
end)

vim.keymap.set("n", "<leader>fc", ":call setreg('+', expand('%:.'))<CR>", { desc = "Copy file path" })
vim.keymap.set("n", "<leader>fC", ":call setreg('+', expand('%:p'))<CR>", { desc = "Copy full file path" })
vim.keymap.set("n", "<leader>fG", "<cmd>OpenCurrentFileInGitHub<CR>", { desc = "Open current file on GitHub" })
vim.keymap.set("x", "<leader>fG", function()
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")

	require("jorge.commands").open_current_file_in_github({
		start_line = start_line,
		end_line = end_line,
	})
end, { desc = "Open selection on GitHub" })
vim.keymap.set("n", "<leader>fD", ":%d<CR>", { desc = "Delete contents of current buffer/file" })

vim.keymap.set("n", "<C-k>", ":noh<CR>", { desc = "Clear search results" })
vim.keymap.set("n", "<leader>ce", ":e " .. vim.fn.expand("$HOME/.config/nvim/") .. "<CR>", { desc = "Open config dir" })

-- windows
vim.keymap.set("n", "<leader>wv", vim.cmd.vsplit, { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>ws", vim.cmd.split, { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Focus left window" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Focus right window" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Focus lower window" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Focus upper window" })
vim.keymap.set("n", "<leader>wr", "<C-w>r", { desc = "Rotate windows" })
vim.keymap.set("n", "<leader>wq", ":wq<CR>", { desc = "Save and close window" })
vim.keymap.set("n", "<leader>qq", ":wqall<CR>", { desc = "Save and quit all" })
vim.keymap.set("n", "<leader>QQ", ":qall!<CR>", { desc = "Quit all (force)" })
vim.keymap.set("n", "<leader>wm", ":wincmd _<Bar>wincmd <Bar><CR>", { desc = "Maximize buffer" })
vim.keymap.set("n", "<leader>wM", "<C-w>=", { desc = "Minimize buffer" })
vim.keymap.set("n", "<leader>wT", "<C-w>T", { desc = "Move window to new tab" })
vim.keymap.set("n", "<leader>wt", ":tab split<CR>", { desc = "Open buffer in new tab, maintain state" })

-- Tabs
vim.keymap.set("n", "<leader>tn", ":tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<leader>tp", ":tabprevious<CR>", { desc = "Previous tab" })

-- buffers
vim.keymap.set("n", "<leader>bC", ":bp<bar>sp<bar>bn<bar>bd<CR>", { desc = "Close Buffer" })
vim.keymap.set("n", "<leader>bcc", ":bp<bar>sp<bar>bn<bar>bd<CR>", { desc = "Close Buffer" })
vim.keymap.set("n", "<leader>bd", ":bp<bar>sp<bar>bn<bar>bd<CR>", { desc = "Close Buffer" })
vim.keymap.set("n", "<leader>bD", ":bp<bar>sp<bar>bn<bar>bd!<CR>", { desc = "Close Buffer" })
vim.keymap.set("n", "<leader>bp", ":bp<CR>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<leader>bn", ":bn<CR>", { desc = "Next Buffer" })

-- terminal
vim.keymap.set("n", "<leader>$", ":terminal<CR>")
-- my leader key is <C-;> in wezterm
-- vim.keymap.set("t", "<C-;><C-n>", "<C-\\><C-n>")
vim.keymap.set("t", "<Esc><Esc><Esc>", "<C-\\><C-n>")

local function rename_terminal(command_opts)
	local name = vim.trim(command_opts.args or "")
	if name == "" then
		name = vim.trim(vim.fn.input("Terminal name: "))
	end

	if name == "" then
		return
	end

	vim.cmd.file("term://" .. name)
end

local terminal_commands_augroup = vim.api.nvim_create_augroup("jorge_terminal_commands", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
	group = terminal_commands_augroup,
	callback = function(args)
		vim.api.nvim_buf_create_user_command(args.buf, "RenameTerminal", rename_terminal, {
			nargs = "?",
			desc = "Rename the terminal",
		})
	end,
	desc = "Create terminal-only user commands",
})

-- insert date/time
vim.keymap.set("n", "<leader>id", function()
	vim.api.nvim_put({ os.date("%Y-%m-%d") }, "c", true, true)
end, { desc = "Insert date (YYYY-MM-DD)" })

vim.keymap.set("n", "<leader>it", function()
	vim.api.nvim_put({ os.date("%H:%M") }, "c", true, true)
end, { desc = "Insert time (HH:MM)" })
