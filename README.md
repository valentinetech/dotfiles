# Dotfiles

Personal configuration files for macOS development environment.

## Setup

### 1. Backup existing configs (optional but recommended)

```bash
mkdir -p ~/config-backup-$(date +%Y%m%d)
cp -r ~/.config/nvim ~/config-backup-$(date +%Y%m%d)/ 2>/dev/null || true
cp ~/.tmux.conf ~/config-backup-$(date +%Y%m%d)/ 2>/dev/null || true
cp ~/.wezterm.lua ~/config-backup-$(date +%Y%m%d)/ 2>/dev/null || true
```

### 2. Remove existing configs

```bash
rm -rf ~/.config/nvim
rm -f ~/.tmux.conf
rm -f ~/.wezterm.lua
```

### 3. Create symlinks

```bash
ln -s ~/Documents/dotfiles/nvim ~/.config/nvim
ln -s ~/Documents/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/Documents/dotfiles/.wezterm.lua ~/.wezterm.lua
```

### 4. Verify symlinks

```bash
ls -la ~/ | grep -E "(tmux|wezterm)"
ls -la ~/.config/ | grep nvim
```

## What's included

- **nvim/** - Neovim config with lazy.nvim
  - Ruff LSP for Python (diagnostics + formatting)
  - Vue/JS/TS support with vtsls + eslint_d
  - Gruvbox theme
- **.tmux.conf** - tmux config with vim-tmux-navigator
- **.wezterm.lua** - WezTerm terminal config

## Requirements

- Neovim 0.11+
- tmux
- WezTerm
- uv (Python package manager)
- Node.js (for Vue/JS/TS LSPs)
