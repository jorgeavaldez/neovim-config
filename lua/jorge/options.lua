PREF = {
  common = {
    textwidth = 120,
    tabwidth = 4,
  },

  lsp = {
    format_on_save = false,
    virtual_text = false,
    show_signature_on_insert = false,
    show_diagnostic = true,
    -- Use take_over_mode for vue projects or not
    -- tom_enable = true,
  },

  ui = {
    -- colorscheme = 'tokyonight',
    background = "dark",
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
  background = PREF.ui.background,

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
  grepprg = 'rg --vimgrep',

  -- ==========================================================================
  -- Other
  -- ==========================================================================
  updatetime = 50,
  undofile = true,
  splitright = true,
  splitbelow = true,
  mouse = 'a',
  clipboard = 'unnamedplus',
  backup = false,
  swapfile = false,
  completeopt = { 'menuone', 'noselect' },
  winbar = ' ',
  spell = false,
  spelllang = 'en_us',
  termguicolors = true,
  scrolloff = 8,
}

for option_name, value in pairs(options) do
  vim.opt[option_name] = value
end

