# Git Workflow Migration Summary

## Your Old Fugitive Workflow → New Enhanced Workflow

### **Before (Fugitive):**
- `:Git` → `=` to preview diffs → `<leader>gs` for git status

### **Now (Enhanced):**
- `:Git` → `dv` (new!) to open diffview → or just `<leader>gd` directly

## Core New Commands & Shortcuts

### **Primary Workflow Commands**
| Old Way | New Way | Description |
|---------|---------|-------------|
| `:Git` then `=` | `<leader>gd` | Open comprehensive diff view (all changes) |
| `:Git` | `<leader>gg` | Git status (still fugitive, but enhanced) |
| Multiple steps | `<leader>gq` | Smart workflow: diffview if changes, status if clean |

### **Diffview Navigation & Control**
- `<leader>gd` - Open diffview (shows all: staged + unstaged + untracked)
- `<leader>gc` - Close diffview
- `<leader>gf` - Toggle file panel in diffview
- `<tab>` / `<S-tab>` - Navigate between files in diffview
- `dv` - When in fugitive status, quickly jump to diffview

### **Specific Change Types**
- `<leader>gs` - Staged changes only
- `<leader>gu` - Unstaged changes only  
- `<leader>ga` - All changes (comprehensive)
- `<leader>gm` - Changes vs origin/main

### **File-Level Operations (Gitsigns)**
- `]c` / `[c` - Jump between hunks in current file
- `<leader>hp` - Preview hunk under cursor
- `<leader>hd` - Show diff of current file
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk

## Migration Workflow Examples

### **Scenario 1: "I want to see all my changes"**
```
Old: :Git → = on each file → quit → repeat
New: <leader>gd → <tab>/<S-tab> to navigate all files
```

### **Scenario 2: "Quick status check"**
```
Old: :Git
New: <leader>gq (smart: diffview if changes, status if clean)
```

### **Scenario 3: "From fugitive status to better diff view"**
```
Old: In :Git window → = → limited diff view
New: In :Git window → dv → full diffview experience
```

### **Scenario 4: "Just unstaged changes"**
```
Old: Multiple commands/steps
New: <leader>gu (clean, focused view)
```

## New Custom Commands
- `:DiffAll` - Comprehensive diff view
- `:DiffStaged` - Only staged changes
- `:DiffUnstaged` - Only unstaged changes
- `:DiffMain` - Compare against main branch
- `:GitWorkflow` - Smart git workflow command

## Bridge Features

### **From Fugitive to Diffview:**
- `dv` - When in any fugitive buffer, opens diffview
- `dh` - When in fugitive, shows file history
- `<leader>gv` - Smart bridge (detects context)

## Recommended New Workflow

1. **Daily workflow:** `<leader>gq` (smart git command)
2. **Comprehensive review:** `<leader>gd` (see everything)
3. **Quick file check:** Open file → `]c`/`[c` to jump between changes
4. **Staging workflow:** `<leader>hp` (preview) → `<leader>hs` (stage hunk)
5. **Branch comparison:** `<leader>gm` (vs main)

## Key Improvements Over Old Workflow

✅ **Single command** vs multiple steps  
✅ **Visual file panel** with all change types  
✅ **Modern diff presentation** with syntax highlighting  
✅ **Untracked files** shown alongside modified files  
✅ **Faster navigation** with tab cycling  
✅ **Context preservation** - no losing your place  
✅ **Hunk-level operations** without leaving your file  

**Bottom line:** Replace your `:Git` → `=` workflow with `<leader>gd` for a dramatically better experience!