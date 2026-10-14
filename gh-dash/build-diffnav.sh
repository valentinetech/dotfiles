#!/bin/zsh
# Build diffnav with vim-style keys: j/k scroll the diff one line, arrows move between files.
# diffnav's keys are hard-coded (pkg/ui/keys.go), so this patches the source and builds
# a separate binary at ~/.local/bin/diffnav-vim. gh-dash's `pager.diff` points at it.
# Re-run to pick up a newer diffnav release.

set -euo pipefail

src=${DIFFNAV_SRC:-$HOME/.cache/diffnav-src}
out=${DIFFNAV_OUT:-$HOME/.local/bin/diffnav-vim}

if [[ -d $src/.git ]]; then
  git -C "$src" fetch -q origin && git -C "$src" reset -q --hard origin/HEAD
else
  git clone -q https://github.com/dlvhdr/diffnav "$src"
fi

keys=$src/pkg/ui/keys.go
# Files: arrows only.
sed -i '' 's/key.WithKeys("up", "k"),/key.WithKeys("up"),/' "$keys"
sed -i '' 's/key.WithHelp("↑\/k", "prev file"),/key.WithHelp("↑", "prev file"),/' "$keys"
sed -i '' 's/key.WithKeys("down", "j"),/key.WithKeys("down"),/' "$keys"
sed -i '' 's/key.WithHelp("↓\/j", "next file"),/key.WithHelp("↓", "next file"),/' "$keys"
# Diff scrolling: j/k one line, J/K half page (Ctrl variants still work).
sed -i '' 's/key.WithKeys("ctrl+e"),/key.WithKeys("ctrl+e", "j"),/' "$keys"
sed -i '' 's/key.WithHelp("ctrl+e", "diff line down"),/key.WithHelp("j", "diff line down"),/' "$keys"
sed -i '' 's/key.WithKeys("ctrl+y"),/key.WithKeys("ctrl+y", "k"),/' "$keys"
sed -i '' 's/key.WithHelp("ctrl+y", "diff line up"),/key.WithHelp("k", "diff line up"),/' "$keys"
sed -i '' 's/key.WithKeys("ctrl+d"),/key.WithKeys("ctrl+d", "J"),/' "$keys"
sed -i '' 's/key.WithHelp("ctrl+d", "diff half page down"),/key.WithHelp("J", "diff half page down"),/' "$keys"
sed -i '' 's/key.WithKeys("ctrl+u"),/key.WithKeys("ctrl+u", "K"),/' "$keys"
sed -i '' 's/key.WithHelp("ctrl+u", "diff half page up"),/key.WithHelp("K", "diff half page up"),/' "$keys"

grep -q 'WithKeys("ctrl+e", "j")' "$keys" || { echo "patch did not apply; diffnav keys.go changed upstream"; exit 1; }

mkdir -p "$(dirname "$out")"
(cd "$src" && go build -o "$out" .)
echo "built $out ($(git -C "$src" rev-parse --short HEAD))"
