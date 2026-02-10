# jorge's neovim configs
this is my attempt at coming back from helix and spacemacs 

most of the bindings in helix are just so damn good. but vim is more widely supported and i'd rather get back the muscle
memory.

there's a lot that's missing of course since i'm a noob. this is also my first time dealing with lua configs.

## mantra
i prefer simplicity and speed over anything else. yeah maybe some of the choices here are debatable but this is my
config and i can do what i want.

i'm also learning, and i'm not sure i have a good understanding of everything yet. but we're experimenting so whatever.

## structure

- `init.lua` → `lua/jorge/init.lua` — entry point, loads all core modules
- `lua/jorge/` — core config (options, remaps, commands, lsp, jj workflow, breadcrumbs, etc.)
- `lua/plugins/` — plugin specs split by category, auto-imported by lazy.nvim
  - `colors.lua` — catppuccin + auto-dark-mode
  - `search.lua` — telescope, treesitter, textobjects
  - `lsp.lua` — lspconfig, mason, cmp, none-ls, lspsaga, go.nvim, typescript-tools
  - `ui.lua` — oil, which-key, trouble, undotree, surround, dropbar, render-markdown
  - `vcs.lua` — jj.nvim, hunk.nvim, jjsigns.nvim, telescope-jj, jj-diffconflicts
  - `extras.lua` — debugging, obsidian, AI tools, overseer, zig, sidekick
- `after/plugin/` — post-plugin configuration overrides

## version control

i use [jujutsu (jj)](https://github.com/jj-vcs/jj) instead of raw git. the neovim integration includes:

- **jj.nvim** for log, status, describe, commit, rebase, bookmarks, push
- **hunk.nvim** as the diff editor for `jj split` / `jj squash -i`
- **jj-diffconflicts** as the default merge tool for `jj resolve`
- **jjsigns.nvim** for gutter change indicators

see `JJ_WORKFLOW.md` for the full workflow reference.

## project files and ripgrep
i made it so ripgrep will show hidden files but also respect gitignore and hide .git and .jj directories.

if you want to also undo stuff gitignore is ignoring, like .env files, make sure to add a .ignore directory with
something like this:

```
!.env
!.env.*
!.env.*.local
```

## todo
- [ ] i set up all the textobject stuff and immediately realized i could have that stuff live in telescope. this todo is
  move everything to telescope
