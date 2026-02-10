# CLAUDE.md / AGENT.md / AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) and other AI Agents when working with code in this repository.

## Architecture Overview

This is a personal Neovim configuration built with Lua, focused on simplicity and speed. The config is structured in a modular way:

- **Entry point**: `init.lua` → loads `lua/jorge/init.lua`
- **Core modules**: All configuration lives in `lua/jorge/` directory
- **Plugin specs**: Organized by category in `lua/plugins/` (lazy.nvim auto-imports the directory)
- **Package management**: Uses lazy.nvim with automatic installation

### Key Configuration Files

- `lua/jorge/init.lua` - Main module loader (options, remaps, commands, lazy, jj, wf, breadcrumbs)
- `lua/jorge/lazy.lua` - lazy.nvim bootstrap and setup (imports `lua/plugins/` specs)
- `lua/jorge/options.lua` - Neovim options and preferences (via `PREF` global table)
- `lua/jorge/remap.lua` - Key mappings and leader key setup
- `lua/jorge/commands.lua` - Custom commands and utility functions
- `lua/jorge/jj.lua` - Jujutsu (jj) workflow keymaps and commands
- `lua/jorge/wf.lua` - WF workflow manager integration
- `lua/jorge/lsp.lua` - LSP configuration, completion, formatters
- `lua/jorge/breadcrumbs.lua` - Breadcrumb trail for visited files
- `after/plugin/colors.lua` - Color scheme overrides (mostly commented out)

### Plugin Specs (`lua/plugins/`)

Plugin specifications are split into category files that lazy.nvim auto-imports:

- `lua/plugins/colors.lua` - Color scheme (catppuccin, auto-dark-mode)
- `lua/plugins/search.lua` - Telescope, Treesitter, textobjects, autotag
- `lua/plugins/lsp.lua` - LSP ecosystem (lspconfig, mason, cmp, none-ls, lspsaga, fidget, go.nvim, typescript-tools)
- `lua/plugins/ui.lua` - UI plugins (oil, which-key, trouble, undotree, surround, mini.cmdline, render-markdown, dropbar)
- `lua/plugins/vcs.lua` - Version control (jj.nvim, hunk.nvim, jjsigns.nvim, telescope-jj.nvim, jj-diffconflicts)
- `lua/plugins/extras.lua` - Everything else (debugging, obsidian, AI tools, overseer, zig, sidekick)

## Plugin Management

Uses **lazy.nvim** as the plugin manager. Specs are defined in `lua/plugins/*.lua` and auto-imported. The old monolithic `lua/jorge/lazy.lua` now just bootstraps lazy.nvim and points it at the `plugins` spec directory.

### VCS Plugins (Jujutsu-first)
- **jj.nvim**: Main jj interface — log, status, describe, commit, rebase, bookmarks, push, annotate
- **hunk.nvim**: Interactive diff-editor for `jj split`, `jj squash -i`, etc.
- **jjsigns.nvim**: Gutter signs showing changes vs parent revision
- **telescope-jj.nvim**: Telescope picker for jj files
- **jj-diffconflicts**: Conflict resolution merge tool for `jj resolve`

### Search & Navigation
- **Telescope**: File finder, grep, LSP navigation, buffer picker, command palette
- **Treesitter**: Syntax highlighting, textobjects, autotag

### LSP & Completion
- **nvim-lspconfig**: Core LSP client (configured in `lua/jorge/lsp.lua`)
- **mason.nvim + mason-lspconfig**: LSP server management
- **nvim-cmp**: Autocompletion with LuaSnip, lspkind, codeium
- **none-ls**: Formatters and linters (biome, djhtml, prettier, yamlfmt, sqlfmt, shfmt)
- **lspsaga**: Enhanced LSP UI
- **fidget.nvim**: LSP progress notifications
- **go.nvim**: Go development
- **typescript-tools.nvim**: TypeScript/JavaScript development

### UI
- **Oil.nvim**: File explorer (mapped to `<leader>pv`)
- **Which-key**: Key binding help and organization
- **Trouble**: Diagnostics and quickfix list
- **Undotree**: Undo history visualization
- **Dropbar**: Breadcrumb/winbar navigation
- **render-markdown**: Markdown rendering
- **mini.cmdline**: Enhanced command line

### Color Scheme
- **Catppuccin**: With auto-dark-mode switching between latte (light) and mocha (dark)

### AI & Coding Assistants
- **Sidekick.nvim**: Terminal-based AI assistant integration (claude, opencode, codex)
- **Windsurf/Codeium**: AI code completion (active)
- **Codecompanion**: AI chat interface (disabled)
- **Supermaven**: AI completion (disabled)
- **Avante**: AI editing assistant (disabled)

### Extras
- **nvim-dap + dap-ui**: Debugging (Python via debugpy)
- **Obsidian.nvim**: Note-taking vault integration (`~/obsidian/delvaze`)
- **Overseer**: Task runner
- **zig.vim**: Zig language support

## Development Workflow Commands

### File Operations
- `<leader>pf` - Find files (includes hidden, excludes .git/.jj)
- `<C-p>` - Find files via jj (falls back to git)
- `<leader>/` - Live grep across project
- `<leader>*` - Grep word under cursor
- `<leader>pv` - Open file explorer (Oil)
- `<leader>fc` - Copy relative file path
- `<leader>fC` - Copy absolute file path
- `<leader>fR` - Rename file (LSP)

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

