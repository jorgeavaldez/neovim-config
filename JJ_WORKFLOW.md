# JJ (Jujutsu) Workflow in Neovim

## Plugins

- **jj.nvim** — Main interface: log, status, describe, commit, rebase, bookmarks, push, annotate
- **hunk.nvim** — Interactive diff-editor for `jj split`, `jj squash -i`, etc.
- **jjsigns.nvim** — Gutter signs showing changes vs parent revision
- **telescope-jj.nvim** — Telescope picker for jj files, diffs, conflicts
- **jj-diffconflicts** — Conflict resolution merge tool for `jj resolve`

## Core Keymaps (dual-bound: `<leader>g*` and `<leader>j*`)

| Keymap | Command | Description |
|--------|---------|-------------|
| `<leader>gg` / `<leader>jj` | `:J log` | **Home base** — log view |
| `<leader>gs` / `<leader>js` | `:J st` | Status (changed files) |
| `<leader>gc` / `<leader>jc` | `:J commit` | Describe current change + create new |
| `<leader>gd` / `<leader>jd` | `:J desc` | Describe current change only |
| `<leader>gD` / `<leader>jD` | `:Jdiff` | Diff current file vs parent |
| `<leader>gb` / `<leader>jb` | `:J annotate` | Blame/annotate file |
| `<leader>gp` / `<leader>jp` | `:J git push` | Push to remote |
| `<leader>gf` / `<leader>jf` | `:J git fetch` | Fetch from remote |
| `<leader>gn` / `<leader>jn` | `:J new` | New empty change on top |
| `<leader>gu` / `<leader>ju` | `:J undo` | Undo last operation |
| `<leader>gB` / `<leader>jB` | `:J bookmark create ` | Create bookmark (prompts for name) |
| `<leader>gl` / `<leader>jl` | `:J log` | Log alias |

## Telescope

| Keymap | Description |
|--------|-------------|
| `<C-p>` | Find files in jj repo (falls back to git) |

## Log Buffer Keys (built into jj.nvim)

The log is your command center. Open it with `<leader>gg` or `<leader>jj`.

| Key | Action |
|-----|--------|
| `d` | Diff the change under cursor |
| `<CR>` | Edit a mutable change (switch to it) |
| `<S-CR>` | Edit an immutable change |
| `n` | New change branching off cursor |
| `<C-n>` | New change after cursor |
| `r` | Interactive rebase mode |
| `s` | Squash mode |
| `<S-s>` | Quick squash into parent |
| `b` | Create/move bookmark |
| `p` | Push bookmark of cursor revision |
| `<S-p>` | Push all to remote |
| `f` | Fetch from remote |
| `a` | Abandon change |
| `<S-u>` | Undo |
| `<S-r>` | Redo |
| `<S-k>` | Preview change summary tooltip |
| `o` | Open PR/MR |

## Status Buffer Keys

| Key | Action |
|-----|--------|
| `<CR>` | Open changed file |
| `<S-x>` | Restore file (discard changes) |

## Hunk.nvim (Diff Editor)

Used automatically when jj needs a diff editor (`jj split`, `jj squash -i`).

| Key | Action |
|-----|--------|
| `a` | Toggle line selection |
| `A` | Toggle hunk selection |
| `s` | Toggle line pair (both sides) |
| `[h` / `]h` | Navigate between hunks |
| `<Tab>` | Jump between left/right diff |
| `<leader>e` | Focus file tree |
| `<leader><CR>` | Accept selection |
| `q` | Quit/abort (no changes written) |
| `g?` | Help |

## Conflict Resolution (jj-diffconflicts)

Configured as the **default merge tool** in jj. When conflicts exist after a rebase or merge, `jj resolve` automatically opens Neovim with a two-way diff interface.

### How It Works

1. **Tab 1 — Two-way diff**: Shows the two conflicting sides. Edit the **left side** to produce the desired result.
2. **Tab 2 — History view**: A 3-way diff between both sides and their common ancestor, for context on how the sides diverged.

### Usage

```bash
# Resolve all conflicted files (uses diffconflicts by default)
jj resolve

# Resolve a specific file
jj resolve path/to/file.rs
```

### Controls

| Action | Key |
|--------|-----|
| Save and accept resolution | `:qa` |
| Abort without resolving | `:cq` |
| Switch to history tab | `gt` |
| Switch back to merge tab | `gT` |

### Can Also Be Used Inside Neovim

If you have a buffer with jj conflict markers, you can invoke `:JJDiffConflicts` directly.

## JJ Config

Located at `~/.config/jj/config.toml` (symlinked from `~/dots/jj/config.toml`):

```toml
[ui]
diff-editor = ["nvim", "-c", "DiffEditor $left $right $output"]
merge-editor = "diffconflicts"

[merge-tools.diffconflicts]
program = "nvim"
merge-args = [
  "-c", "let g:jj_diffconflicts_marker_length=$marker_length",
  "-c", "JJDiffConflicts!",
  "$output", "$base", "$left", "$right",
]
merge-tool-edits-conflict-markers = true
```

- **diff-editor**: Uses hunk.nvim for interactive diff editing (`jj split`, etc.)
- **merge-editor**: Uses jj-diffconflicts for conflict resolution (`jj resolve`)

## Common Workflows

### "What's going on?"
`<leader>gg` → browse log → `d` on any change to see its diff

### "I'm done with this change"
`<leader>gc` → editor opens for description → save & close → new empty change created

### "Just add/edit a message"
`<leader>gd` → editor opens → save & close → keep working in same change

### "Push my work"
`<leader>gp` — or from log: `<S-p>` to push all, `p` to push specific bookmark

### "Who wrote this?"
`<leader>gb` → annotate view → `:q` when done

### "Create a bookmark"
`<leader>gB` → type name → enter. Or from log: `b` on a change.

### "Switch to another change"
`<leader>gg` → navigate to change → `<CR>` to edit it

### "Split this change into two"
CLI: `jj split` → hunk.nvim opens → select hunks with `a`/`A` → `<leader><CR>` to accept

### "Rebase a change"
`<leader>gg` → navigate to change → `r` → move cursor to destination → `<CR>`

### "Resolve conflicts after rebase"
`jj resolve` → Neovim opens with two-way diff → edit left side → `:qa` to save

### "Undo a mistake"
`<leader>gu` — or from log: `<S-u>`

### "See changed files"
`<leader>gs` → status view → `<CR>` to open file, `<S-x>` to restore

### "Diff current file"
`<leader>gD` → split diff view against parent revision

## Key Differences from Git

- **No staging**: Every save is part of the current change. Use `jj split` to separate changes.
- **Rebasing is instant**: No "rebase in progress" state. Conflicts are recorded, resolve at leisure.
- **Branches → Bookmarks**: Bookmarks are lightweight labels, not branches.
- **The log is everything**: Status, diff, rebase, squash, push — all from the log buffer.
- **`jj undo` is magic**: Almost anything can be undone.
