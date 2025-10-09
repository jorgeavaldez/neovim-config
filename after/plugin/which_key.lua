vim.o.timeout = true
vim.o.timeoutlen = 300

local wk = require("which-key")
wk.setup({})

-- Register keymap group headers
wk.add({
	-- AI / Assistant
	{ "<leader>a", group = "AI/Assistant" },

	-- Buffers
	{ "<leader>b", group = "Buffers" },
	{ "<leader>bc", group = "Breadcrumbs" },

	-- Config / Edit
	{ "<leader>c", group = "Config" },
	{ "<leader>ca", desc = "Code action (LSP)" },
	{ "<leader>ce", desc = "Open config directory" },

	-- Diagnostics / LSP
	{ "<leader>d", desc = "Open diagnostic float" },

	-- Debug
	{ "<leader>m", group = "Debug" },
	{ "<leader>md", desc = "Toggle debugger" },

	-- LSP actions
	{ "<leader>k", desc = "Hover documentation (LSP)" },
	{ "<leader>r", desc = "Rename symbol (LSP)" },

	-- Files
	{ "<leader>f", group = "Files" },
	{ "<leader>ff", desc = "Format buffer" },
	{ "<leader>fc", desc = "Copy file path" },
	{ "<leader>fD", desc = "Delete buffer contents" },
	{ "<leader>fR", desc = "Rename file (LSP)" },

	-- Git (main group defined in lua/jorge/git.lua)
	-- Git hunks (gitsigns) - buffer-local, defined per-buffer
	{ "<leader>h", group = "Git Hunks" },

	-- Obsidian
	{ "<leader>o", group = "Obsidian" },

	-- Project / Find
	{ "<leader>p", group = "Project" },
	{ "<leader>pf", desc = "Find files (incl. hidden)" },
	{ "<leader>ps", desc = "Workspace symbols" },
	{ "<leader>pv", desc = "Open file explorer (Oil)" },

	-- Search
	{ "<leader>s", desc = "Document symbols" },
	{ "<leader>/", desc = "Live grep in project" },
	{ "<leader>*", desc = "Grep word under cursor" },

	-- Tabs
	{ "<leader>t", group = "Tabs" },

	-- Theme
	{ "<leader>T", group = "Theme" },
	{ "<leader>Tt", desc = "Theme picker" },

	-- Windows
	{ "<leader>w", group = "Windows" },
	{ "<leader>wf", group = "Workflow Files" },

	-- Yank to system clipboard
	{ "<leader>y", desc = "Yank to clipboard" },
	{ "<leader>Y", desc = "Yank line to clipboard" },

	-- Terminal
	{ "<leader>$", desc = "Open terminal" },

	-- Undo tree
	{ "<leader>u", desc = "Toggle undo tree" },

	-- Additional top-level bindings
	{ "<C-p>", desc = "Find git files" },
	{ "<C-h>", desc = "Signature help (LSP)", mode = "i" },
	{ "gd", desc = "Go to definition" },
	{ "gr", desc = "Go to references" },
	{ "gi", desc = "Go to implementations" },
})
