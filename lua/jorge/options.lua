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

-- Nvim's automatic OSC 52 detection is intentionally bypassed when 'clipboard'
-- is set. Since this config sets unnamedplus below, force OSC 52 copy only for
-- SSH sessions so "+ operations work without xclip (for example, Termius into
-- tmux). Do not infer this from missing DISPLAY/WAYLAND_DISPLAY: local macOS
-- terminals like WezTerm do not set those, and should use Nvim's native
-- pbcopy/pbpaste provider instead. Pasting uses a local cache to avoid hanging
-- on terminals that do not answer OSC 52 reads.
local use_osc52_clipboard = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
if use_osc52_clipboard and vim.g.clipboard == nil then
	local osc52 = require("vim.ui.clipboard.osc52")
	local cache = {
		["+"] = { {}, "v" },
		["*"] = { {}, "v" },
	}

	local function copy(reg)
		local osc52_copy = osc52.copy(reg)
		return function(lines, regtype)
			cache[reg] = { lines, regtype }
			osc52_copy(lines)
		end
	end

	local function paste(reg)
		return function()
			return cache[reg]
		end
	end

	vim.g.clipboard = {
		name = "OSC 52 (copy only)",
		copy = {
			["+"] = copy("+"),
			["*"] = copy("*"),
		},
		paste = {
			["+"] = paste("+"),
			["*"] = paste("*"),
		},
		cache_enabled = 0,
	}
end

-- ==========================================================================
-- Indents, spaces, tabulation
-- ==========================================================================
vim.opt.expandtab = true
vim.opt.cindent = true
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.shiftwidth = tabwidth
vim.opt.tabstop = tabwidth
vim.opt.softtabstop = tabwidth
-- ==========================================================================
-- UI
-- ==========================================================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
-- colorcolumn = "80",
-- background = PREF.ui.background,
-- colorscheme = "vim",
-- ==========================================================================
-- Text
-- ==========================================================================
vim.opt.textwidth = PREF.common.textwidth
vim.opt.wrap = true
vim.opt.linebreak = true
-- ==========================================================================
-- Search
-- ==========================================================================
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.infercase = true
vim.opt.grepprg = "rg --vimgrep"
-- ==========================================================================
-- Other
-- ==========================================================================
vim.opt.updatetime = 50
vim.opt.undofile = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.completeopt = { "menuone", "noselect" }
-- winbar = ' ',
vim.opt.spell = false
vim.opt.spelllang = "en_us"
vim.opt.termguicolors = false -- Use terminal colors until Catppuccin enables truecolor.
vim.opt.scrolloff = 8
vim.opt.conceallevel = 2
-- avante?
vim.opt.laststatus = 3

if not vim.g.colors_name then
	pcall(vim.cmd.colorscheme, "default")
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
	vim.o.guifont = "Consolas:h13"

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
