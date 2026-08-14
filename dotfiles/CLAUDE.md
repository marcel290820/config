# Global Claude Code Configuration

## Identity & Privacy
- **Never include my name in any commit message.** Do not use "Marcel" or "Marcel Heidebrecht" anywhere in commit messages, code comments, or generated content.
- Use generic authorship like "refactor:", "fix:", "feat:" (conventional commits) - no personal names.

---

## Mandatory Skill Usage Rules
The following skills must be loaded automatically based on context - do not wait to be asked.

### Frontend / UI Work
- **Trigger:** Any task involving HTML, CSS, JSX, TSX, Vue, Svelte, UI components, layouts, design systems, or visual output.
- **Action:** Always load and apply the `frontend-design` skill before writing any UI code or markup.

### Writing & Copy
- **Trigger:** Any user-facing text, external-facing writing, documentation, README content, commit descriptions, PR descriptions, API descriptions, UI copy, or any natural-language output a human will read.
- **Action:** Always load and apply **both** `humanizer` AND `writing-clearly-and-concisely` together before writing any prose. `humanizer` removes AI-style patterns; `writing-clearly-and-concisely` ensures directness, clarity, and plain language. Neither is optional when writing for humans.

### Karpathy Engineering Guidelines
- **Trigger:** Any software engineering task - code architecture, model code, training scripts, system design, debugging, or general coding work.
- **Action:** Always load and apply the `andrej-karpathy-skills:karpathy-guidelines` skill as a baseline engineering standard.

