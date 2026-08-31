#!/bin/bash
# Merged statusline: personal context/limits lines from statusline.sh,
# plus a daily.dev headline. stdin JSON is captured once and fed to both.
input=$(cat)

printf '%s' "$input" | "$HOME/.claude/statusline.sh"

# Glob resolves the most recently installed plugin version (path is version-pinned).
# Fail-soft: a missing/broken plugin must never blank the whole statusline.
# stdin from /dev/null: with no session JSON the script skips its own
# "<model> · " prefix, which would duplicate statusline.sh's model tag.
DAILY_DIR=$(ls -td "$HOME/.claude/plugins/cache/daily-dev/daily-dev"/*/ 2>/dev/null | head -1)
[ -n "$DAILY_DIR" ] && node "${DAILY_DIR}statusline/statusline.mjs" < /dev/null 2>/dev/null

exit 0
