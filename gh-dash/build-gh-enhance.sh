#!/bin/zsh
# Build gh-enhance with `q` as a quit key (upstream only has ctrl+c, keys are hard-coded
# in internal/tui/keys.go). Produces ~/.local/bin/gh-enhance-q, which gh-dash's `S` runs.
# `q` is ignored while a list filter or the log search is being typed. Re-run for upgrades.

set -euo pipefail

src=${GH_ENHANCE_SRC:-$HOME/.cache/gh-enhance-src}
out=${GH_ENHANCE_OUT:-$HOME/.local/bin/gh-enhance-q}

if [[ -d $src/.git ]]; then
  git -C "$src" fetch -q origin && git -C "$src" reset -q --hard origin/HEAD
else
  git clone -q https://github.com/dlvhdr/gh-enhance "$src"
fi

keys=$src/internal/tui/keys.go
tui=$src/internal/tui/tui.go

sed -i '' 's/key.WithKeys("ctrl+c"),/key.WithKeys("ctrl+c", "q"),/' "$keys"
sed -i '' 's/key.WithHelp("ctrl+c", "quit"),/key.WithHelp("q\/ctrl+c", "quit"),/' "$keys"
# Only let plain `q` quit when no list filter is being typed (ctrl+c always quits).
sed -i '' 's/^\t\tif key.Matches(msg, quitKey) {$/\t\tif key.Matches(msg, quitKey) \&\& (msg.String() == "ctrl+c" || (m.checksList.FilterState() != list.Filtering \&\& m.runsList.FilterState() != list.Filtering \&\& m.jobsList.FilterState() != list.Filtering \&\& m.stepsList.FilterState() != list.Filtering)) {/' "$tui"

grep -q 'WithKeys("ctrl+c", "q")' "$keys" || { echo "patch did not apply; keys.go changed upstream"; exit 1; }
grep -q 'quitKey) && (msg.String() == "ctrl+c"' "$tui" || { echo "patch did not apply; tui.go changed upstream"; exit 1; }

mkdir -p "$(dirname "$out")"
(cd "$src" && go build -o "$out" .)
echo "built $out ($(git -C "$src" rev-parse --short HEAD))"
