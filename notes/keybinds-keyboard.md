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
| `PageUp` | Enter copy mode and scroll up |

### With prefix (`Ctrl+b` then...)
| Key | Action |
|---|---|
| `r` | Reload config |
| `c` | New window (prompts for name, in current path) |
| `t` | Floating terminal popup (in current path) |
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
