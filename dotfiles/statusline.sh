#!/bin/bash
input=$(cat)

# Single jq pass - statusline runs on every UI update, so one jq spawn
# instead of many. Unit separator (\x1f) as delimiter: unlike tab it is not
# IFS whitespace, so empty fields survive instead of collapsing and shifting
# every later column.
IFS=$'\x1f' read -r MODEL PCT TOKENS SIZE FIVE_H FIVE_H_RESET WEEK WEEK_RESET CWD PR_NUM PR_STATE COST ADDED REMOVED CACHE_WARM CACHE_HIT EFFORT FAST THINK <<< "$(printf '%s' "$input" | jq -r '[
  (.model.display_name // "?"),
  ((.context_window.used_percentage // 0) | floor),
  (.context_window.total_input_tokens // 0),
  (.context_window.context_window_size // 200000),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.five_hour.resets_at // ""),
  (.rate_limits.seven_day.used_percentage // ""),
  (.rate_limits.seven_day.resets_at // ""),
  (.workspace.current_dir // ""),
  (.pr.number // ""),
  (.pr.review_state // ""),
  (.cost.total_cost_usd // ""),
  (.cost.total_lines_added // 0),
  (.cost.total_lines_removed // 0),
  (.prompt_cache.warm | if . == null then "" else tostring end),
  (.prompt_cache.hit_ratio // "" | if type == "number" then (. * 100 | floor) else "" end),
  (.effort.level // ""),
  (.fast_mode // false),
  (.thinking.enabled | if . == null then true else . end)
] | join("\u001f")' 2>/dev/null)"

# Fallbacks if jq failed or fields absent
[[ "$PCT"     =~ ^[0-9]+$ ]] || PCT=0
[[ "$TOKENS"  =~ ^[0-9]+$ ]] || TOKENS=0
[[ "$SIZE"    =~ ^[0-9]+$ ]] || SIZE=200000
[[ "$ADDED"   =~ ^[0-9]+$ ]] || ADDED=0
[[ "$REMOVED" =~ ^[0-9]+$ ]] || REMOVED=0

# Colors
GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; CYAN='\033[36m'; DIM='\033[2m'; RESET='\033[0m'

# Location: dir basename + git branch (detached HEAD shows short SHA) + dirty star
LOC=""
if [ -n "$CWD" ]; then
  LOC="${CWD##*/}"
  BRANCH=$(git -C "$CWD" symbolic-ref --short -q HEAD 2>/dev/null || git -C "$CWD" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$BRANCH" ]; then
    DIRTY=""
    [ -n "$(git -C "$CWD" status --porcelain 2>/dev/null | head -c1)" ] && DIRTY="${YELLOW}*${RESET}"
    LOC="${LOC}:${BRANCH}${DIRTY}"
  fi
fi

# Open PR for the current branch (provided by the statusline API when one exists)
PR=""
if [ -n "$PR_NUM" ]; then
  case "$PR_STATE" in
    approved)          PR=" ${GREEN}PR#${PR_NUM} ok${RESET}" ;;
    changes_requested) PR=" ${RED}PR#${PR_NUM} chg${RESET}" ;;
    draft)             PR=" ${DIM}PR#${PR_NUM} draft${RESET}" ;;
    *)                 PR=" ${YELLOW}PR#${PR_NUM}${RESET}" ;;
  esac
fi

# Context bar (10 chars wide)
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
[ "$FILLED" -gt "$BAR_WIDTH" ] && FILLED=$BAR_WIDTH
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /▓}"
[ "$EMPTY"  -gt 0 ] && printf -v PAD  "%${EMPTY}s"  && BAR="${BAR}${PAD// /░}"

# Pick context bar color: green < 70%, yellow < 85%, red >= 85%
if   [ "$PCT" -ge 85 ]; then BC="$RED"
elif [ "$PCT" -ge 70 ]; then BC="$YELLOW"
else BC="$GREEN"; fi

# Absolute tokens (e.g. 82k/200k) + compact nudge from 70% on
TOK="$((TOKENS / 1000))k/$((SIZE / 1000))k"
HINT=""
[ "$PCT" -ge 70 ] && HINT=" ${BC}-> /compact${RESET}"

CTX_LINE="${CYAN}[${MODEL}]${RESET}${LOC:+ $LOC}${PR} ctx: ${BC}${BAR} ${PCT}%${RESET} ${TOK}${HINT}"

# Time until a limit window resets, as " (2h10m)" / " (3d4h)"; empty if unknown
fmt_reset() {
  [[ "$1" =~ ^[0-9]+$ ]] || return
  local diff=$(( $1 - $(date +%s) ))
  [ "$diff" -le 0 ] && return
  if [ "$diff" -ge 86400 ]; then
    printf ' (%dd%dh)' $(( diff / 86400 )) $(( (diff % 86400) / 3600 ))
  else
    printf ' (%dh%dm)' $(( diff / 3600 )) $(( (diff % 3600) / 60 ))
  fi
}

# Rate limits line (only shown when data is available)
LIMITS=""
if [ -n "$FIVE_H" ]; then
  FH=$(printf '%.0f' "$FIVE_H" 2>/dev/null) || FH=0
  [ "$FH" -ge 85 ] && FHC="$RED" || { [ "$FH" -ge 60 ] && FHC="$YELLOW" || FHC="$GREEN"; }
  LIMITS="${FHC}5h: ${FH}%${RESET}$(fmt_reset "$FIVE_H_RESET")"
fi
if [ -n "$WEEK" ]; then
  WK=$(printf '%.0f' "$WEEK" 2>/dev/null) || WK=0
  [ "$WK" -ge 85 ] && WKC="$RED" || { [ "$WK" -ge 60 ] && WKC="$YELLOW" || WKC="$GREEN"; }
  LIMITS="${LIMITS:+$LIMITS  }${WKC}7d: ${WK}%${RESET}$(fmt_reset "$WEEK_RESET")"
fi

# Session cost + line delta (shown once non-zero)
SPEND=""
if [ -n "$COST" ]; then
  LC_ALL=C printf -v COSTF '%.2f' "$COST" 2>/dev/null || COSTF="$COST"
  [ "$COSTF" != "0.00" ] && SPEND="\$${COSTF}"
fi
[ $((ADDED + REMOVED)) -gt 0 ] && SPEND="${SPEND:+$SPEND }${GREEN}+${ADDED}${RESET}/${RED}-${REMOVED}${RESET}"

# Prompt cache: hit ratio while warm, loud when cold (next request re-caches)
CACHE=""
if [ "$CACHE_WARM" = "true" ]; then
  CACHE="${GREEN}cache${CACHE_HIT:+ ${CACHE_HIT}%}${RESET}"
elif [ "$CACHE_WARM" = "false" ]; then
  CACHE="${RED}cache cold${RESET}"
fi

# Mode flags: effort always; fast/no-think only when they deviate from default
MODES="$EFFORT"
[ "$FAST" = "true" ] && MODES="${MODES:+$MODES }fast"
[ "$THINK" = "false" ] && MODES="${MODES:+$MODES }no-think"

LINE2="$LIMITS"
[ -n "$SPEND" ] && LINE2="${LINE2:+$LINE2  }$SPEND"
[ -n "$CACHE" ] && LINE2="${LINE2:+$LINE2  }$CACHE"
[ -n "$MODES" ] && LINE2="${LINE2:+$LINE2  }${DIM}${MODES}${RESET}"

echo -e "$CTX_LINE"
[ -n "$LINE2" ] && echo -e "$LINE2"
exit 0