### JJ (Jujutsu) Workflow
All keymaps are dual-bound to `<leader>g*` and `<leader>j*`:

| Keymap | Command | Description |
|--------|---------|-------------|
| `<leader>gg` / `<leader>jj` | `:J log` | Log view (home base) |
| `<leader>gs` / `<leader>js` | `:J st` | Status (changed files) |
| `<leader>gc` / `<leader>jc` | `:J commit` | Commit (describe + new) |
| `<leader>gd` / `<leader>jd` | `:J desc` | Describe current change |
| `<leader>gD` / `<leader>jD` | `:Jdiff` | Diff current file vs parent |
| `<leader>gb` / `<leader>jb` | `:J annotate` | Annotate (blame) |
| `<leader>gp` / `<leader>jp` | `:J git push` | Push to remote |
| `<leader>gf` / `<leader>jf` | `:J git fetch` | Fetch from remote |
| `<leader>gn` / `<leader>jn` | `:J new` | New empty change |
| `<leader>gu` / `<leader>ju` | `:J undo` | Undo last operation |
| `<leader>gB` / `<leader>jB` | `:J bookmark create ` | Create bookmark |
| `<leader>gl` / `<leader>jl` | `:J log` | Log alias |

See `JJ_WORKFLOW.md` for full workflow documentation including log buffer keys and conflict resolution.

### LSP Operations
- `<leader>k` - Hover documentation
- `<leader>d` - Open diagnostic float
- `<leader>ca` - Code actions
- `<leader>r` - Rename symbol
- `<leader>ff` - Format buffer
- `gr` - Go to references (Telescope)
- `gd` - Go to definition
- `gi` - Go to implementations (Telescope)
- `gR` - Trouble references
- `<C-h>` (insert mode) - Signature help
- `<leader>s` - Document symbols
- `<leader>ps` - Workspace symbols

### Window/Buffer/Tab Management
- `<leader>w*` - Window operations (split, navigate, maximize, etc.)
- `<leader>b*` - Buffer operations (close, navigate)
- `<leader>t*` - Tab operations (next, previous)
- `<leader>bb` - List buffers (Telescope)
- `<leader>bd` - Close buffer

### AI Assistants
- `<leader>ac` - Toggle Claude (Sidekick)
- `<leader>ai` / `<leader>ao` - Toggle OpenCode (Sidekick)
- `<leader>ag` - Toggle Codex (Sidekick)
- `<leader>ap` - Sidekick prompt

### WF Workflow Manager
- `<leader>wfp` - Add current file as wf prompt
- `<leader>wfa` - Add current file as wf artifact
- `<leader>wfl` - List recently added wf files in quickfix

### Other
- `<leader>u` - Toggle undo tree
- `<leader><leader>` - Command palette (Telescope)
- `<leader>?` - Search keymaps
- `<leader>Tt` - Theme picker
- `<leader>$` - Open terminal
- `<leader>id` - Insert date (YYYY-MM-DD)
- `<leader>it` - Insert time (HH:MM)

## Language Support

### Configured LSP Servers (via mason-lspconfig)
- **TypeScript/JavaScript**: typescript-tools.nvim (ts_ls excluded from mason auto-enable)
- **Python**: pyright + ruff (ruff hover disabled in favor of pyright)
- **Go**: gopls + ray-x/go.nvim (gopls excluded from mason auto-enable, managed by go.nvim)
- **Rust**: rust_analyzer
- **Lua**: lua_ls with lazydev for Neovim API
- **Web**: tailwindcss, eslint, html (with templ support), biome
- **Shell**: bashls
- **Terraform**: terraformls
- **Zig**: zls (with semantic_tokens = "partial")

### Formatters (via none-ls)
- **Web**: Biome (JS/TS/JSON), Prettier (Markdown only)
- **Python**: Handled by ruff LSP
- **Templates**: djhtml, djlint
- **YAML**: yamlfmt (+ yamllint diagnostics)
- **SQL**: sqlfmt
- **Shell**: shfmt

## Custom Features

### Project Root Detection
- `GetProjectRoot` command - Tries jj root first, falls back to git root, then cwd
- Defined in `lua/jorge/commands.lua`

### Search Configuration
- ripgrep as default grep program
- Hidden files shown in Telescope but respects gitignore
- `.jj` directories excluded alongside `.git`
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

## Important Notes

### Preferences (from options.lua)
- **Tabwidth**: 4 spaces
- **Textwidth**: 0 (no hard wrap)
- **Theme**: catppuccin with auto-dark-mode (latte/mocha)
- **Format on save**: Disabled by default
- **Virtual text diagnostics**: Enabled
- **Clipboard**: unnamedplus (system clipboard)
- **Scrolloff**: 8
- **Split**: right and below

### No Build/Test Commands
This is a Neovim configuration, not a project with build/test steps. The configuration is loaded when Neovim starts.

### Debugging
- Uses nvim-dap for debugging support
- Python debugging configured via nvim-dap-python (debugpy)
- dap-ui for debugging interface
- Toggle with `<leader>md`

### Plugin Installation
Plugins are managed by lazy.nvim and install automatically on first load. No manual build steps required.