### YAGNI / Lean Software Development
- **Trigger:** Any software development task where scope, feature set, or abstraction level is a decision point - new features, refactors, API design, architecture, or any "should I build X now or later" question.
- **Action:** Always load and apply the `/ponytail` skill ladder to enforce YAGNI (You Aren't Gonna Need It). Build only what the current requirement demands; do not add speculative generality, configuration, or abstraction for needs that have not yet materialized. When the skill flags over-engineering, cut scope rather than justify it. This stacks on top of the Karpathy guidelines - load both; `/ponytail` governs scope, Karpathy governs how the in-scope code is written.

### Focused Output (i-have-adhd)
- **Trigger:** Any turn where the user wants a decision or an action, not a survey. Concretely: debugging, "how do I fix X", "what's wrong with Y", a next-step request, a task with an obvious single next move, or any moment where the answer is one action and broad explanation would bury it.
- **Not triggered by:** explicit requests to explain, compare, teach, or explore ("explain how X works", "walk me through", "what are my options", "why does X happen"). When the user asks for breadth, give breadth.
- **Action:** Load and apply `i-have-adhd`. Lead with the next action, number multi-step tasks, end with one concrete next step, cap lists at 5, no preamble or closers.
- **On conflict:** the Next steps section below still applies. The skill's "end with one concrete next step" and this file's "Next steps" section are the same closer, so satisfy both with a single "Next steps:" block, not two.

### CI/CD Setup
- **Trigger:** Starting a new project, or beginning work in a repo whose `.github/workflows` is missing, empty, or does not gate merges. Also any question about CI, pipelines, GitHub Actions, or release automation.
- **Action:** Load and apply the `ci-setup` skill. On a new project, set CI up before the first feature. On an existing repo, name what is unprotected, ask once whether to add a pipeline, and respect the answer for the rest of the session.

### Finding New Skills
- **Trigger:** Whenever a task or domain arises that might benefit from a specialized skill not already listed - e.g. a new framework, an unfamiliar domain, a request for specialized tooling.
- **Action:** Load and use the `find-skills` skill to discover and suggest relevant skills before proceeding.

---

| Context | Skill to Load |
|---|---|
| HTML, CSS, JSX/TSX, UI components, layouts | `frontend-design` |
| Any prose, copy, docs, or text for humans | `humanizer` + `writing-clearly-and-concisely` |
| All coding and engineering tasks | `andrej-karpathy-skills:karpathy-guidelines` |
| Software dev where scope or abstraction is a decision | `/ponytail` (YAGNI ladder) |
| User wants a decision or action, not a survey | `i-have-adhd` |
| New project, or a repo with no CI gate | `ci-setup` |
| Unknown domain or potentially specialized task | `find-skills` |

These are **mandatory defaults**, not optional suggestions. Load them proactively based on context without waiting for an explicit instruction.

---

## Character & Symbol Rules
- **ASCII only in all output.** Never use em dashes, en dashes, curly/smart quotes, ellipsis characters, non-breaking spaces, or any other non-ASCII typographic symbols. Use a regular hyphen (-), straight quotes (" and '), and three periods (...) instead. These characters signal AI-generated text and a human writing by hand would not produce them.

---

## Next Steps / Open TODOs
- **End every response with a "Next steps" section.** After completing any turn, list the open TODOs, follow-ups, or next actions so they are never lost track of.
- Keep it short: a few bullet points of what is pending, what comes next, or what is blocked.
- If nothing is genuinely pending, state that explicitly (e.g. "Next steps: none, task complete") rather than omitting the section.

---

## Summaries and Reporting
I act as the manager; the agent codes. Report at that level.

- End-of-task summaries stay high level: what changed, how it affects features and users of the app, and anything I need to decide or act on.
- Skip code-level narration: file names, line numbers, import chains, test-count arithmetic, and the story of how a bug was found. The commits and diffs hold that detail; I read them when I want it.
- An issue you already found and fixed gets one line: what it was, why it mattered, and the commit hash. Keep the outcome, drop the debugging story.
- Full detail belongs only where I must act: unresolved failures (with real output), open decisions, and remaining risks. The Verification rules still apply - run the checks and state the result - but report the outcome, not the narrative.

---

## Design Guidelines
- **Simplicity first, always.** Default to clean, lean, minimal layouts with generous whitespace and a restrained palette; refined or modern polish is welcome only when it serves clarity, never decoration for its own sake. When in doubt, remove rather than add.
- **No generic AI styling.** Do not default to the colorful, gradient-heavy Bootstrap/Tailwind look that signals templated AI output. Build exactly what the task requires, no more and no less; if a requirement isn't stated, don't invent color, ornament, or visual noise to fill the space.

---

## General Coding Standards

### Precedence
- The project's own conventions win. Existing code style, a local CLAUDE.md, lint config, and framework idioms override anything here. Match the file you are editing before applying a preference from this file.

### Writing code
- Prefer clear, minimal, readable code over clever abstractions.
- Match the surrounding code: naming, structure, error handling, comment density. New code should not be identifiable as new.
- Comments explain why, not what. No commented-out code and no dead branches kept "just in case" - delete them, git remembers.
- No magic values. Hardcoded URLs, keys, paths, limits, and timeouts belong in config or in a named constant.
- Fail loud. Never swallow an exception, never write an empty catch, never return null or an empty list to hide an error. If you cannot handle it, let it propagate.
- Validate at trust boundaries: user input, API responses, file contents, env vars. Inside the boundary, trust the types.
- Do not silence the tooling. No blanket `any`, `ts-ignore`, `# noqa`, or disabled lint rule to make something pass. Fix the cause or ask me.

### Making changes
- Smallest diff that solves the problem. Do not reformat, rename, or restructure unrelated lines while making a fix.
- Fix the root cause, not the reported symptom. Before editing a shared function, grep every caller and fix it once where all callers route through.
- Stay in scope, with one exception: a minor issue that is cheap, low-risk, and reversible (a typo, a broken import, an obvious one-line bug, a small lint or test fix) gets fixed on the spot without asking, then mentioned in one line. Never stop work to ask approval for something this small.
- Larger out-of-scope findings (behavior changes, design problems, anything worth its own PR or a decision) get reported at the end, not fixed silently and not raised one by one mid-task. We then decide on a fix or a separate PR.
- Changing a signature, config key, or public name means updating every call site in the same change. Grep for them; do not assume you know them all.

### Verification
- Never claim done without running the check. Build, tests, typecheck, or the actual command, whichever proves it. Show real output, not a description of the output you expect.
- Report failures plainly. A failing test, a skipped step, or a partial fix gets stated with the output, not smoothed over.
- A bugfix needs a check that fails before the fix and passes after. Non-trivial logic leaves one runnable check behind.
- Do not optimize without a measurement. Guessing at the hot path wastes the change.

### Security and data
- Never commit secrets. No API keys, tokens, passwords, or connection strings in source, config, comments, or commit messages. Use env vars and keep `.env` gitignored.
- Never log secrets, tokens, or personal data. Redact before it reaches a log line or an error message.
- Destructive operations need my explicit confirmation first: `rm -rf`, `DROP`, `TRUNCATE`, force push, history rewrite, bulk file moves, and anything touching production data.

### Dependencies
- Check what is already installed before adding anything. A new dependency needs a reason that a few lines of code cannot satisfy.
- Pin versions and commit the lockfile.

### Git
- One logical change per commit. Conventional commits (`feat:`, `fix:`, `refactor:`, `chore:`, etc.) - no author names.
- Never include personal names (Marcel, Marcel Heidebrecht) in any commit message, code comment, docstring, or generated file.
- Commit and push only when I ask. Never force-push or rewrite history on a shared branch.
- Never commit build output, generated artifacts, `.env` files, or local editor config.

---

## Architecture and Delivery
Architecture, library, systems, service, and CI/CD requirements live in `@ARCHITECTURE.md`, imported below. They are hard requirements: skip one only with an explicit waiver from me, and mark it `WAIVED:` in your output.

---

## Verify Before Acting
- **Treat every assumption as an unverified hypothesis.** Before acting on a belief about the codebase, environment, or task, confirm it against the actual source of truth. Do not act on what you expect to be true; act on what you have checked.
- **Triggers that require verification first:**
  - File paths, file existence, or directory structure -> read/list before referencing.
  - Function signatures, class members, types, return values -> read the definition, do not infer from the call site.
  - Library, framework, or API behavior -> check the installed version's actual interface (the version present, not the latest you remember).
  - Config keys, env vars, build scripts, CI steps -> open the file and confirm.
  - "It probably works like X" reasoning of any kind -> verify X.
- **When verification is cheap, never skip it.** Reading a file, listing a directory, grepping for a symbol, or running a type check costs little; a wrong assumption acted on costs a broken change and a debugging cycle.
- **Ask me when verifying is expensive or the task is unclear.** If confirming an assumption would cost significant time or resources (long builds, large downloads, destructive or irreversible operations, external systems), or if the requirement itself is ambiguous, stop and ask me rather than guessing or burning resources on a hunch.
- **Mark any assumption you act on without verifying.** When you proceed on an unverified assumption (because checking was impossible, too expensive, or you judged it low-risk), prefix it with `ASSUMPTION:` in your output so it is explicit and greppable. Example: `ASSUMPTION: the API returns ISO-8601 timestamps; proceeding on that basis.` Never let an unverified assumption pass silently.
- **Do not invent to fill gaps.** If a needed fact is unknown, find it (read, grep, ask) rather than guessing a plausible value.

---

## Reasoning Discipline
Model-independent operating procedures. They describe how to work a problem, not what to build, and apply to every task on every model.

- **Answer the intent, not the literal words.** Before starting, restate in one line what the request is actually for. If the literal reading and the likely intent diverge, say so and pick the intent (or ask).
- **Split hard problems into independently checkable pieces.** Verify each piece on its own before assembly. Never verify only the finished whole; a wrong piece hides inside a plausible whole.
- **Put effort where the risk is.** Name the one or two places the task can go seriously wrong (irreversible step, silent data corruption, misread requirement) and concentrate verification there instead of spreading it evenly.
- **Re-derive, do not recognize.** "Sounds right" is not a check. Verify a claim by computing it again from the source: recompute the number, test both endpoints of a range, walk the actual edge case. Flipped signs and off-by-ones live exactly where recognition feels most confident.
- **Attack the conclusion before delivering it.** Ask: what input, edge case, or alternative reading would make this wrong? Fix what you find, or state it as a known risk.
- **Report answer first, then reasoning, then residual risk.** Lead with the result. Follow with why it holds. Close with what could still be wrong and what was not checked.
- **Watch for mistakes that look like competence:** a detailed answer built on an unverified premise; tests that pass but never exercise the change; a fix at one call site while sibling callers stay broken; fluent prose standing in for a check that never ran. Polish is not evidence.

Pre-send self-test on every answer:
1. Does this answer what was actually asked?
2. Is every load-bearing claim verified or marked ASSUMPTION: (see Verify Before Acting)?
3. Where is the weakest point, and is it stated?
4. Would this survive a hostile reviewer hunting for the flaw?
5. Is anything here invented to fill a gap?

@ARCHITECTURE.md
@RTK.md
