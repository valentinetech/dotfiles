# ---- nodev: switch Node.js versions with n (brew install n) ----
# nodev                   active version, installed versions, latest LTS / current
# nodev <version>         install if missing and switch: 24, 24.19, 24.19.0, lts, latest, current
# nodev auto              the version the current project asks for (.nvmrc, .node-version, package.json engines)
# nodev rm <version>      remove an installed version (not the active one)
# n keeps every version in /usr/local/n/versions/node and copies the active one to /usr/local/bin,
# so the switch is global (new shells, editors, Claude Code) and needs sudo. Nothing in .zshrc pins it.

nodev() {
  local dir=/usr/local/n/versions/node
  command -v n >/dev/null || { echo "n is not installed: brew install n"; return 1; }
  case ${1:-} in
    '')
      local active=$(/usr/local/bin/node -v 2>/dev/null) v
      echo "active  ${active:-none}  ($(command -v node))"
      echo "installed:"
      for v in ${(f)"$(ls $dir 2>/dev/null | sort -V)"}; do
        [[ v$v == $active ]] && echo "  ● $v" || echo "    $v"
      done
      echo "latest lts  $(n --lts 2>/dev/null)"
      ;;
    rm|remove)
      [ -n "${2:-}" ] || { echo "usage: nodev rm <version>"; return 1; }
      # the highest installed version matching what was typed: 24.1 -> 24.1.0
      local v=$(ls $dir | sort -V | grep -E "^${2//./\\.}(\\.|\$)" | tail -1)
      [ -n "$v" ] || { echo "❌ no installed version matches $2"; return 1; }
      [[ v$v == $(/usr/local/bin/node -v 2>/dev/null) ]] && { echo "❌ $v is active; switch first"; return 1; }
      sudo n rm "$v" && echo "removed $v"
      ;;
    *)
      local before=$(/usr/local/bin/node -v 2>/dev/null) target=$1
      [[ $target == latest ]] && target=current
      # globals of the version being left, to say what to reinstall
      local -a globals=(${(f)"$(npm ls -g --depth=0 --parseable 2>/dev/null | tail -n +2 | xargs -n1 basename 2>/dev/null)"})
      if [[ $target == auto ]]; then sudo n auto || return 1; else sudo n "$target" || return 1; fi
      hash -r
      local after=$(/usr/local/bin/node -v)
      echo "node ${before:-none} → $after · npm $(npm -v)"
      [[ $(command -v node) != /usr/local/bin/node ]] && echo "⚠️ this shell still finds $(command -v node) first; check PATH"
      local -a now=(${(f)"$(npm ls -g --depth=0 --parseable 2>/dev/null | tail -n +2 | xargs -n1 basename 2>/dev/null)"})
      local -a missing=(${globals:|now})
      missing=(${missing:#(npm|corepack)})
      (( ${#missing} )) && echo "global packages from $before not in $after: ${missing[*]} (sudo npm i -g ${missing[*]})"
      return 0
      ;;
  esac
}
