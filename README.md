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
  - `lsp.lua` — lspconfig, mason, cmp, conform.nvim, nvim-lint, fidget, go.nvim, typescript-tools
  - `ui.lua` — oil, which-key, trouble, builtin undotree, surround, dropbar, render-markdown
  - `vcs.lua` — jj.nvim, hunk.nvim, jjsigns.nvim, telescope-jj, jj-diffconflicts
  - `extras.lua` — debugging, obsidian, orgmode, AI tools, overseer, zig, sidekick
- `after/plugin/` — post-plugin configuration overrides

## notes

this config supports both obsidian markdown notes and org files.

- `<leader>o` is the notes namespace in which-key
- `<leader>oa` opens org agenda
- `<leader>oc` opens org capture
- org files are loaded from `~/org` (fallback: `~/orgfiles`)
- default org inbox file: `~/org/inbox.org` (or fallback dir equivalent)

## astro

- `.astro` files use the Astro language server for completion, diagnostics, hover, navigation, rename, and code actions.
- Treesitter installs Astro and its embedded TypeScript, JavaScript, and CSS parsers on first open. Neovim supplies
  file detection and indentation; nvim-ts-autotag supplies tag closing/renaming. Existing Tailwind support includes Astro.
- On a new machine, run `:MasonInstall astro-language-server prettier` (Node.js is required; parser installation also
  needs the `tree-sitter` CLI and a C compiler).
- Install the project's dependencies before editing: the language server resolves TypeScript from the project's
  `node_modules`. If TypeScript is missing, install a compatible version (`typescript@~6`; the language server
  currently needs the JavaScript-based TypeScript SDK, not TypeScript 7).
- `<leader>ff` formats with project-local Prettier when available. Format-on-save remains disabled.

For formatting, install these in the Astro project using its package manager (npm example):

```sh
npm install --save-dev --save-exact prettier prettier-plugin-astro
```

Merge this into the project's Prettier configuration:

```json
{
  "plugins": ["prettier-plugin-astro"],
  "overrides": [
    { "files": "*.astro", "options": { "parser": "astro" } }
  ]
}
```

If using `prettier-plugin-tailwindcss`, keep it last in the `plugins` array.
See the [Astro editor setup guide](https://docs.astro.build/en/editor-setup/).

## version control

i use [jujutsu (jj)](https://github.com/jj-vcs/jj) instead of raw git. the neovim integration includes:

- **jj.nvim** for log, status, describe, commit, rebase, bookmarks, push
- **hunk.nvim** as the diff editor for `jj split` / `jj squash -i`
- **jj-diffconflicts** as the default merge tool for `jj resolve`
- **jjsigns.nvim** for gutter change indicators

see `JJ_WORKFLOW.md` for the full workflow reference.

## pi external editor rpc
pi external editing is wired to the host nvim instance (when pi is launched from `:terminal`).

- wrapper: `bin/pi-nvim-editor`
- host rpc module: `lua/jorge/pi_edit_rpc.lua`
- runbook/troubleshooting: `PI_NVIM_RPC.md`

if host rpc is unavailable (`$NVIM` missing/stale), the wrapper falls back to local nvim.

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
