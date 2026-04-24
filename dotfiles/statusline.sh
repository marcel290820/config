#!/bin/bash
input=$(cat)

# Model & context
MODEL=$(echo "$input" | jq -r '.model.display_name')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# Rate limits (Pro/Max only — may be absent)
FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
FIVE_H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

# Colors
GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; CYAN='\033[36m'; RESET='\033[0m'

# Context bar (10 chars wide)
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /▓}"
[ "$EMPTY"  -gt 0 ] && printf -v PAD  "%${EMPTY}s"  && BAR="${BAR}${PAD// /░}"

# Pick context bar color: green < 70%, yellow < 85%, red >= 85%
if   [ "$PCT" -ge 85 ]; then BC="$RED"
elif [ "$PCT" -ge 70 ]; then BC="$YELLOW"
else BC="$GREEN"; fi

CTX_LINE="${CYAN}[${MODEL}]${RESET} ctx: ${BC}${BAR} ${PCT}%${RESET}"

# Rate limits line (only shown when data is available)
LIMITS=""
if [ -n "$FIVE_H" ]; then
  FH=$(printf '%.0f' "$FIVE_H")
  [ "$FH" -ge 85 ] && FHC="$RED" || { [ "$FH" -ge 60 ] && FHC="$YELLOW" || FHC="$GREEN"; }
  
  # Time until reset
  RESET_STR=""
  if [ -n "$FIVE_H_RESET" ]; then
    NOW=$(date +%s)
    DIFF=$(( FIVE_H_RESET - NOW ))
    if [ "$DIFF" -gt 0 ]; then
      HH=$(( DIFF / 3600 )); MM=$(( (DIFF % 3600) / 60 ))
      RESET_STR=" (resets ${HH}h${MM}m)"
    fi
  fi
  LIMITS="${FHC}5h: ${FH}%${RESET}${RESET_STR}"
fi
if [ -n "$WEEK" ]; then
  WK=$(printf '%.0f' "$WEEK")
  [ "$WK" -ge 85 ] && WKC="$RED" || { [ "$WK" -ge 60 ] && WKC="$YELLOW" || WKC="$GREEN"; }
  LIMITS="${LIMITS:+$LIMITS  }${WKC}7d: ${WK}%${RESET}"
fi

echo -e "$CTX_LINE"
[ -n "$LIMITS" ] && echo -e "limits: $LIMITS"

