#!/bin/zsh
# Edit PR labels with fzf multi-select. Current labels are pre-selected.
# Usage: pr-labels.sh <owner/repo> <pr-number>
# Keys in fzf: type to filter, Tab toggles a label, Enter applies, Esc cancels.
# Set DRY_RUN=1 to print the gh command instead of running it.

set -u
repo=$1
pr=$2

current=$(gh pr view "$pr" --repo "$repo" --json labels --jq '.labels[].name' | sort)
all=$(gh label list --repo "$repo" --limit 300 --json name --jq '.[].name' | sort)

# Current labels first so they can be pre-selected by position.
ordered=$( { echo "$current"; comm -23 <(echo "$all") <(echo "$current"); } | grep -v '^$')
n_current=$(echo "$current" | grep -c .)

preselect=""
if [[ $n_current -gt 0 ]]; then
  for _ in $(seq "$n_current"); do preselect+="select+down+"; done
  preselect+="first"
fi

selected=$(echo "$ordered" | fzf --multi --prompt="labels for #$pr> " --height=70% --reverse \
  --header="Tab: toggle  Enter: apply  Esc: cancel" \
  --bind "load:transform:echo '$preselect'") || exit 0
selected=$(echo "$selected" | sort)

add=$(comm -13 <(echo "$current") <(echo "$selected") | grep -v '^$')
remove=$(comm -23 <(echo "$current") <(echo "$selected") | grep -v '^$')

args=()
while IFS= read -r l; do [[ -n $l ]] && args+=(--add-label "$l"); done <<< "$add"
while IFS= read -r l; do [[ -n $l ]] && args+=(--remove-label "$l"); done <<< "$remove"

if [[ ${#args[@]} -eq 0 ]]; then
  echo "No label changes."
  exit 0
fi

if [[ ${DRY_RUN:-0} == 1 ]]; then
  echo gh pr edit "$pr" --repo "$repo" "${args[@]}"
else
  gh pr edit "$pr" --repo "$repo" "${args[@]}"
fi
