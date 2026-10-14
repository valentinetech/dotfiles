# Keybinds

## tmux

Prefix: `Ctrl+b`

### Global (no prefix)
| Key | Action |
|---|---|
| `F5` | Split horizontally (side by side), in current path |
| `F6` | Split vertically (top/bottom), in current path |
| `F7` | Kill current pane |
| `F8` | Session switcher (`choose-tree -Zs`) |
| `F9` | New session (prompts for name) |
| `F10` | GitHub PR dashboard popup (gh-dash, all repos; `q` to close) |
| `PageUp` | Enter copy mode and scroll up |

### With prefix (`Ctrl+b` then...)
| Key | Action |
|---|---|
| `r` | Reload config |
| `c` | New window (prompts for name, in current path) |
| `t` | Floating terminal popup (in current path) |
| `p` / `n` | Previous / next window (tmux defaults) |
| `h` / `j` / `k` / `l` | Resize pane left/down/up/right (repeatable, 5 cells) |
| `m` | Maximize/zoom pane |

### Choose-tree mode (inside `F8` session switcher)
| Key | Action |
|---|---|
| `r` | Rename session (prompt) |
| `d` | Kill session (with confirm) |

### Copy mode (vi-style, entered via prefix + `[`)
| Key | Action |
|---|---|
| `v` | Begin selection |
| `y` | Copy selection to clipboard (trims trailing whitespace) |
| mouse drag-end | Copy to clipboard |
| `Escape` | Cancel copy mode |
| `PageUp` / `PageDown` | Scroll |

Notes: mouse support is on. Old bindings unbound: `C-M-h/j/k/l/Left/Down/Up/Right`, `C-M-q`, `C-Space`.

---

## gh-dash (F10 popup)

Starts with the preview open at the bottom (keep it that way: starting hidden leaves no row selected until the cursor moves).

### Navigation
Arrows drive the table, hjkl drives the preview.

| Key | Action |
|---|---|
| `←` / `→` | Previous / next section tab (Mine, Mine draft, Mine needs approval, Review hpanel, Review other, Reviewed by me). Review sections only show PRs where I'm requested by name (not via a team), dex-review has reviewed, and no human has approved yet. Reviewed by me = open PRs where I approved, requested changes or left a review comment (plain conversation comments don't count) |
| `↑` / `↓` | Previous / next PR row |
| `g` / `G` | First / last PR |
| `p` | Hide / show the preview (full-width table while hidden) |
| `h` / `l` | Previous / next preview tab (Overview, Activity, Commits, Checks, Files Changed) |
| `k` / `j` | Page the preview up / down |
| `e` | Expand the PR description |
| `/` | Edit the section filter (Enter applies) |
| `t` | Toggle smart filtering (scope section to the repo gh-dash was opened from) |
| `s` | Switch between PRs and Issues views |
| `r` / `R` | Refresh section / refresh all |
| `?` | Help |
| `q` / `F10` | Close |

### Selected PR
| Key | Action |
|---|---|
| `o` | Open in GitHub |
| `P` | Pick a link from the PR comments with fzf and open it |
| `F` | Pick a failing check with fzf and open its log |
| `L` | Edit labels with fzf (Tab toggles, Enter applies) |
| `S` | Open the PR's Actions runs in gh-enhance (jobs, steps, logs; `h`/`l` panes, `Ctrl+r` reruns failed; `q` or `Ctrl+c` back, built by `gh-dash/build-gh-enhance.sh`) |
| `C` / `Space` | Check out the branch in a new tmux window |
| `w` | Watch checks, notify when done |
| `d` | Full-screen diff in diffnav (patched build from `gh-dash/build-diffnav.sh`): `↑`/`↓` prev/next file, `j`/`k` scroll diff one line, `J`/`K` half page, `h`/`l` collapse/expand folder, `t` find file, `/` search diff, `q` back. Read-only: to comment, use `c` in gh-dash or `o` and comment on GitHub |
| `c` | Comment |
| `v` | Approve: asks `y/N`, no comment prompt (`r` refreshes the row) |
| `V` | Approve all workflow runs |
| `W` | Mark ready for review |
| `u` | Update from base branch |
| `m` | Merge |
| `x` / `X` | Close / reopen |
| `a` / `A` | Assign / unassign |
| `y` / `Y` | Copy PR number / URL |

### Inside fzf pickers (`P`, `F`, `L`)
| Key | Action |
|---|---|
| type | Filter |
| `↑` / `↓`, `Ctrl+k` / `Ctrl+j` | Move |
| `Tab` | Toggle selection (labels only) |
| `Enter` | Confirm |
| `Esc` | Cancel |

---

## Neovim

Leader: `Space`

### Navigation
| Key | Action |
|---|---|
| `Ctrl+h/j/k/l` | Navigate splits/tmux panes (vim-tmux-navigator) |
| `Ctrl+d` / `Ctrl+u` | Half page down/up, centered |
| `n` / `N` | Next/prev search result, centered |
| `Alt+h` | Vertical split (side by side) |
| `Alt+l` | Horizontal split (top/bottom) |
| `Alt+Left/Right` | Decrease/increase split width |
| `Alt+Up/Down` | Decrease/increase split height |
| `Ctrl+q` | Close split |

### Buffers
| Key | Action |
|---|---|
| `<leader>q` | Close buffer (switches to another buffer first) |
| `<leader>b` | Previous buffer (`Ctrl+^`) |
| `Shift+h` | Previous buffer |
| `Shift+l` | Next buffer |

### Editing
| Key | Action |
|---|---|
| `<leader>w` | Save + async lint/format (conform) |
| `J` (visual) | Move selection down |
| `K` (visual) | Move selection up |
| `Shift+j` (normal) | Move line down |
| `Shift+k` (normal) | Move line up |
| `Alt+j` | Duplicate line/selection down |
| `Alt+k` | Duplicate line/selection up |
| `<` / `>` (visual) | Indent left/right, reselect |
| `o` / `O` | New line below/above without auto-comment |
| `x` | Delete char without yanking |
| `<leader>d` | Delete without yanking |
| `<leader>p` (visual) | Paste without overwriting register |
| `p` (visual) | Paste without overwriting register |

### Clipboard
| Key | Action |
|---|---|
| `<leader>y` | Copy to system clipboard |
| `<leader>Y` | Copy line to system clipboard |

(System clipboard is also default via `clipboard=unnamedplus`)

### Diagnostics
| Key | Action |
|---|---|
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>d` | Show diagnostic float |
| `<leader><` | Previous error only |
| `<leader>>` | Next error only |

### Misc
| Key | Action |
|---|---|
| `Esc` | Clear search highlights |
| `Alt+Backspace` (insert) | Delete word backward (Mac behavior) |
| `q` (in Lazy window) | Close Lazy |
