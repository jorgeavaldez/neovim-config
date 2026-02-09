-- JJ (Jujutsu) workflow integration keymaps and commands
-- Replaces the old git.lua with jj.nvim, hunk.nvim, and jjsigns.nvim

-- Helper to dual-bind a keymap to both <leader>g* and <leader>j*
local function dual_map(suffix, cmd, desc)
	vim.keymap.set("n", "<leader>g" .. suffix, cmd, { desc = desc })
	vim.keymap.set("n", "<leader>j" .. suffix, cmd, { desc = desc })
end

-- Primary workflow keymaps
dual_map("g", "<cmd>J log<CR>", "JJ log (home base)")
dual_map("s", "<cmd>J st<CR>", "JJ status")
dual_map("c", "<cmd>J commit<CR>", "JJ commit (describe + new)")
dual_map("d", "<cmd>J desc<CR>", "JJ describe")
dual_map("D", "<cmd>Jdiff<CR>", "JJ diff current file")
dual_map("b", "<cmd>J annotate<CR>", "JJ annotate (blame)")
dual_map("p", "<cmd>J git push<CR>", "JJ push")
dual_map("f", "<cmd>J git fetch<CR>", "JJ fetch")
dual_map("n", "<cmd>J new<CR>", "JJ new change")
dual_map("u", "<cmd>J undo<CR>", "JJ undo")
dual_map("l", "<cmd>J log<CR>", "JJ log")

-- Bookmark create: opens cmdline with `:J bookmark create ` ready for name input
dual_map("B", ":J bookmark create ", "JJ bookmark create")

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
