#!/bin/sh
set -eu
cd "$(dirname "$0")/.."

git config --file git/config --list >/dev/null
zsh -n zsh/zshrc

check_tmp=$(mktemp -d)
tmux_socket="config-check-$$"
trap 'tmux -L "$tmux_socket" kill-server >/dev/null 2>&1 || :; rm -rf "$check_tmp"' 0
HOME="$check_tmp" vim -Nu vim/vimrc -n -es '+qa!'
# RgFind: explicit ./ and absolute paths must resolve, fuzzy names must match
if command -v rg >/dev/null; then
  HOME="$check_tmp" vim -Nu vim/vimrc -n -es \
    "+if RgFind('./vim/vimrc', 0) != ['./vim/vimrc'] | cq | endif" \
    "+if RgFind('$PWD/vim/vimrc', 0) != ['$PWD/vim/vimrc'] | cq | endif" \
    "+if index(RgFind('vimrc', 0), 'vim/vimrc') < 0 | cq | endif" \
    '+qa!' || { echo "vimrc: RgFind path resolution broken" >&2; exit 1; }
fi

tmux_config="$check_tmp/tmux.conf"
sed '/^[[:space:]]*set -g @plugin /d; /^[[:space:]]*run /d' tmux/tmux.conf > "$tmux_config"
tmux -L "$tmux_socket" -f "$tmux_config" new-session -d -s check /usr/bin/true

ghostty +validate-config --config-file="$PWD/ghostty/config"

mkdir "$check_tmp/xdg"
ln -s "$PWD/herdr" "$check_tmp/xdg/herdr"
XDG_CONFIG_HOME="$check_tmp/xdg" herdr config check >/dev/null

# herdr-new regressions, run with stub fzf/herdr
stub="$check_tmp/stub"; mkdir "$stub" "$check_tmp/home"
cat > "$stub/fzf" <<'STUB'
#!/bin/sh
case "$*" in
  *Agent*) [ -n "${FZF_CANCEL_AGENT:-}" ] && exit 130; echo claude ;;
  *) if [ -n "${FZF_EXPECT:-}" ]; then grep -qx "$FZF_EXPECT" || exit 1; fi; echo "$FZF_PROJECT" ;;
esac
STUB
cat > "$stub/herdr" <<'STUB'
#!/bin/sh
echo "$*" >> "$HERDR_LOG"
case "${HERDR_RESPONSE:-ok}" in
  ok) echo '{"result":{"root_pane":{"pane_id":"p1"}}}' ;;
  missing) echo '{"result":{}}' ;;
  empty) echo '{"result":{"root_pane":{"pane_id":""}}}' ;;
  *) echo 'not json' ;;
esac
STUB
chmod +x "$stub/fzf" "$stub/herdr"
mkdir -p "$check_tmp/home/Documents/Projects/foo"
export HERDR_LOG="$check_tmp/herdr.log" HERDR_BIN_PATH="$stub/herdr"
# cancelled agent picker must not create anything
: > "$HERDR_LOG"
echo task | HOME="$check_tmp/home" PATH="$stub:$PATH" FZF_CANCEL_AGENT=1 HERDR_ACTIVE_PANE_CWD="$check_tmp" herdr/herdr-new --tab >/dev/null
[ ! -s "$HERDR_LOG" ] || { echo "herdr-new: cancelled picker still ran herdr" >&2; exit 1; }
# cancelled agent picker in workspace mode must not create a project dir
: > "$HERDR_LOG"
HOME="$check_tmp/home" PATH="$stub:$PATH" FZF_CANCEL_AGENT=1 FZF_PROJECT=newproj herdr/herdr-new >/dev/null
{ [ ! -s "$HERDR_LOG" ] && [ ! -e "$check_tmp/home/Projects/newproj" ]; } || { echo "herdr-new: cancelled picker left side effects" >&2; exit 1; }
# project under a nested root must keep its path
: > "$HERDR_LOG"
HOME="$check_tmp/home" PATH="$stub:$PATH" HERDR_ROOTS=Documents/Projects FZF_PROJECT=Documents/Projects/foo herdr/herdr-new >/dev/null
grep -q "workspace create --cwd .*/home/Documents/Projects/foo " "$HERDR_LOG" || { echo "herdr-new: nested root resolved wrongly" >&2; exit 1; }
# a root that is itself a repo must be listed and keep its path
mkdir -p "$check_tmp/home/Solo/.git"
: > "$HERDR_LOG"
HOME="$check_tmp/home" PATH="$stub:$PATH" HERDR_ROOTS=Solo FZF_EXPECT=Solo FZF_PROJECT=Solo herdr/herdr-new >/dev/null
grep -q "workspace create --cwd .*/home/Solo " "$HERDR_LOG" || { echo "herdr-new: repo at a root not listed or resolved wrongly" >&2; exit 1; }
# a missing, empty, or malformed pane id must fail before any pane command runs, in both modes
for resp in missing empty bad; do
  : > "$HERDR_LOG"
  if echo task | HOME="$check_tmp/home" PATH="$stub:$PATH" HERDR_RESPONSE=$resp HERDR_ACTIVE_PANE_CWD="$check_tmp" herdr/herdr-new --tab >/dev/null 2>&1; then
    echo "herdr-new --tab: $resp pane id did not fail" >&2; exit 1
  fi
  if HOME="$check_tmp/home" PATH="$stub:$PATH" HERDR_RESPONSE=$resp HERDR_ROOTS=Documents/Projects FZF_PROJECT=Documents/Projects/foo herdr/herdr-new >/dev/null 2>&1; then
    echo "herdr-new: $resp pane id did not fail" >&2; exit 1
  fi
  ! grep -q '^pane ' "$HERDR_LOG" || { echo "herdr-new: $resp pane id still ran pane commands" >&2; exit 1; }
done
printf 'Config checks passed.\n'
