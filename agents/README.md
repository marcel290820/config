# AI agent setup

Global instructions shared by Claude Code and Codex, plus the list of skills
and tools in use. The skill files themselves are not tracked here.

| Repo path | Live location | Read by |
| --- | --- | --- |
| `AGENTS.md` | `~/.agents/AGENTS.md` | Claude Code via `~/.claude/CLAUDE.md` (`@~/.agents/AGENTS.md`), Codex via symlink `~/.codex/AGENTS.md` |
| `~/.agents/AGENTS.local.md` (untracked) | same | Both, via the `@` import line in `AGENTS.md` |

## Skills

Installed in `~/.agents/skills/<name>/` (Codex reads them directly, Claude Code
via symlinks in `~/.claude/skills/`). Main skills are in bold. Upstream sources
come from `~/.agents/.skill-lock.json`.

| Skill | Source |
| --- | --- |
| **i-have-adhd** | `ayghri/i-have-adhd` |
| **humanizer** | `blader/humanizer` |
| **writing-clearly-and-concisely** | `softaworks/agent-toolkit` |
| **asd-ste100** | `danyuchn/asd-ste100-skill` |
| **frontend-design** | `anthropics/skills` |
| **playwright-cli** | ships with npm `@playwright/cli` |
| herdr | `herdrdev/herdr` |

## Tools

- Ponytail: Claude Code plugin `ponytail@ponytail`
- RTK: `rtk` CLI, Claude Code `PreToolUse` hook `rtk hook claude`
- Context7: MCP server (Claude Code user scope)
- Playwright CLI: `playwright-cli` (npm global) plus the skill above

## Plugins

- Security Guidance: `security-guidance@claude-plugins-official`
- Claude Security: `claude-security@claude-plugins-official`

## Custom

- Adversarial review by the other provider (Claude Code reviews Codex work,
  Codex reviews Claude Code work): plugin `counterpart-review@personal-plugins`,
  source in the `claude-plugins` repo
