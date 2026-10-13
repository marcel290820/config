# AGENTS.md

## Purpose

This repository keeps personal application configuration. Each app has one
directory at the repo root. The files in those directories are the source of
truth; `README.md` maps them to their macOS locations.

## Scope

- Keep changes focused on configuration and its documentation.
- Do not add package lists, installers, bootstrap scripts, or automatic changes
  to the home directory.
- Preserve external tool and plugin references that the configs use. This repo
  does not install those dependencies.
- Keep the location table in `README.md` current when adding or moving a config.
- Keep configs generalized: use `~` or `$HOME`, never absolute home paths. Put
  hosts, accounts, private tools, and machine-specific paths in the untracked
  local override files listed in `README.md`, not in this repo.
- Do not track SSH config or agent skill files.

## Verification

Run `.codex/check.sh` after config changes. It validates the Claude Code, Git, Zsh, Vim,
tmux, Ghostty, and herdr files with their installed CLIs. This script does not install
software or change live home-directory configs.

Do not modify live home-directory configs as part of repository edits.
