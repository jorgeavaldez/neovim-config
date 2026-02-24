PREF = {
	common = {
		textwidth = 0,
		tabwidth = 4,
	},
	lsp = {
		format_on_save = false,
		virtual_text = true,
		show_signature_on_insert = false,
		show_diagnostic = true,
		-- Use take_over_mode for vue projects or not
		-- tom_enable = true,
	},
	ui = {
		colorscheme = "catppuccin-latte",
		background = "light",
		italic_comment = true,
	},
	git = {
		show_blame = false,
		show_signcolumn = true,
	},
}

local tabwidth = PREF.common.tabwidth

local options = {
	-- ==========================================================================
	-- Indents, spaces, tabulation
	-- ==========================================================================
	expandtab = true,
	cindent = true,
	smarttab = true,
	smartindent = true,
	shiftwidth = tabwidth,
	tabstop = tabwidth,
	softtabstop = tabwidth,
	-- ==========================================================================
	-- UI
	-- ==========================================================================
	number = true,
	relativenumber = true,
	signcolumn = "yes",
	-- colorcolumn = "80",
	-- background = PREF.ui.background,
	-- colorscheme = "vim",
	-- ==========================================================================
	-- Text
	-- ==========================================================================
	textwidth = PREF.common.textwidth,
	wrap = true,
	linebreak = true,
	-- ==========================================================================
	-- Search
	-- ==========================================================================
	ignorecase = true,
	smartcase = true,
	hlsearch = true,
	incsearch = true,
	infercase = true,
	grepprg = "rg --vimgrep",
	-- ==========================================================================
	-- Other
	-- ==========================================================================
	updatetime = 50,
	undofile = true,
	splitright = true,
	splitbelow = true,
	mouse = "a",
	clipboard = "unnamedplus",
	backup = false,
	swapfile = false,
	completeopt = { "menuone", "noselect" },
	-- winbar = ' ',
	spell = false,
	spelllang = "en_us",
	termguicolors = true,
	scrolloff = 8,
	conceallevel = 2,
	-- avante?
	laststatus = 3,
}

for option_name, value in pairs(options) do
	vim.opt[option_name] = value
end

if not vim.g.colors_name then
	pcall(vim.cmd.colorscheme, "vim")
end
-- vim.cmd.colorscheme("catppuccin-latte")
-- vim.wo.foldmethod = 'expr';
-- vim.wo.foldexpr = 'nvim_treesitter#foldexpr()';
-- vim.wo.foldenable = false;

--[[
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = { "*" },
    command = "normal zx zR",
})
--]]

if vim.g.neovide then
	vim.g.neovide_scale_factor = 1.0
	vim.o.guifont = "JetBrains Mono:h13"

	vim.g.neovide_cursor_animation_length = 0
	vim.g.neovide_scroll_animation_length = 0.05

	-- it adds weird shadows to menus
	vim.g.neovide_floating_shadow = false
	vim.g.neovide_floating_z_height = 1
	vim.g.neovide_light_angle_degrees = 30
	vim.g.neovide_light_radius = 10

	-- border radius
	vim.g.neovide_floating_corner_radius = 0.1

	-- neovide doesn't set copy/paste by default :(
	local function save()
		vim.cmd.write()
	end
	local function copy()
		vim.cmd([[normal! "+y]])
	end
	local function paste()
		vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
	end

	vim.keymap.set({ "n", "i", "v" }, "<D-s>", save, { desc = "Save" })
	vim.keymap.set("v", "<D-c>", copy, { silent = true, desc = "Copy" })
	vim.keymap.set({ "n", "i", "v", "c", "t" }, "<D-v>", paste, { silent = true, desc = "Paste" })
end
