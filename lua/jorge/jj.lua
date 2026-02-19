-- JJ (Jujutsu) workflow integration keymaps and commands

local function map(suffix, cmd, desc)
	vim.keymap.set("n", "<leader>j" .. suffix, cmd, { desc = desc })
end

-- Primary workflow keymaps
map("j", "<cmd>J log<CR>", "JJ log")
map("s", "<cmd>J st<CR>", "JJ status")
map("c", "<cmd>J commit<CR>", "JJ commit")
map("d", "<cmd>J desc<CR>", "JJ describe")
map("D", "<cmd>Jdiff<CR>", "JJ diff current file")
map("b", "<cmd>J annotate<CR>", "JJ annotate (blame)")
map("p", "<cmd>J git push<CR>", "JJ push")
map("f", "<cmd>J git fetch<CR>", "JJ fetch")
map("n", "<cmd>J new<CR>", "JJ new change")
map("u", "<cmd>J undo<CR>", "JJ undo")
map("l", "<cmd>J log<CR>", "JJ log")

-- Bookmark create: opens cmdline with `:J bookmark create ` ready for name input
map("B", ":J bookmark create ", "JJ bookmark create")

-- Aliases for the <leader>jj case (log as home base)
vim.keymap.set("n", "<leader>jj", "<cmd>J log<CR>", { desc = "JJ log (home base)" })

-- Quick reference command
vim.api.nvim_create_user_command("JJWorkflow", function()
	vim.cmd("edit " .. vim.fn.stdpath("config") .. "/JJ_WORKFLOW.md")
end, { desc = "Open JJ workflow reference" })

-- Which-key integration (only if already loaded)
local wk = package.loaded["which-key"]
if wk then
	wk.add({
		{ "<leader>g", group = "JJ (jujutsu)" },
		{ "<leader>j", group = "JJ (jujutsu)" },
	})
end
