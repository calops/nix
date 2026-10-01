# Claude Code statusLine command.
# Reads the statusLine JSON payload on stdin and renders two lines of
# oh-my-posh style "pills" (same palette and diamonds as the shell prompt).
# Managed by Nix: modules/programs/claude-code.nix.
#
# Environment:
#   CLAUDE_STATUSLINE_PALETTE  scss palette file ($name: #rrggbb;), set by Nix;
#                              defaults to the one home-manager writes to XDG.
#   CLAUDE_STATUSLINE_CAPTURE  where the last payload is saved, so
#                              `claude-statusline-preview` can replay real data.
#   CLAUDE_STATUSLINE_READONLY set by the preview: don't update the
#                              rate-limit and extra-cost state.
#   CLAUDE_STATUSLINE_MARGIN   columns reserved around the line (default 5).
set -uo pipefail
# Force "." as the decimal separator so printf %.2f accepts jq numbers.
export LC_NUMERIC=C

input="$(cat)"

capture="${CLAUDE_STATUSLINE_CAPTURE:-${XDG_RUNTIME_DIR:-/tmp}/claude-statusline-last.json}"
printf '%s' "$input" >"$capture" 2>/dev/null

# ---------------------------------------------------------------- glyphs --
# Built from codepoints so the file stays plain ASCII and doesn't depend on
# the caller's locale.
u8() { # $1: target var, $2: hex codepoint
  local cp=$((16#$2)) b
  if ((cp < 0x800)); then
    printf -v b '\\x%02x\\x%02x' $((0xC0 | cp >> 6)) $((0x80 | cp & 0x3F))
  elif ((cp < 0x10000)); then
    printf -v b '\\x%02x\\x%02x\\x%02x' $((0xE0 | cp >> 12)) $((0x80 | cp >> 6 & 0x3F)) $((0x80 | cp & 0x3F))
  else
    printf -v b '\\x%02x\\x%02x\\x%02x\\x%02x' $((0xF0 | cp >> 18)) $((0x80 | cp >> 12 & 0x3F)) \
      $((0x80 | cp >> 6 & 0x3F)) $((0x80 | cp & 0x3F))
  fi
  # shellcheck disable=SC2059 # $b is a generated escape sequence
  printf -v "$1" "$b"
}

u8 g_left E0B6 # pill caps, same as oh-my-posh
u8 g_right E0B4
u8 g_model F06A9  # robot
# Effort levels as signal bars (0-3), fire for max.
u8 g_effort_low F08BF
u8 g_effort_medium F08BC
u8 g_effort_high F08BD
u8 g_effort_xhigh F08BE
u8 g_effort_max F0238
u8 g_think F09D1 # brain
u8 g_style F1FC   # paintbrush
u8 g_agent F21B   # user-secret
u8 g_tree F0645   # file-tree
u8 g_vim E62B
u8 g_session F412 # tag
u8 g_folder F07B
u8 g_git E702
u8 g_github F09B
u8 g_gitlab F296
u8 g_branch E0A0
u8 g_ahead F062
u8 g_behind F063
u8 g_working F044 # edit
u8 g_pr F407
u8 g_stack F0BA5  # layers
u8 g_ticket F145  # ticket
u8 g_chevron 203A # single right angle quote
u8 g_ctx F035B    # memory chip
u8 g_limit F051F  # timer-sand
u8 g_cost F155    # dollar
u8 g_clock F017
u8 g_cache_read F095E  # database-export
u8 g_cache_write F095D # database-import
u8 g_warm F0238        # fire
u8 g_cold F0717        # snowflake
u8 g_in F02FA          # import
u8 g_out F0207         # export
u8 g_dot 00B7
u8 g_tokens F0B38 # coins
u8 g_reset F06B0  # history

# Left-aligned eighth blocks for the progress bars (index = eighths filled).
eighths=(" ")
for cp in 258F 258E 258D 258C 258B 258A 2589 2588; do
  u8 g "$cp"
  eighths+=("$g")
done

# ---------------------------------------------------------------- colors --
declare -A F B # truecolor fg / bg escapes, keyed by palette name
palette="${CLAUDE_STATUSLINE_PALETTE:-${XDG_DATA_HOME:-$HOME/.local/share}/colors/palette.scss}"
if [ -r "$palette" ]; then
  while IFS= read -r l; do
    [[ $l =~ ^\$([a-z0-9]+):\ *#([0-9a-fA-F]{6}) ]] || continue
    h="${BASH_REMATCH[2]}"
    rgb="$((16#${h:0:2}));$((16#${h:2:2}));$((16#${h:4:2}))"
    F[${BASH_REMATCH[1]}]=$'\e[38;2;'"${rgb}m"
    B[${BASH_REMATCH[1]}]=$'\e[48;2;'"${rgb}m"
  done <"$palette"
fi

reset=$'\e[0m'
bold=$'\e[1m'
nobold=$'\e[22m'
fgdef=$'\e[39m'
pill_bg="${B[surface0]:-}"
track_bg="${B[surface1]:-}"

# Pills per line and side, joined at the end once the widths are known.
left1=() center1=() right1=() left2=() center2=() right2=()

# pill <array> <content>: appends one pill to the named array. Content must
# only change the foreground (or restore $pill_bg after changing the
# background) so the pill stays solid.
pill() {
  local -n dst="$1"
  [ -z "$2" ] && return
  dst+=("${F[surface0]:-}${g_left}${pill_bg}${2}${fgdef}${reset}${F[surface0]:-}${g_right}${reset}")
}

# Terminal width for right alignment. Claude Code doesn't pass it, so ask
# the controlling terminal; without one, right pills just follow the left.
cols="${COLUMNS:-}"
if [ -z "$cols" ]; then
  read -r _ cols < <(stty size </dev/tty 2>/dev/null)
fi
# Columns Claude Code's prompt box takes around the status line (measured:
# any less and Claude Code truncates the last pill with an ellipsis).
margin="${CLAUDE_STATUSLINE_MARGIN:-5}"

visible_width() { # $1: string with SGR escapes -> printed cell count
  # Chunk-wise instead of an extglob ${s//...}, which is quadratic in bash.
  local LC_ALL=C.UTF-8 s="$1" out="" esc=$'\e['
  while [[ $s == *"$esc"* ]]; do
    out+="${s%%"$esc"*}"
    s="${s#*"$esc"}"
    s="${s#*m}"
  done
  out+="$s"
  echo "${#out}"
}

join_pills() { # <array name>: sets $joined and $joined_w
  local -n a="$1"
  local i
  joined=""
  for i in "${a[@]}"; do joined+="${joined:+ }$i"; done
  joined_w=$(visible_width "$joined")
}

# join_line <left> <center> <right>: prints one line with the left pills,
# the center pills centered on the line (pushed right if the left side is
# too long) and the right pills against the edge. When it doesn't fit,
# right pills go first, then center ones, last pill first; left always stays.
join_line() {
  local -n cl="$2" cr="$3"
  local left lw center="" cw=0 right="" rw=0 avail start
  local c_keep=("${cl[@]}") r_keep=("${cr[@]}")
  join_pills "$1"
  left="$joined" lw="$joined_w"
  if [ -z "$cols" ]; then # unknown width: just chain everything
    join_pills "$2"; center="$joined"
    join_pills "$3"; right="$joined"
    printf '%s%s%s\n' "$left" "${center:+ $center}" "${right:+ $right}"
    return
  fi
  avail=$((cols - margin))
  while :; do
    join_pills c_keep; center="$joined" cw="$joined_w"
    join_pills r_keep; right="$joined" rw="$joined_w"
    start=$(((avail - cw) / 2))
    ((start < lw + 1)) && start=$((lw + 1))
    ((cw == 0)) && start=$lw
    # Fits: center pills end before the right ones begin (with a gap).
    ((start + cw + (rw > 0 ? rw + 1 : 0) <= avail)) && break
    if ((${#r_keep[@]} > 0)); then unset 'r_keep[-1]'
    elif ((${#c_keep[@]} > 0)); then unset 'c_keep[-1]'
    else break; fi
  done
  local line="$left"
  ((cw > 0)) && line+="$(printf '%*s' $((start - lw)) '')${center}"
  if ((rw > 0)); then
    local used=$((cw > 0 ? start + cw : lw))
    line+="$(printf '%*s' $((avail - used - rw)) '')${right}"
  fi
  printf '%s\n' "$line"
}

pct_color() { # $1: integer percentage -> palette name
  if (($1 >= 80)); then echo red; elif (($1 >= 50)); then echo sand; else echo green; fi
}

# Sets $bar to a 5-cell bar for percentage $1, colored by severity.
bar() {
  local w=5 total i v col
  total=$(($1 * w * 8 / 100))
  ((total == 0 && $1 > 0)) && total=1
  col=$(pct_color "$1")
  bar="${track_bg}${F[$col]:-}"
  for ((i = 0; i < w; i++)); do
    v=$((total - i * 8))
    ((v > 8)) && v=8
    ((v < 0)) && v=0
    bar+="${eighths[v]}"
  done
  bar+="${pill_bg}"
}

# ---------------------------------------------------------------- fields --
# Rate limits are per account and only arrive after a session's first API
# response, so the last ones seen are cached and shown until they reset.
rl_cache="${XDG_RUNTIME_DIR:-/tmp}/claude-statusline/rate_limits.json"
rl_cached=""
[ -r "$rl_cache" ] && rl_cached="$(<"$rl_cache")"

# One jq pass; every value comes out shell-quoted, "" when absent. Booleans
# are stringified so an explicit false isn't mistaken for "missing".
eval "$(
  printf '%s' "$input" | jq -r --arg rl_cached "$rl_cached" '
    def s: if . == null then "" else tostring end;
    def pct: if . == null then "" else round | tostring end;
    def live: if . == null then null else with_entries(select((.value.resets_at // 0) > now)) end;
    (.rate_limits | if . == null or . == {} then null else . end) as $rl_live
    # A corrupt cache must not blank the whole status line.
    | .rate_limits = (($rl_live // ($rl_cached | fromjson? // null)) | live)
    | {
      model:        (.model.display_name // .model.id | s),
      version:      (.version | s),
      style:        (.output_style.name | s),
      session_id:   (.session_id | s),
      session_name: (.session_name | s),
      agent_name:   (.agent.name | s),
      agent_type:   (.agent.type | s),
      wt_name:      (.worktree.name | s),
      wt_branch:    (.worktree.branch | s),
      vim_mode:     (.vim.mode | s),
      effort:       (.effort.level | s),
      thinking:     (.thinking.enabled | s),
      # 0% before the first message rather than hiding the pill.
      ctx_used:     (.context_window
                     | if .used_percentage == null and .context_window_size != null then 0
                       else .used_percentage end | pct),
      ctx_left:     (.context_window.remaining_percentage | pct),
      ctx_size:     (.context_window.context_window_size | s),
      rl_5h:        (.rate_limits.five_hour.used_percentage | pct),
      rl_7d:        (.rate_limits.seven_day.used_percentage | pct),
      rl_spend:     (.rate_limits.spend_limit.used_percentage | pct),
      rl_5h_reset:  (.rate_limits.five_hour.resets_at | s),
      rl_7d_reset:  (.rate_limits.seven_day.resets_at | s),
      rl_spend_reset: (.rate_limits.spend_limit.resets_at | s),
      rl_live:      ($rl_live | if . == null then "" else tojson end),
      transcript:   (.transcript_path | s),
      cache_seen:   (.prompt_cache.caching_observed | s),
      cache_warm:   (.prompt_cache.warm | s),
      cache_hit:    (if .prompt_cache.hit_ratio == null then null else .prompt_cache.hit_ratio * 100 end | pct),
      cost_cents:   (if .cost.total_cost_usd == null then null else .cost.total_cost_usd * 100 | round end | s),
      dur_s:        (if .cost.total_duration_ms == null then null else .cost.total_duration_ms / 1000 | floor end | s),
      added:        (.cost.total_lines_added | s),
      removed:      (.cost.total_lines_removed | s),
      cwd:          (.workspace.current_dir // .cwd | s),
      project_dir:  (.workspace.project_dir | s),
      extra_dirs:   ((.workspace.added_dirs // []) | length | tostring),
      repo_host:    (.workspace.repo.host | s),
      pr_number:    (.pr.number | s),
      pr_state:     (.pr.review_state | s),
      pr_kind:      (.pr.kind | s)
    } | to_entries[] | "\(.key)=\(.value | @sh)"
  ' 2>/dev/null
)"

if [ -n "${rl_live:-}" ] && [ -z "${CLAUDE_STATUSLINE_READONLY:-}" ]; then
  mkdir -p "${rl_cache%/*}" 2>/dev/null
  printf '%s' "$rl_live" >"$rl_cache" 2>/dev/null
fi

human_duration() { # seconds -> 45s / 7m27s / 1h02m
  local s=$1
  if ((s >= 3600)); then printf '%dh%02dm' $((s / 3600)) $((s % 3600 / 60))
  elif ((s >= 60)); then printf '%dm%02ds' $((s / 60)) $((s % 60))
  else printf '%ds' "$s"; fi
}

human_count() { # 512 / 12.3k / 1.2M, one decimal below 100
  local n=$1 div unit
  if ((n >= 1000000)); then div=1000000 unit=M
  elif ((n >= 1000)); then div=1000 unit=k
  else echo "$n"; return; fi
  if ((n / div >= 100)); then echo "$((n / div))${unit}"
  else echo "$((n / div)).$((n * 10 / div % 10))${unit}"; fi
}

printf -v now '%(%s)T' -1

human_until() { # epoch -> time left, coarse: 3d4h / 2h13m / 13m
  local s=$(($1 - now))
  ((s < 0)) && s=0
  if ((s >= 86400)); then printf '%dd%dh' $((s / 86400)) $((s % 86400 / 3600))
  elif ((s >= 3600)); then printf '%dh%02dm' $((s / 3600)) $((s % 3600 / 60))
  else printf '%dm' $((s / 60)); fi
}

state_dir="${XDG_RUNTIME_DIR:-/tmp}/claude-statusline"
mkdir -p "$state_dir" 2>/dev/null

# Session token totals aren't in the payload (context_window only covers the
# current context), so sum message usage from the transcripts. Each file's
# byte offset and running totals are cached, so a render only parses the
# lines appended since the previous one.
tok_in=0 tok_out=0 tok_read=0 tok_write=0
scan_transcript() { # $1: transcript .jsonl
  local t="$1" st off=0 last=- i=0 o=0 r=0 w=0 size complete=false
  st="$state_dir/$(basename "$t").tok"
  [ -r "$st" ] && read -r off last i o r w <"$st"
  size=$(stat -c %s "$t" 2>/dev/null) || return
  ((size < off)) && off=0 last=- i=0 o=0 r=0 w=0 # file was rewritten
  if ((size > off)); then
    # A partially written last line is left for the next render.
    [ -z "$(tail -c1 "$t")" ] && complete=true
    read -r off last i o r w < <(
      tail -c +$((off + 1)) "$t" | head -c $((size - off)) | jq -Rnr \
        --argjson off "$off" --arg last "$last" --argjson complete "$complete" \
        --argjson acc "[$i,$o,$r,$w]" '
        [inputs] | (if $complete then . else .[:-1] end) as $lines
        # A message is logged once per content block with the same usage,
        # and those entries are consecutive: count each message id once.
        | reduce ($lines[] | fromjson? | select(.type == "assistant" and .message.usage != null)
                  | [.message.id, .message.usage]) as [$id, $u]
            ({last: $last, acc: $acc};
             if $id == .last then . else
               .last = $id
               | .acc = [.acc[0] + ($u.input_tokens // 0), .acc[1] + ($u.output_tokens // 0),
                         .acc[2] + ($u.cache_read_input_tokens // 0), .acc[3] + ($u.cache_creation_input_tokens // 0)]
             end)
        | "\($off + ($lines | map(utf8bytelength + 1) | add // 0)) \(.last // "-") \(.acc | map(tostring) | join(" "))"
      ' 2>/dev/null
    )
    printf '%s %s %s %s %s %s\n' "$off" "$last" "$i" "$o" "$r" "$w" >"$st" 2>/dev/null
  fi
  tok_in=$((tok_in + i)) tok_out=$((tok_out + o)) tok_read=$((tok_read + r)) tok_write=$((tok_write + w))
}
if [ -n "${transcript:-}" ] && [ -r "$transcript" ]; then
  scan_transcript "$transcript"
  for t in "${transcript%.jsonl}"/subagents/*.jsonl; do
    [ -r "$t" ] && scan_transcript "$t"
  done
fi

# Extra-usage spend isn't in the payload either; total_cost_usd is an
# API-price estimate of the whole session. Approximation: only cost accrued
# while a subscription window is exhausted (>= 100%) counts as extra usage.
extra_cents=""
if [ -n "${cost_cents:-}" ] && [ -n "${session_id:-}" ]; then
  cst="$state_dir/${session_id}.cost"
  last_cents="$cost_cents" extra_cents=0
  [ -r "$cst" ] && read -r last_cents extra_cents <"$cst"
  if ((cost_cents > last_cents)) && { ((${rl_5h:-0} >= 100)) || ((${rl_7d:-0} >= 100)); }; then
    extra_cents=$((extra_cents + cost_cents - last_cents))
  fi
  [ -z "${CLAUDE_STATUSLINE_READONLY:-}" ] && printf '%s %s\n' "$cost_cents" "$extra_cents" >"$cst" 2>/dev/null
fi


# Latest version of each model family: those show as just the family name
# ("opus"), anything older keeps its version ("sonnet 4.5"). Bump when a new
# model ships; CLAUDE_STATUSLINE_LATEST overrides it, e.g. "opus=5.5 sonnet=5".
declare -A latest=([fable]=5.1 [opus]=5.5 [sonnet]=5 [haiku]=4.5)
for kv in ${CLAUDE_STATUSLINE_LATEST:-}; do latest[${kv%%=*}]="${kv#*=}"; done
short_model() { # "Opus 5.5" -> "opus", "Sonnet 4.5" -> "sonnet 4.5"
  local family ver rest
  read -r family ver rest <<<"$1"
  family="${family,,}"
  if [ -n "$ver" ] && [ "${latest[$family]:-}" = "$ver" ]; then
    echo "${family}${rest:+ $rest}"
  else
    echo "${family}${ver:+ $ver}${rest:+ $rest}"
  fi
}

sep=" ${F[overlay0]:-}${g_dot}${fgdef} "

# ============================================================== line 1 ===
# Left: model and everything that limits the session (context, usage
# windows, extra spend). Right: token accounting.
p="${F[mauve]:-}${g_model} ${bold}$(short_model "${model:-?}")${nobold}"
if [ -n "${effort:-}" ]; then
  icon_var="g_effort_${effort}"
  # Warmer as effort goes up.
  case "$effort" in low) ecol=overlay2 ;; medium) ecol=sand ;; high) ecol=peach ;; xhigh) ecol=tangerine ;; *) ecol=cherry ;; esac
  # Unknown future levels fall back to the name.
  p+=" ${F[$ecol]:-}${!icon_var:-$effort} "
fi
# Thinking is on by default; only flag it when it's been turned off.
[ "${thinking:-}" = "false" ] && p+=" ${F[overlay1]:-}${g_think} off"
pill left1 "$p"

if [ -n "${ctx_used:-}" ]; then
  bar "$ctx_used"
  pill left1 "${F[$(pct_color "$ctx_used")]:-}${g_ctx} ${bar} ${ctx_used}%"
elif [ -n "${ctx_left:-}" ]; then
  pill left1 "${F[overlay1]:-}${g_ctx} ${ctx_left}% left"
fi

# One pill per usage window, with the time until it resets.
for win in "5h:${rl_5h:-}:${rl_5h_reset:-}" "7d:${rl_7d:-}:${rl_7d_reset:-}" \
  "spend:${rl_spend:-}:${rl_spend_reset:-}"; do
  IFS=: read -r name v resets_at <<<"$win"
  [ -z "$v" ] && continue
  bar "$v"
  p="${F[sky]:-}${g_limit} ${F[overlay2]:-}${name} ${bar} ${F[$(pct_color "$v")]:-}${v}%"
  [ -n "$resets_at" ] && p+=" ${F[overlay1]:-}${g_reset} $(human_until "$resets_at")"
  pill center1 "$p"
done

if ((${extra_cents:-0} > 0)); then
  pill center1 "${F[red]:-}${bold}${g_cost} $((extra_cents / 100)).$(printf '%02d' $((extra_cents % 100))) extra${nobold}"
fi

if ((tok_in + tok_out + tok_read + tok_write > 0)); then
  pill right1 "${F[blue]:-}${g_tokens} ${F[overlay1]:-}${g_in} ${F[blue]:-}$(human_count "$tok_in") ${F[overlay1]:-}${g_out} ${F[blue]:-}$(human_count "$tok_out")"
fi

# Cache state as icon + color (fire when warm, snowflake when cold) with the
# hit ratio, then how much was read from / written to the cache.
p=""
if [ "${cache_seen:-}" = "true" ]; then
  if [ "${cache_warm:-}" = "true" ]; then p="${F[tangerine]:-}${g_warm} "; else p="${F[sky]:-}${g_cold} "; fi
  [ -n "${cache_hit:-}" ] && p+="${cache_hit}%"
fi
if ((tok_read + tok_write > 0)); then
  p+="${p:+$sep}${F[overlay1]:-}${g_cache_read} ${F[teal]:-}$(human_count "$tok_read") ${F[overlay1]:-}${g_cache_write} ${F[teal]:-}$(human_count "$tok_write")"
fi
pill right1 "$p"

# ============================================================== line 2 ===
# Left: where we are (path, git, modes). Center: Linear ticket and PR stack.
# Right: session activity.
if [ -n "${cwd:-}" ]; then
  path="${cwd/#$HOME/\~}"
  parent="${path%/*}"
  [ "$parent" = "$path" ] && parent=""
  p="${F[turquoise]:-}${g_folder} ${parent:+${parent}/}${F[mint]:-}${bold}${path##*/}${nobold}"
  if [ -n "${project_dir:-}" ] && [ "$project_dir" != "$cwd" ]; then
    p+=" ${F[overlay1]:-}in ${project_dir##*/}"
  fi
  ((${extra_dirs:-0} > 0)) && p+=" ${F[overlay1]:-}+${extra_dirs}"
  pill left2 "$p"

  # Branch and ahead/behind from porcelain v2; line counts like git's
  # own --shortstat, plus untracked files.
  if gs=$(git -C "$cwd" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null); then
    head="" oid="" ahead=0 behind=0 untracked=0
    while IFS= read -r l; do
      case "$l" in
        "# branch.head "*) head="${l#\# branch.head }" ;;
        "# branch.oid "*) oid="${l#\# branch.oid }" ;;
        "# branch.ab "*)
          read -r _ _ a b <<<"$l"
          ahead="${a#+}" behind="${b#-}"
          ;;
        "? "*) untracked=$((untracked + 1)) ;;
      esac
    done <<<"$gs"
    [ "$head" = "(detached)" ] && head="${oid:0:7}"

    ins=0 del=0
    stat=$(git -C "$cwd" --no-optional-locks diff HEAD --shortstat 2>/dev/null)
    [[ $stat =~ ([0-9]+)\ insertion ]] && ins="${BASH_REMATCH[1]}"
    [[ $stat =~ ([0-9]+)\ deletion ]] && del="${BASH_REMATCH[1]}"

    case "${repo_host:-}" in
      *github*) icon="$g_github" ;;
      *gitlab*) icon="$g_gitlab" ;;
      *) icon="$g_git" ;;
    esac
    p="${F[turquoise]:-}${icon} ${head:0:25}"
    ((ahead > 0)) && p+=" ${F[violet]:-}${g_ahead} ${ahead}"
    ((behind > 0)) && p+=" ${F[mauve]:-}${g_behind} ${behind}"
    ((ins > 0)) && p+=" ${F[green]:-}+${ins}"
    ((del > 0)) && p+=" ${F[red]:-}-${del}"
    ((untracked > 0)) && p+=" ${F[overlay1]:-}?${untracked}"
    pill left2 "$p"
  fi
fi

# ------------------------------------------------------- ticket and PRs --
# Center of line 2: the Linear ticket and the PR stack of the current branch.
# Open PRs come from `gh pr list`, cached per repo and refreshed in the
# background so a render never waits on the network. The stack is the chain
# of PRs whose base is another PR's head, walked down to the trunk and up
# through the PRs based on this one.
stack=() cur_title=""
if [ -n "${head:-}" ] && top=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null) &&
  { [[ ${repo_host:-} == *github* ]] ||
    { [ -z "${repo_host:-}" ] && [[ $(git -C "$cwd" remote get-url origin 2>/dev/null) == *github* ]]; }; } &&
  command -v gh >/dev/null; then
  prs_cache="$state_dir/$(printf '%s' "$top" | md5sum | cut -c1-16).prs.json"
  lock="$prs_cache.lock"
  mtime=$(stat -c %Y "$prs_cache" 2>/dev/null || echo 0)
  # A refresh killed mid-way must not block the next ones forever.
  [ -d "$lock" ] && ((now - $(stat -c %Y "$lock" 2>/dev/null || echo 0) > 60)) && rmdir "$lock" 2>/dev/null
  if ((now - mtime > ${CLAUDE_STATUSLINE_PR_TTL:-60})) && mkdir "$lock" 2>/dev/null; then
    (
      cd "$top" || exit
      if GH_PROMPT_DISABLED=1 timeout 15 gh pr list --state open --limit 200 \
        --json number,headRefName,baseRefName,isDraft,reviewDecision,title >"$prs_cache.tmp"; then
        mv "$prs_cache.tmp" "$prs_cache"
      else
        # Not authenticated, offline...: back off for a TTL instead of
        # retrying on every render.
        rm -f "$prs_cache.tmp"
        if [ -e "$prs_cache" ]; then touch "$prs_cache"; else echo '[]' >"$prs_cache"; fi
      fi
      rmdir "$lock"
    ) </dev/null >/dev/null 2>&1 &
  fi
  if [ -r "$prs_cache" ]; then
    # One line per PR, trunk first: number, draft, review decision, current.
    mapfile -t stack < <(jq -r --arg head "$head" '
      . as $prs
      | (map({key: .headRefName, value: .}) | from_entries) as $by
      | def down($b; $n):
          if $n > 20 or $by[$b] == null then []
          else down($by[$b].baseRefName; $n + 1) + [$by[$b]] end;
        def up($h; $n):
          ([$prs[] | select(.baseRefName == $h)] | sort_by(.number)) as $c
          | if $n > 20 or ($c | length) == 0 then []
            else [$c[0]] + up($c[0].headRefName; $n + 1) end;
        select($by[$head] != null)
      | (down($head; 0) + up($head; 0))[]
      | "\(.number) \(.isDraft) \(.reviewDecision // "" | if . == "" then "-" else . end) \(.headRefName == $head)"
    ' "$prs_cache" 2>/dev/null)
    cur_title=$(jq -r --arg head "$head" '.[] | select(.headRefName == $head) | .title' "$prs_cache" 2>/dev/null)
  fi
fi

# Linear ticket: from the branch name (Linear's "user/eng-123-title"), else
# from the PR title ("[ENG-123] ...").
ticket=""
for src in "${head:-}" "$cur_title"; do
  if [[ ${src,,} =~ (^|[^a-z0-9])([a-z][a-z0-9]{1,9}-[0-9]+)($|[^0-9]) ]]; then
    ticket="${BASH_REMATCH[2]^^}"
    break
  fi
done
[ -n "$ticket" ] && pill center2 "${F[blue]:-}${g_ticket} ${bold}${ticket}${nobold}"

label="PR"
[ "${pr_kind:-}" = "mr" ] && label="MR"
if ((${#stack[@]} > 0)); then
  p="${F[purple]:-}${g_pr} "
  ((${#stack[@]} > 1)) && p+="${F[overlay1]:-}${g_stack} "
  first=1
  for l in "${stack[@]}"; do
    read -r num draft review current <<<"$l"
    ((first)) || p+=" ${F[overlay0]:-}${g_chevron} "
    first=0
    # Drafts dimmed, others by review state; the current one bold.
    case "$draft:$review" in
      true:*) col=overlay1 ;;
      *:APPROVED) col=green ;;
      *:CHANGES_REQUESTED) col=red ;;
      *) col=purple ;;
    esac
    if [ "$current" = "true" ]; then
      p+="${F[$col]:-}${bold}#${num}${nobold}"
    else
      p+="${F[$col]:-}#${num}"
    fi
  done
  pill center2 "${p}${pr_state:+ ${F[overlay1]:-}${pr_state}}"
elif [ -n "${pr_number:-}" ]; then
  # No gh data (yet, or not GitHub): the PR Claude Code knows about.
  pill center2 "${F[purple]:-}${g_pr} ${label}#${pr_number}${pr_state:+ ${F[overlay1]:-}${pr_state}}"
fi

[ -n "${style:-}" ] && [ "$style" != "default" ] && pill left2 "${F[blue]:-}${g_style} ${style}"
if [ -n "${agent_name:-}" ]; then
  pill left2 "${F[violet]:-}${g_agent} ${agent_name}${agent_type:+ ${F[overlay1]:-}(${agent_type})}"
fi
[ -n "${wt_name:-}" ] && pill left2 "${F[purple]:-}${g_tree} ${wt_name}${wt_branch:+ ${F[overlay1]:-}${g_branch} ${wt_branch}}"
[ -n "${vim_mode:-}" ] && pill left2 "${F[green]:-}${g_vim} ${vim_mode}"

# Lines Claude changed this session.
if ((${added:-0} + ${removed:-0} > 0)); then
  pill right2 "${F[overlay2]:-}${g_working} ${F[green]:-}+${added:-0} ${F[red]:-}-${removed:-0}"
fi
[ -n "${dur_s:-}" ] && pill right2 "${F[overlay2]:-}${g_clock} $(human_duration "$dur_s")"
[ -n "${session_name:-}" ] && pill right2 "${F[overlay2]:-}${g_session} ${session_name}"

join_line left1 center1 right1
join_line left2 center2 right2
