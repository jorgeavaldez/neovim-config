local obsidian_group = vim.api.nvim_create_augroup("ObsidianLoader", { clear = true })

local function load_obsidian()
	local ok, obsidian = pcall(require, "obsidian")
	if not ok then
		return false
	end
	return true
end

vim.api.nvim_create_user_command("ObsidianNewPrompt", function()
	if not load_obsidian() then
		vim.notify("Failed to load obsidian plugin", vim.log.levels.ERROR)
		return
	end

	local client = require("obsidian").get_client()
	local vault_path = client.dir
	local prompts_dir = vault_path / "prompts"

	prompts_dir:mkdir({ parents = true, exist_ok = true })

	vim.ui.input({ prompt = "Prompt note title: " }, function(title)
		if title and title ~= "" then
			local note = client:create_note({ title = title, dir = prompts_dir })
			vim.cmd("edit " .. tostring(note.path))
		end
	end)
end, { desc = "Create new Obsidian prompt note" })

vim.keymap.set(
	"n",
	"gf",
	function()
		if not load_obsidian() then
			return "gf"
		end
		if require("obsidian").util.cursor_on_markdown_link() then
			return "<cmd>Obsidian follow_link<CR>"
		else
			return "gf"
		end
	end,
	{ noremap = false, expr = true, desc = "Follow obsidian link or file" }
)

vim.keymap.set("n", "<leader>oN", ":Obsidian new ", { desc = "New Obsidian Note with name" })
vim.keymap.set("n", "<leader>on", "<cmd>Obsidian new<CR>", { desc = "New Obsidian note" })
vim.keymap.set("n", "<leader>op", "<cmd>ObsidianNewPrompt<CR>", { desc = "New Obsidian prompt" })
vim.keymap.set("n", "<leader>o/", "<cmd>Obsidian search<CR>", { desc = "Search Obsidian notes" })
vim.keymap.set("n", "<leader>of", "<cmd>Obsidian quick_switch<CR>", { desc = "Quick switch notes" })
vim.keymap.set("n", "<leader>ob", "<cmd>Obsidian backlinks<CR>", { desc = "Show backlinks" })
vim.keymap.set("n", "<leader>oL", ":Obsidian link ", { desc = "Link to note (with query)" })
vim.keymap.set("n", "<leader>oln", ":Obsidian link_new ", { desc = "Link to new note (with title)" })
vim.keymap.set("n", "<leader>olN", "<cmd>Obsidian link_new<CR>", { desc = "Link to new note" })
vim.keymap.set("n", "<leader>ol", "<cmd>Obsidian link<CR>", { desc = "Link to note" })
vim.keymap.set("n", "<leader><CR>", "<cmd>Obsidian follow_link<CR>", { desc = "Follow link" })
