-- Git workflow integration keymaps and commands
-- Enhanced git workflow combining fugitive, diffview, and gitsigns

-- Core git workflow keymaps
vim.keymap.set("n", "<leader>gg", "<cmd>Git<CR>", { desc = "Git status (fugitive)" })
vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "Open diffview" })
vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewOpen HEAD~1<CR>", { desc = "Diff against previous commit" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<CR>", { desc = "File history" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", { desc = "Current file history" })
vim.keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<CR>", { desc = "Close diffview" })
vim.keymap.set("n", "<leader>gf", "<cmd>DiffviewToggleFiles<CR>", { desc = "Toggle diffview file panel" })

-- Enhanced git operations
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
vim.keymap.set("n", "<leader>gl", "<cmd>Git log --oneline<CR>", { desc = "Git log" })
vim.keymap.set("n", "<leader>gL", "<cmd>Git log<CR>", { desc = "Git log (detailed)" })
vim.keymap.set("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git push" })
vim.keymap.set("n", "<leader>gP", "<cmd>Git pull<CR>", { desc = "Git pull" })

-- Quick diff comparisons
vim.keymap.set("n", "<leader>gm", "<cmd>DiffviewOpen origin/main<CR>", { desc = "Diff against origin/main" })
vim.keymap.set("n", "<leader>gs", "<cmd>DiffviewOpen --staged<CR>", { desc = "Diff staged changes" })
vim.keymap.set("n", "<leader>gu", "<cmd>DiffviewOpen HEAD<CR>", { desc = "Diff unstaged changes" })
vim.keymap.set("n", "<leader>ga", "<cmd>DiffviewOpen --cached HEAD<CR>", { desc = "Diff all changes (staged + unstaged)" })

-- Quick access to git workflows
vim.keymap.set("n", "<leader>gq", function()
	-- Quick git workflow: open diffview if changes exist, otherwise show git status
	local handle = io.popen("git status --porcelain 2>/dev/null")
	if handle then
		local result = handle:read("*a")
		handle:close()
		if result and result ~= "" then
			vim.cmd("DiffviewOpen")
		else
			print("No changes to diff")
			vim.cmd("Git")
		end
	end
end, { desc = "Quick git diff or status" })

-- Bridge fugitive and diffview workflows
vim.keymap.set("n", "<leader>gv", function()
	-- From fugitive status to diffview
	local current_buf = vim.api.nvim_get_current_buf()
	local buf_name = vim.api.nvim_buf_get_name(current_buf)
	if string.find(buf_name, "fugitive://") then
		vim.cmd("DiffviewOpen")
	else
		-- If in a regular file, show its diff
		vim.cmd("Gitsigns diffthis")
	end
end, { desc = "Bridge fugitive to diffview" })

-- Custom git commands
vim.api.nvim_create_user_command("DiffMain", "DiffviewOpen origin/main", { desc = "Diff against main branch" })
vim.api.nvim_create_user_command("DiffStaged", "DiffviewOpen --staged", { desc = "Diff staged changes" })
vim.api.nvim_create_user_command("DiffUnstaged", "DiffviewOpen HEAD", { desc = "Diff unstaged changes" })
vim.api.nvim_create_user_command("DiffAll", function()
	-- Show a comprehensive diff view with both staged and unstaged changes
	vim.cmd("DiffviewOpen")
end, { desc = "Diff all changes (staged + unstaged + untracked)" })

vim.api.nvim_create_user_command("DiffWorking", function()
	-- Show working tree changes (unstaged + untracked)
	local handle = io.popen("git ls-files --others --exclude-standard 2>/dev/null")
	local untracked = ""
	if handle then
		untracked = handle:read("*a")
		handle:close()
	end
	
	if untracked and untracked ~= "" then
		print("Opening diffview with untracked files...")
		vim.cmd("DiffviewOpen HEAD")
	else
		vim.cmd("DiffviewOpen HEAD")
	end
end, { desc = "Diff working directory changes" })

vim.api.nvim_create_user_command("GitQuickDiff", function()
	local current_file = vim.fn.expand('%')
	if current_file ~= "" then
		vim.cmd("DiffviewOpen HEAD~1 -- " .. current_file)
	else
		print("No file in current buffer")
	end
end, { desc = "Quick diff current file against previous commit" })

vim.api.nvim_create_user_command("GitWorkflow", function()
	-- Smart git workflow command
	local handle = io.popen("git status --porcelain 2>/dev/null")
	if handle then
		local result = handle:read("*a")
		handle:close()
		if result and result ~= "" then
			print("Opening diffview for changes...")
			vim.cmd("DiffviewOpen")
		else
			print("No changes found, opening git status...")
			vim.cmd("Git")
		end
	else
		print("Not in a git repository")
	end
end, { desc = "Smart git workflow - diffview if changes, status otherwise" })

-- Which-key integration for git commands (if which-key is available)
local ok, wk = pcall(require, "which-key")
if ok then
	wk.add({
		{ "<leader>g", group = "Git" },
		{ "<leader>gg", desc = "Git status (fugitive)" },
		{ "<leader>gd", desc = "Open diffview" },
		{ "<leader>gD", desc = "Diff against previous commit" },
		{ "<leader>gh", desc = "File history" },
		{ "<leader>gH", desc = "Current file history" },
		{ "<leader>gc", desc = "Close diffview" },
		{ "<leader>gf", desc = "Toggle diffview file panel" },
		{ "<leader>gb", desc = "Git blame" },
		{ "<leader>gl", desc = "Git log" },
		{ "<leader>gL", desc = "Git log (detailed)" },
		{ "<leader>gp", desc = "Git push" },
		{ "<leader>gP", desc = "Git pull" },
		{ "<leader>gm", desc = "Diff against origin/main" },
		{ "<leader>gs", desc = "Diff staged changes" },
		{ "<leader>gu", desc = "Diff unstaged changes" },
		{ "<leader>ga", desc = "Diff all changes" },
		{ "<leader>gq", desc = "Quick git diff or status" },
		{ "<leader>gv", desc = "Bridge fugitive to diffview" },
	})
end

-- Auto-commands for enhanced git workflow
vim.api.nvim_create_augroup("GitWorkflow", { clear = true })

-- Auto-open diffview when entering fugitive buffers
vim.api.nvim_create_autocmd("BufEnter", {
	group = "GitWorkflow",
	pattern = "fugitive://*",
	callback = function()
		vim.keymap.set("n", "dv", "<cmd>DiffviewOpen<CR>", { buffer = true, desc = "Open diffview from fugitive" })
		vim.keymap.set("n", "dh", "<cmd>DiffviewFileHistory %<CR>", { buffer = true, desc = "File history from fugitive" })
	end,
})

print("Git workflow integration loaded")