# ---- tasks: the msw-kit task tracker shared by all Claude sessions/agents ----
# tasks            open tasks, newest update first
# tasks h          finished tasks (newest done first)
# tasks <KEY>      full JSON of one task (open or finished)
# tasks watch|w    live view for a side pane (r: review requests view, t: back to tasks):
#                  open tasks at the top, newest first, as many as fit
#                  ("+N more" only for the overflow), recently finished and the change feed flush
#                  with the bottom edge;
#                  redraws when agents update the tracker (Ctrl-C to quit)
# Written only through the msw-kit MCP (tasks_update); this just reads the files.

_TASKS_DIR=~/Documents/GitHub/msw-kit/data
# this file, symlinks resolved: the watcher re-sources it when it changes, so an open pane picks up edits
_TASKS_SRC=${${(%):-%x}:A}

tasks() {
  local open=$_TASKS_DIR/tasks.json hist=$_TASKS_DIR/history.json
  local cols=${COLUMNS:-120}
  if [[ "$1" == watch || "$1" == w ]]; then _tasks_watch "$open" "$hist"; return; fi
  # shared jq helpers: colours, "2h ago", truncate to width
  local lib='
    def c($n): "\u001b[" + $n + "m";
    def dim: c("2");  def bold: c("1");  def reset: c("0");
    def colour($s): if $s == "in_progress" or $s == "implementing" then c("33")
                    elif $s == "testing" or $s == "linting" then c("36")
                    elif $s == "verifying" or $s == "e2e" or $s == "self_review" then c("34")
                    elif $s == "blocked" then c("31") elif $s == "human_review" then c("1;36") elif $s == "review" then c("35")
                    elif $s == "ready_for_review" then c("1;32")
                    elif $s == "done" then c("32") else c("90") end;
    # one glyph per status (all single-width, so the columns stay aligned)
    def icon($s): {todo: "○", in_progress: "◐", implementing: "✎", testing: "◇", linting: "≡",
                   verifying: "◉", e2e: "▷", self_review: "⊙", blocked: "✖", review: "◎", human_review: "★", ready_for_review: "◆", done: "✔"}[$s] // "●";
    def stname($s): $s | gsub("_"; " ");
    def epoch: sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601;
    def ago: (now - epoch) | floor
      | if . < 60 then "just now" elif . < 3600 then "\(./60|floor)m ago"
        elif . < 86400 then "\(./3600|floor)h ago" else "\(./86400|floor)d ago" end;
    def cut($n): if length > $n then .[0:$n-1] + "…" else . end;
    def prnum: if . == null then null else capture("/pull/(?<n>[0-9]+)$").n // . end;
    # CI state from watch-pr: red when something fails, yellow while running/fixing, green when green
    def ciline($ci; $n): (if ($ci | test("fail|red|conflict|reject"; "i")) then c("31")
                          elif ($ci | test("green|approved|ready|pass"; "i")) then c("32")
                          else c("33") end) + "⟳ " + ($ci | cut($n)) + reset;
  '
  case "$1" in
    h)
      [ -f "$hist" ] || { echo "no history yet"; return }
      jq -r --argjson w "$cols" "$lib"'
        to_entries | map(.value) | sort_by(.doneAt) | reverse | .[]
        | colour("done") + icon("done") + reset + " " + bold + .key + reset + "  " + ((.title // "") | cut($w - 30))
          + "\n  " + dim + "done " + (.doneAt | ago)
          + (if .pr then " · PR #" + (.pr | prnum) else "" end)
          + (if .branch then " · " + .branch else "" end) + reset + "\n"' "$hist"
      ;;
    "")
      [ -f "$open" ] || { echo "no open tasks"; return }
      # _TASKS_LIMIT=n (set by the watcher) shows only the n most recently updated, plus a "+n more" line
      # open review comments per task, left with c in the worktree picker (tmux prefix g)
      local -a cfiles=( $_TASKS_DIR/comments/*.jsonl(N) ); local cm='{}'
      (( ${#cfiles} )) && cm=$(cat "${(@)cfiles}" | jq -cs 'map(select(.status != "resolved")) | group_by(.key) | map({key: .[0].key, value: {open: map(select(.status == "open")) | length, working: map(select(.status == "working")) | length}}) | from_entries' 2>/dev/null || echo '{}')
      # draft or not per open PR (GitHub, refreshed every 2 min in the background)
      _tasks_prs_fetch
      local gp='{}'; [[ -s $_TASKS_PR_DRAFTS ]] && gp=$(<$_TASKS_PR_DRAFTS)
      jq -r --argjson w "$cols" --argjson lim "${_TASKS_LIMIT:-0}" --argjson cm "$cm" --argjson gp "$gp" "$lib"'
        ($gp.drafts // {}) as $dr
        # every open PR of yours whose title carries the task key is listed under it, recorded or not
        | map_values(. as $t | ((.prs // []) | if length == 0 and $t.pr then [{pr: $t.pr}] else . end) as $p
            | (($gp.byKey // {})[.key] // []) as $found
            | .prs = $p + [$found[] | select(. as $u | $p | map(.pr) | index($u) | not) | {pr: .}]
            | if (.prs | length) == 1 and (.pr | not) then .pr = .prs[0].pr else . end)
        # a PR the user marked ready counts as ready_for_review even before watch-pr notices
        | map_values(if (.status | IN("review", "human_review"))
                      and ([(.prs // [{pr: .pr}])[] | select(.pr and (.mergedAt | not)) | $dr[.pr]] as $d
                           | ($d | length) > 0 and all($d[]; . == false))
                   then .status = "ready_for_review" else . end)
        | . as $open
        # priority: what needs you first, then work in flight, then waiting on others, then not started;
        # newest update first inside each group
        | def rank: if .status == "blocked" then 0
                    elif .status == "human_review" then 1
                    elif (.status | IN("implementing", "testing", "linting", "verifying", "e2e", "self_review", "in_progress")) then 2
                    elif (.status | IN("review", "ready_for_review")) then 3
                    elif .status == "todo" then 4 else 5 end;
        # sections in this order: needs you (blocked on you: auth, an install, a decision; or a green draft
        # waiting for your review), in progress (incl. todo), in review (draft PR, the bot fixing CI and bot
        # comments), ready for review (you marked it ready: teammates review), ad hoc (no ticket key; a blocked
        # ad hoc task still goes to needs you)
        def section: if (.status | IN("human_review", "blocked")) then 0
                       elif (.key | startswith("adhoc-")) then 4
                       elif .status == "review" then 2
                       elif .status == "ready_for_review" then 3 else 1 end;
        def sname: ["Needs you", "In progress", "In review", "Ready for review", "Ad hoc"][.];
        to_entries | map(.value) | if length == 0 then "no open tasks" else
        sort_by([section, rank, -(.updated | epoch)])
        | (map(section) | group_by(.) | map({key: (.[0] | tostring), value: length}) | from_entries) as $count
        # with a limit: the $lim newest, plus anything updated in the last 3 hours (a running session)
        | (if $lim > 0 then [ to_entries[] | select(.key < $lim or (now - (.value.updated | epoch)) < 10800) | .value ] else . end) as $shown
        | (if $lim > 0 and length > ($shown | length) then dim + "  +\(length - ($shown | length)) more · tasks" + reset + "\n" else "" end) as $more
        | $shown
        | (. as $a | range(0; length) as $i | $a[$i] | ((.prs // []) | length > 1) as $multi
        # section header glued to its first task (no blank line), so the watcher keeps it with that task
        | (if $i == 0 or ($a[$i - 1] | section) != section then
             (if section == 0 then c("1;36") else dim end) + "── " + (section | sname)
             + " (" + ($count[section | tostring] | tostring) + ") ──" + reset + "\n"
           else "" end)
          + colour(.status) + icon(.status) + reset + " " + bold + .key + reset + "  " + ((.title // "") | cut($w - 16))
          + "\n  " + colour(.status) + stname(.status) + reset + dim
          + (if $multi then "" else
              (if .branch then " · " + .branch else "" end)
              + (if .pr then " · PR #" + (.pr | prnum) else "" end) end)
          + (if .agent then " · " + .agent else "" end)
          + " · " + (.updated | ago) + reset
          # several PRs: one line each with its branch and CI state; one PR: its CI line from watch-pr
          + (if $multi then
              # merged (recorded, or the ci line from watch-pr says so): green tick, the rest struck through
              [.prs[] | (((.pr | try capture("github.com/[^/]+/(?<r>[^/]+)/pull").r catch null) // "hpanel") as $repo
                   | "PR " + (if $repo == "hpanel" then "" else $repo end) + "#" + (.pr | prnum)
                     + (if .branch then " · " + .branch else "" end)) as $head
                | if .mergedAt or ((.ci // "") | test("^merged"; "i")) then
                    "\n  " + c("32") + "✔ " + reset + dim + c("9") + ($head + " · " + (.ci // "merged") | cut($w - 6)) + reset
                  else
                    "\n  " + dim + "⑂ " + $head + reset
                    + (if .ci then " " + ciline(.ci; $w - 8 - ($head | length)) else "" end)
                  end] | join("")
            elif .ci then "\n  " + ciline(.ci; $w - 6) else "" end)
          # merge-after links: dim while work/review goes on, yellow once this one is approved and only waiting
          + (if (.blockedBy // []) | length > 0 then
              ((.ci // "") | test("approved|ready to merge"; "i")) as $ready
              | "\n  " + (if $ready then c("33") else dim end) + "⏸ merge after "
                + ([.blockedBy[] | . as $b | $b + " (" + (($open[$b].status // "not tracked") | stname(.)) + ")"] | join(", "))
                + (if $ready then " · approved, waiting" else "" end) + reset
            else "" end)
          # your review comments: 💬 open, 🔧 an agent is fixing them
          + (if $cm[.key] then "\n  "
               + ([ (if $cm[.key].open > 0 then c("33") + "💬 \($cm[.key].open) open" + reset else empty end),
                    (if $cm[.key].working > 0 then c("34") + "🔧 \($cm[.key].working) being fixed" + reset else empty end) ] | join(dim + " · " + reset))
               + dim + " (your review comments)" + reset else "" end)
          + (if (.notes | length) > 0 then "\n  " + dim + "↳ " + reset + (.notes[-1].text | cut($w - 4)) else "" end)
          + "\n"), $more end' "$open"
      ;;
    *)
      local key=${1:u}
      jq --arg k "$key" '.[$k] // empty' "$open" "$hist" 2>/dev/null | grep -q . \
        && jq --arg k "$key" '.[$k] // empty' "$open" "$hist" 2>/dev/null \
        || echo "no task $key"
      ;;
  esac
}

# ---- your open PRs on GitHub (any repo), one search every 2 min in the background ----
# { drafts: { "<pr url>": isDraft }, byKey: { "HPNL-1234": ["<pr url>", ...] } }; the key comes from the PR
# title (the repo convention ends it with the ticket key). Shows a task's split PRs even when no session
# recorded them in the tracker, and whether each one is still a draft.
_TASKS_PR_DRAFTS=~/.cache/tasks-pr-drafts.json
_tasks_prs_fetch() {
  local c=$_TASKS_PR_DRAFTS
  zmodload -F zsh/stat b:zstat 2>/dev/null; zmodload zsh/datetime 2>/dev/null
  (( EPOCHSECONDS - $(zstat +mtime "$c" 2>/dev/null || echo 0) < 120 )) && return
  [[ -e $c.lock ]] && (( EPOCHSECONDS - $(zstat +mtime "$c.lock" 2>/dev/null || echo 0) < 60 )) && return
  mkdir -p ${c:h}; : > $c.lock
  ( gh search prs --author @me --state open --limit 100 --json url,title,isDraft 2>/dev/null \
      | jq -c '{drafts: (map({key: .url, value: .isDraft}) | from_entries),
                byKey: ([.[] | {url, k: ([.title | scan("[A-Za-z][A-Za-z0-9]+-[0-9]+")] | last | ascii_upcase?)}
                         | select(.k) ] | group_by(.k) | map({key: .[0].k, value: map(.url)}) | from_entries)}' > $c.tmp \
      && [[ -s $c.tmp ]] && mv $c.tmp $c
    rm -f $c.lock ) &!
}

# ---- reviews view (r in the watcher): PRs waiting on your review, joined with the review ledger ----
_TASKS_REVIEWS_CACHE=~/.cache/tasks-reviews.json
_TASKS_REVIEWS_STATES=~/.cache/tasks-reviews-states.json
_TASKS_REVIEWS_LEDGER=~/.local/state/claude/review-requested-prs/reviews.jsonl
# one <number>.json per PR whose review subagent is running (written/removed by review-requested-prs)
_TASKS_REVIEWS_INFLIGHT=~/.local/state/claude/review-requested-prs/reviewing
# local, never committed: one GitHub login per line (# comments ok) whose PRs are hidden here
# and skipped by review-requested-prs
_TASKS_REVIEWS_SKIP=~/.config/review-skip-authors

# refresh the requested-PR list in the background when it is older than 2 min
# or the skip list changed since (never blocks the view)
_tasks_reviews_fetch() {
  local c=$_TASKS_REVIEWS_CACHE
  zmodload -F zsh/stat b:zstat 2>/dev/null; zmodload zsh/datetime 2>/dev/null
  local cm=$(zstat +mtime "$c" 2>/dev/null || echo 0)
  (( EPOCHSECONDS - cm < 120 && $(zstat +mtime $_TASKS_REVIEWS_SKIP 2>/dev/null || echo 0) <= cm )) && return
  [[ -e $c.lock ]] && (( EPOCHSECONDS - $(zstat +mtime "$c.lock" 2>/dev/null || echo 0) < 60 )) && return
  mkdir -p ${c:h}; : > $c.lock
  local -a skip=( ${(f)"$(cat $_TASKS_REVIEWS_SKIP 2>/dev/null)"} )
  skip=( ${${skip:#\#*}//[[:space:]]/} ); skip=( ${skip:#} )
  ( gh pr list --repo hostinger/hpanel --limit 100 \
      --search "is:open -is:draft user-review-requested:@me -author:@me -author:app/dependabot ${skip/#/-author:}" \
      --json number,title,author,headRefOid,updatedAt,url > $c.tmp 2>/dev/null && mv $c.tmp $c
    # title and open/merged/closed for every PR in the ledger (the week's history), one GraphQL call
    local q
    q=$(jq -rs '[.[] | select(.repo == "hostinger/hpanel") | .number] | unique
      | map("p\(.): pullRequest(number: \(.)) { number state title }") | join(" ")' \
      $_TASKS_REVIEWS_LEDGER 2>/dev/null)
    [[ -n $q ]] && gh api graphql -f query="{ repository(owner: \"hostinger\", name: \"hpanel\") { $q } }" \
      --jq '[.data.repository[] | select(.)]' > $_TASKS_REVIEWS_STATES.tmp 2>/dev/null \
      && mv $_TASKS_REVIEWS_STATES.tmp $_TASKS_REVIEWS_STATES
    rm -f $c.lock ) &!
}

# the reviews list: reviewing now, waiting on you (not reviewed / rated but not posted / new commits since),
# then everything you reviewed in the last 7 days (the ledger keeps a week)
_tasks_reviews() {
  local cols=${COLUMNS:-120}
  _tasks_reviews_fetch
  [[ -f $_TASKS_REVIEWS_CACHE ]] || { print "  fetching review requests…"; return }
  jq -r -n --argjson w "$cols" --slurpfile req $_TASKS_REVIEWS_CACHE \
    --slurpfile led <( [[ -f $_TASKS_REVIEWS_LEDGER ]] && cat $_TASKS_REVIEWS_LEDGER || true ) \
    --slurpfile ing <( cat /dev/null $_TASKS_REVIEWS_INFLIGHT/*.json(N) 2>/dev/null || true ) \
    --slurpfile st <( [[ -f $_TASKS_REVIEWS_STATES ]] && cat $_TASKS_REVIEWS_STATES || true ) '
    def c($n): "\u001b[" + $n + "m"; def dim: c("2"); def bold: c("1"); def reset: c("0");
    def epoch: sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601;
    def ago: (now - epoch) | floor
      | if . < 3600 then "\(./60|floor)m ago" elif . < 86400 then "\(./3600|floor)h ago" else "\(./86400|floor)d ago" end;
    def cut($n): if length > $n then .[0:$n-1] + "…" else . end;
    ($led | map(select(.repo == "hostinger/hpanel"))) as $l
    # in flight: markers younger than 2 h (an older one is a crashed session)
    | ($ing | map(select((now - (.startedAt | epoch)) < 7200)) | sort_by(.startedAt)) as $doing
    | ($doing | map(.number)) as $doingN
    # latest review entry and latest posted entry per PR
    | ($l | map(select(.rating)) | group_by(.number) | map({key: (.[0].number | tostring), value: .[-1]}) | from_entries) as $rev
    | ($l | map(select(.posted == true)) | group_by(.number) | map({key: (.[0].number | tostring), value: .[-1]}) | from_entries) as $post
    | ($req[0] // [] | map(select(.number | IN($doingN[]) | not))) as $r
    | ($r | map(. as $p | ($rev[$p.number | tostring]) as $e | ($post[$p.number | tostring]) as $x
        | $p + {state:
            (if $e == null then "new"
             elif $e.headSha != $p.headRefOid then "moved"
             elif $x != null and $x.headSha == $p.headRefOid then "posted"
             else "rated" end), rating: ($e.rating // null)})) as $rows
    | def line($col; $tag): $col + "●" + reset + " " + bold + "#\(.number)" + reset + "  " + (.title | cut($w - 12))
        + "\n  " + $col + $tag + reset + dim + " · " + .author.login + " · " + (.updatedAt | ago) + reset;
    (if ($doing | length) > 0 then
       (dim + "── Reviewing (\($doing | length)) ──" + reset),
       ($doing[] | c("34") + "◐" + reset + " " + bold + "#\(.number)" + reset + "  " + ((.title // "") | cut($w - 12))
         + "\n  " + c("34") + "reviewing" + reset + dim + " · " + (.author // "") + " · @ " + ((.headSha // "")[0:7])
         + " · started " + (.startedAt | ago) + reset),
       ""
     else empty end),
    (dim + "── Waiting on you (\($rows | map(select(.state != "posted")) | length)) ──" + reset),
    ($rows | map(select(.state == "new")) | .[] | line(c("33"); "not reviewed")),
    ($rows | map(select(.state == "moved")) | .[] | line(c("35"); "new commits since your review (\(.rating))")),
    ($rows | map(select(.state == "rated")) | .[] | line(c("36"); "\(.rating) · not posted")),
    "",
    # the week: latest entry per PR from the ledger (review-requested search drops PRs once reviewed),
    # merged/closed from the background state fetch
    (($st[0] // []) | map({key: (.number | tostring), value: .}) | from_entries) as $pr
    # posted entries carry no rating: take the latest rated entry, then look for a posted one at its head
    | ([$l[] | select(.reviewedAt and (now - (.reviewedAt | epoch)) < 604800)]
       | group_by(.number)
       | map(([.[] | select(.rating)] | last) as $r | select($r)
           | ([.[] | select(.posted == true and .headSha == $r.headSha)] | last) as $p
           | $r + {posted: ($p != null), at: ($p.reviewedAt // $r.reviewedAt),
               nitCount: (if $p then $p.nitsPosted // 0 else ($r.nits // []) | length end)})
       | sort_by(.at) | reverse) as $week
    # only the 10 newest, so the list never fills the pane
    | (dim + "── Reviewed this week (\(if ($week | length) > 10 then "last 10 of \($week | length)" else $week | length end)) ──" + reset),
      ($week[0:10][] | ($pr[.number | tostring].state // "") as $s
        | (if .rating == "REQUEST CHANGES" then c("31") elif .rating == "APPROVE WITH NITS" then c("36") else c("32") end) as $col
        | (if .posted then $col + "✔" else dim + "○" end) + reset + " " + bold + "#\(.number)" + reset
          + "  " + ((.title // $pr[.number | tostring].title // "") | cut($w - 12))
          + "\n  " + $col + .rating + reset + dim
          + (if .posted then " · posted" else " · not posted" end)
          + (if .nitCount > 0 then " · \(.nitCount) nit(s)" else "" end)
          + (if $s == "MERGED" then " · " + reset + c("35") + "merged" + reset + dim
             elif $s == "CLOSED" then " · closed" else "" end)
          + " · " + (.at | ago) + reset)
  '
}

# live view: polls the two files once a second (no fswatch needed), redraws on change
# or every 60 s so the "2m ago" labels stay honest; keeps a short feed of what changed.
_tasks_watch() {
  local open=$1 hist=$2 cols=${COLUMNS:-120}
  zmodload -F zsh/stat b:zstat 2>/dev/null
  local sig='' last='' tick=0 prev='{}' snap changes line mode=tasks key
  local srcm=$(zstat +mtime $_TASKS_SRC 2>/dev/null)
  local -a feed
  local dim=$'\e[2m' bold=$'\e[1m' reset=$'\e[0m' green=$'\e[32m' yellow=$'\e[33m'
  tput civis 2>/dev/null
  trap 'tput cnorm 2>/dev/null; trap - INT; return 0' INT
  while true; do
    if [[ $mode == reviews ]]; then
      sig="reviews/$(zstat +mtime $_TASKS_REVIEWS_CACHE 2>/dev/null)/$(zstat +mtime $_TASKS_REVIEWS_LEDGER 2>/dev/null)/$(zstat +mtime $_TASKS_REVIEWS_INFLIGHT 2>/dev/null)/${COLUMNS}/${LINES}"
      if [[ "$sig" != "$last" || $tick -ge 60 ]]; then
        last=$sig; tick=0
        printf '\e[H\e[2J'
        print -l -- "${bold}review requests${reset} ${dim}· live · $(date +%H:%M:%S) · t tasks · Ctrl-C to quit${reset}" ""
        _tasks_reviews
      fi
      # the list itself refreshes every 2 min in the background
      (( tick % 30 == 0 )) && _tasks_reviews_fetch
    else
    sig="$(zstat +mtime "$open" 2>/dev/null)/$(zstat +mtime "$hist" 2>/dev/null)/$(zstat +mtime $_TASKS_DIR/comments/*.jsonl(N.om[1]) 2>/dev/null)/$(zstat +mtime $_TASKS_PR_DRAFTS 2>/dev/null)/${COLUMNS}"
    if [[ "$sig" != "$last" || $tick -ge 60 ]]; then
      # key -> updated for open tasks, plus "done" markers for everything in history
      snap=$(jq -c -s '(.[0] // {} | map_values(.updated)) + (.[1] // {} | map_values("done"))' "$open" "$hist" 2>/dev/null) || snap='{}'
      if [[ "$sig" != "$last" && "$last" != "" ]]; then
        changes=$(jq -r -n --argjson p "$prev" --argjson n "$snap" --slurpfile o "$open" --slurpfile h "$hist" '
          ($o[0] // {}) as $open | ($h[0] // {}) as $hist
          | [ $n | to_entries[] | select($p[.key] != .value) ]
          | map(
              if .value == "done" then "\u001b[32m✔ \(.key)\u001b[0m done"
              else ($open[.key]) as $t
                | "\u001b[33m" + ({todo: "○", in_progress: "◐", implementing: "✎", testing: "◇", linting: "≡",
                    verifying: "◉", e2e: "▷", self_review: "⊙", blocked: "✖", review: "◎", human_review: "★"}[$t.status // ""] // "●")
                  + " \(.key)\u001b[0m \($t.status // "")"
                  + (if ($t.agent // "") != "" then " · \($t.agent)" else "" end)
                  + (if ($t.notes | length) > 0 then " · \($t.notes[-1].text)" else "" end)
              end)
          | .[]' 2>/dev/null)
        for line in ${(f)changes}; do
          feed=("${(@)feed}" "${dim}$(date +%H:%M:%S)${reset}  ${line}")
        done
        (( ${#feed} > 3 )) && feed=("${(@)feed[-3,-1]}")
      fi
      prev=$snap; last=$sig; tick=0
      # layout: open tasks at the top, the feed anchored to the bottom half, finished list right above it
      local rows=${LINES:-40}
      local -a fin top
      fin=()
      # last 2 finished, so a ticket that just left the open list is still visible
      if [[ -f "$hist" ]] && jq -e 'length > 0' "$hist" >/dev/null 2>&1; then
        fin=( ${(f)"$(jq -r --argjson w "$cols" '
          def c($n): "\u001b[" + $n + "m";
          def epoch: sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601;
          def ago: (now - epoch) | floor
            | if . < 60 then "just now" elif . < 3600 then "\(./60|floor)m ago"
              elif . < 86400 then "\(./3600|floor)h ago" else "\(./86400|floor)d ago" end;
          def cut($n): if length > $n then .[0:$n-1] + "…" else . end;
          def prnum: if . == null then null else capture("/pull/(?<n>[0-9]+)$").n // . end;
          to_entries | map(.value) | sort_by(.doneAt) | reverse | .[0:2][]
          | c("32") + "✔" + c("0") + " " + c("1") + .key + c("0") + "  " + ((.title // "") | cut($w - 40))
            + c("2") + "  " + (.doneAt | ago)
            + (if .pr then " · PR #" + (.pr | prnum) else "" end) + c("0")' "$hist")"} )
      fi
      # tasks take the top and get priority; finished + feed sit flush against the bottom edge,
      # using at most ~40% of the height and never overlapping the tasks above
      top=( "${bold}msw-kit tasks${reset} ${dim}· live · $(date +%H:%M:%S) · r reviews · Ctrl-C to quit${reset}" "" )
      # every open task, newest first, as many as fit; only the overflow becomes "+N more".
      # Room is kept for the recently-finished block (header + its lines + a gap) at the bottom.
      local reserve=$(( ${#fin} ? ${#fin} + 2 : 0 )) avail line nblocks=0 shown=0
      avail=$(( rows - $(_tasks_rows "${(@)top}") - reserve - 2 ))
      local -a all block blocks
      # `local` inside the redraw loop does not empty an array that already exists: reset explicitly
      all=() block=() blocks=()
      all=( "${(@f)$(tasks)}" )
      for line in "${(@)all}" ""; do
        if [[ -z $line ]]; then
          (( ${#block} )) && { blocks+=( "${(pj:\n:)block}" ); block=() }
        else
          block+=( "$line" )
        fi
      done
      nblocks=${#blocks}
      for b in "${(@)blocks}"; do
        local -a bl; bl=( "${(@f)b}" "" )
        (( $(_tasks_rows "${(@)top}" "${(@)bl}") - 3 > avail + 0 && shown > 0 )) && break
        (( $(_tasks_rows "${(@)top}" "${(@)bl}") > rows - reserve - 2 && shown > 0 )) && break
        top+=( "${(@)bl}" ); (( shown++ ))
      done
      (( shown < nblocks )) && top+=( "${dim}  +$(( nblocks - shown )) more · tasks${reset}" )
      local top_rows=$(_tasks_rows "${(@)top}") budget
      budget=$(( rows - top_rows - 1 ))
      (( budget > rows * 2 / 5 )) && budget=$(( rows * 2 / 5 ))
      local -a bottom
      _tasks_bottom() {
        bottom=()
        (( ${#fin} )) && bottom+=( "${dim}── recently finished ──${reset}" "${(@)fin}" )
        if (( ${#feed} )); then
          (( ${#bottom} )) && bottom+=( "" )
          bottom+=( "${dim}── recent changes ──${reset}" "${(@)feed}" )
        fi
      }
      _tasks_bottom
      # shrink: oldest feed entries first, then the whole feed, then the finished list
      while (( ${#bottom} && $(_tasks_rows "${(@)bottom}") > budget )); do
        if (( ${#feed} > 1 )); then feed=("${(@)feed[2,-1]}")
        elif (( ${#feed} )); then feed=()
        else fin=(); fi
        _tasks_bottom
      done
      printf '\e[H\e[2J'
      print -l -- "${(@)top}"
      if (( ${#bottom} )); then
        printf '\e[%d;1H' $(( rows - $(_tasks_rows "${(@)bottom}") + 1 ))
        print -n -l -- "${(@)bottom}"
      fi
    fi
    fi
    # tasks.zsh edited: reload the functions and redraw (this loop keeps running, the next calls use the new code)
    if [[ $(zstat +mtime $_TASKS_SRC 2>/dev/null) != $srcm ]]; then
      srcm=$(zstat +mtime $_TASKS_SRC 2>/dev/null); source $_TASKS_SRC; last=''
    fi
    # wait a second, or less if a key comes in: r = reviews view, t = tasks view
    if read -s -t 1 -k 1 key 2>/dev/null; then
      case $key in
        r) [[ $mode != reviews ]] && { mode=reviews; last=''; _tasks_reviews_fetch } ;;
        t) [[ $mode != tasks ]] && { mode=tasks; last='' } ;;
      esac
    fi
    (( tick++ ))
  done
}

# visual rows a list of (possibly coloured, possibly wrapping) lines takes at the current width
_tasks_rows() {
  setopt localoptions extendedglob
  local l s n=0 w=${COLUMNS:-120}
  for l in "$@"; do
    s=${l//$'\e'\[[0-9;]#m/}
    (( n += ${#s} ? (${#s} + w - 1) / w : 1 ))
  done
  print $n
}

# wtsweep: list worktrees (any repo in ~/Documents/GitHub) whose PR is merged, then retire them on y:
# uncommitted work archived to ~/Documents/GitHub/.worktree-archive, worktree removed, branch deleted if safe.
# One worktree: ctrl-x in the tmux worktree picker (prefix g).
wtsweep() {
  local wt=~/Documents/GitHub/dotfiles/tmux/worktrees out
  out=$($wt --sweep -n); print -r -- "$out"
  [[ $out == would* ]] || return 0
  read -q "?retire these? [y/N] " && { echo; $wt --sweep; } || echo
}
