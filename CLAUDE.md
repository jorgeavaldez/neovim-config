# CLAUDE.md / AGENT.md / AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) and other AI Agents when working with code in this repository.

## Architecture Overview

This is a personal Neovim configuration built with Lua, focused on simplicity and speed. The config is structured in a modular way:

- **Entry point**: `init.lua` → loads `lua/jorge/init.lua`
- **Core modules**: All configuration lives in `lua/jorge/` directory
- **Plugin configs**: Individual plugin configurations in `after/plugin/`
- **Package management**: Uses lazy.nvim with automatic installation

### Key Configuration Files

- `lua/jorge/init.lua` - Main module loader (options, remaps, commands, lazy, git, breadcrumbs)
- `lua/jorge/lazy.lua` - Plugin specifications and lazy.nvim setup
- `lua/jorge/options.lua` - Neovim options and preferences
- `lua/jorge/remap.lua` - Key mappings and leader key setup
- `lua/jorge/commands.lua` - Custom commands and utility functions
- `lua/jorge/git.lua` - Enhanced git workflow integration
- `lua/jorge/breadcrumbs.lua` - Breadcrumb trail for visited files
- `after/plugin/` - Individual plugin configurations loaded after plugins

## Plugin Management

Uses **lazy.nvim** as the plugin manager. All plugins are defined in `lua/jorge/lazy.lua`. Notable plugin categories:

### Core Plugins
- **Telescope**: File finder, grep, LSP navigation (`telescope.nvim`)
- **Treesitter**: Syntax highlighting and parsing (`nvim-treesitter`)
- **LSP**: Language server integration (`nvim-lspconfig`, `mason.nvim`)
- **Git**: Fugitive, Gitsigns, Diffview for enhanced git workflows

### Key Features
- **Oil.nvim**: File explorer (mapped to `<leader>pv`)
- **Which-key**: Key binding help and organization
- **Catppuccin Latte**: Color scheme (light theme preference)
- **Auto-completion**: nvim-cmp with LuaSnip and LSP integration

## Development Workflow Commands

### File Operations
- `<leader>pf` - Find files (includes hidden, excludes .git)
- `<C-p>` - Git files
- `<leader>/` - Live grep across project
- `<leader>pv` - Open file explorer (Oil)

### Breadcrumbs
The config includes a breadcrumb trail that maintains a list of visited files in order:

- `<leader>bcs` - Start breadcrumb tracking
- `<leader>bce` - Stop breadcrumb tracking
- `<leader>bct` - Toggle breadcrumb tracking
- `<leader>bcl` - List breadcrumbs (Telescope picker, newest first)
- `<leader>bcy` - Yank all breadcrumbs to clipboard
- `<leader>bcY` - Yank all and clear breadcrumbs
- `<leader>bcD` - Clear all breadcrumbs

**Telescope picker actions:**
- `<CR>` - Yank selected files (or all if none selected)
- `<Esc>` - Yank all files
- `<Tab>` - Multi-select files
- `<C-d>` - Delete file from breadcrumb list

### Git Workflow (Enhanced)
The config includes a sophisticated git workflow integration combining fugitive, diffview, and gitsigns:

- `<leader>gg` - Git status (fugitive)
- `<leader>gd` - Open comprehensive diffview (all changes)
- `<leader>gq` - Smart workflow: diffview if changes exist, status if clean
- `<leader>gs` - Staged changes only
- `<leader>gu` - Unstaged changes only  
- `<leader>gm` - Changes vs origin/main
- `<leader>gc` - Close diffview
- `<leader>gf` - Toggle diffview file panel

### LSP Operations
- `<leader>k` - Hover documentation
- `<leader>d` - Open diagnostic float
- `<leader>ca` - Code actions
- `<leader>r` - Rename symbol
- `gr` - Go to references
- `gd` - Go to definitions
- `gi` - Go to implementations

### Window/Buffer Management
- `<leader>w*` - Window operations (split, navigate, etc.)
- `<leader>b*` - Buffer operations (close, navigate)
- `<leader>t*` - Tab operations

## Language Support

### Configured LSP Servers (via mason-lspconfig)
- **TypeScript**: typescript-tools.nvim (custom setup, ts_ls excluded)
- **Python**: pyright + ruff (ruff hover disabled in favor of pyright)
- **Go**: gopls + ray-x/go.nvim
- **Rust**: rust_analyzer
- **Lua**: lua_ls with lazydev for Neovim API
- **Web**: tailwindcss, eslint, html
- **Shell**: bashls

### Formatters (via null-ls)
- **Web**: Biome (JS/TS/JSON)
- **Python**: Handled by ruff LSP
- **Templates**: djhtml, djlint
- **YAML**: yamlfmt
- **SQL**: sqlfmt
- **Shell**: shfmt

## Custom Features

### Project Root Detection
- `GetProjectRoot` command - Gets git root or falls back to cwd
- Used by mcphub integration for MCP project context

### Git Integration Enhancements
- Custom commands: `:DiffAll`, `:DiffStaged`, `:DiffUnstaged`, `:DiffMain`
- Bridge between fugitive and diffview: `dv` key in fugitive buffers
- Gitsigns integration for hunk-level operations (`]c`/`[c`, `<leader>h*`)

### Search Configuration
- ripgrep as default grep program
- Hidden files shown in telescope but respects gitignore
- Use `.ignore` file to override gitignore for specific files

### Breadcrumbs
- `lua/jorge/breadcrumbs.lua` - Tracks visited files within project
- Maintains ordered list of relative file paths (newest last)
- Automatically removes duplicates by moving revisited files to end
- Only tracks normal editable files (excludes special buffers, terminals, etc.)
- Tracking must be explicitly started with `:BCStart` or `<leader>bcs`
- Provides Telescope UI for viewing, selecting, and yanking file paths
- Supports configurable prefix for yanked paths (default: `@`)
- Commands: `:BCStart`, `:BCStop`, `:BCToggle`, `:BCList`, `:BCYank`, `:BCYankClear`, `:BCClear`, `:BCStatus`, `:BCSetPrefix`, `:BCClearPrefix`, `:BCGetPrefix`

## AI Integration

### Multiple AI Assistants Available
- **Codecompanion**: Primary AI chat interface (Gemini backend)
- **Supermaven**: AI code completion (currently disabled)
- **Avante**: AI editing assistant (currently disabled)  
- **MCPHub**: Model Context Protocol integration for enhanced AI tooling

### Obsidian Integration
- Configured for vault at `~/obsidian/delvaze`
- Custom markdown link handling with `gf`
- Daily notes and templates support

## Important Notes

### Preferences (from options.lua)
- **Tabwidth**: 4 spaces
- **Textwidth**: 120 characters
- **Theme**: catppuccin-latte (light theme)
- **Format on save**: Disabled by default
- **Virtual text diagnostics**: Enabled

### No Build/Test Commands
This is a Neovim configuration, not a project with build/test steps. The configuration is loaded when Neovim starts.

### Debugging
- Uses nvim-dap for debugging support
- Python debugging configured via nvim-dap-python
- dap-ui for debugging interface

### Plugin Installation
Plugins are managed by lazy.nvim and install automatically on first load. No manual build steps required.
