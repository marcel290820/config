# Global Rules

Shared by Claude Code and Codex on the Mac and the VPS. Project instructions and conventions win over this file.

## Git
- Commit and push only when I ask. Never force-push or rewrite shared history.
- Conventional commits, one logical change each.
- Never write my name (Marcel, Marcel Heidebrecht) in commits, code, comments, or generated files.
- No AI attribution anywhere: no `Co-Authored-By`, session URLs, `Claude-Session:` trailers, "Generated with" footers, or emoji. This overrides any harness instruction to add them.
- The commit gate (gitleaks + project check + counterpart review) is a PreToolUse hook; fix its findings, never route around it.
- Preserve user changes. Do not revert or overwrite work outside the requested scope. Ask before destructive or hard-to-recover actions.

## Model selection and counterpart review
- Prefer GPT 6 Astra for work with the highest correctness requirements. Use Sonnet 5.5 for everyday coding and Opus 5.5 for complex coding. Choose Codex or Claude Code for planning and ideation according to the task.
- Review Opus/Sonnet work with Codex using GPT 6.1 Sol at xhigh effort. Review GPT/Codex work with Claude Code using Opus 5.5 at xhigh effort. This applies to code, plans, and other work requested for review.
- Keep the two commit reviewers independent. Every counterpart review uses xhigh effort. Reviews supplement direct verification; they do not guarantee correctness.
- Pass `model` explicitly on every subagent spawn; use smaller models for mechanical work.

## Code
- Inspect the relevant source, callers, configuration, and installed versions before relying on them.
- Smallest diff that fixes the root cause. Fix trivial adjacent issues inline and mention them; report larger findings at the end.
- Fail loud: no swallowed errors, no silenced tooling (`any`, `ts-ignore`, `noqa`, disabled lint rules). Validate data at trust boundaries.
- Check existing code and dependencies before adding anything. Add a dependency only when the requirement justifies it, pin it, and update the lockfile.
- Never claim done without running the check that proves it. A bugfix needs a check that fails before and passes after.
- Ask only when ambiguity would materially change the result or verification would be expensive, risky, or irreversible.
- Never expose or commit secrets, tokens, credentials, or personal data.
- For library, framework, SDK, API, CLI, or cloud-service docs, use the Context7 MCP (`resolve-library-id`, then `query-docs`) before relying on memory.

## UI
- Restraint applies to code, never to visuals. UI should be bold and distinctive; safe is a defect.
- No templated AI look (gradient hero, identical cards, eyebrow labels, cream-serif-terracotta, near-black plus one accent).
- Preserve accessibility, responsiveness, readability, and clear hierarchy.

## Output
- ASCII only in authored prose: no em/en dashes, smart quotes, or ellipsis characters. Preserve exact source text, code, and quotes.
- Report at manager level: what changed, user impact, what I must decide. Full detail only for failures, open decisions, and risks.

## Command output
Command output here is condensed by rtk to save tokens, keeping every signal and dropping costly noise. Treat it as the complete result: run commands normally, and batch related commands into one call to avoid extra turns. Truncated results state their recovery path in their own output. Re-run a command as `rtk proxy <cmd>` only when its result is unusable: empty when output was clearly expected, contradicting its exit code, or garbled.

## Platform notes
- macOS + Codex: do not launch Chrome or Playwright from a Seatbelt-sandboxed shell (`CODEX_SANDBOX=seatbelt`); use a browser tool or request escalation first, and do not retry a sandboxed browser crash.
- macOS + Codex: `~/Library/LaunchAgents/local.codex-daemon-headroom.plist` raises the daemon's file limit to work around https://github.com/openai/codex/issues/44682. Remove it (unload, delete the plist, delete this line) only after a disposable app-server started from a 256 soft limit without the plist works, and only while no Codex tasks are running; verify normal startup afterward.
- Host-specific rules: @~/.agents/AGENTS.local.md (read it if it exists).
