---
name: ci-setup
description: Set up or repair CI/CD for a project, interactively. Use at the start of a new project before the first feature lands, when a repo has no pipeline, when the user asks about CI, GitHub Actions, workflows, merge gates, release automation, or pipelines, and whenever work is about to begin in a repo whose .github/workflows directory is missing or empty.
---

# CI setup

CI is a hard requirement in ARCHITECTURE.md, not a nice-to-have. This skill makes the setup conversation happen at the right moment and produces a pipeline that actually passes on the first run.

## When to run

- **Greenfield project.** Run before the first feature is written. A pipeline added on day one costs ten minutes; added on day sixty it costs a week of red builds.
- **Existing repo with no pipeline.** Raise it once, ask, then respect the answer. If the user declines, do not bring it up again in the same session.
- **Existing pipeline that does not gate.** A workflow that skips tests, runs on push only, or is allowed to fail is worse than none, because it looks like coverage. Treat it as missing.

## Step 1: look before you ask

Never ask a question the repo already answers.

```bash
ls .github/workflows/ 2>/dev/null; ls .gitlab-ci.yml Jenkinsfile .circleci azure-pipelines.yml 2>/dev/null
ls package.json Cargo.toml pyproject.toml go.mod CMakeLists.txt Makefile 2>/dev/null
git remote -v 2>/dev/null
```

From that, determine: does CI exist, what is the stack, is the remote GitHub. The templates here are GitHub Actions; if the remote is GitLab or something else, say so and adapt the same stages rather than writing an unusable file.

## Step 2: ask

Use AskUserQuestion. Keep it to the questions whose answers change the pipeline.

**Greenfield.** Ask up to three:

1. *What is this project?* Library or package to publish / application or service to deploy / CLI tool / embedded or systems code. This decides whether the pipeline ends at test, at build, at publish, or at deploy.
2. *Where does it run?* Local only for now / a host or platform (Vercel, Railway, Fly, a VPS, a device) / a package registry (npm, crates.io, PyPI) / not decided yet. This decides whether to add a release job now or leave a placeholder.
3. *What is the merge gate?* Lint plus tests / lint, typecheck, tests, and build / everything plus coverage or a security scan. Recommend the middle option unless the project is a published library, which warrants the third.

**Existing repo without CI.** Ask one question: add a pipeline now, with the two or three most sensible variants as options and "not now" available through Other. State the specific risk in the question, not a generic pitch: name what is currently unprotected, for example "nothing checks that the tests pass before a merge."

## Step 3: verify the commands exist before writing them

The most common failure is a workflow that calls a script the repo does not have, so the first run is red and the pipeline gets ignored from then on.

Read `package.json` scripts, `Cargo.toml`, `pyproject.toml`, or the `Makefile` and confirm every command in the template. When one is missing, either add the script or drop that step. Never ship a step you have not confirmed can run.

Then run the same commands locally once. A pipeline that has never passed on this machine has not been tested.

## Step 4: write it

Copy the matching file from `templates/` into `.github/workflows/ci.yml` and adjust to the answers:

| Stack | Template | Notes |
|---|---|---|
| Node, TypeScript | `templates/node.yml` | Needs `.nvmrc`. Swap `npm ci` for `pnpm install --frozen-lockfile` or `yarn --immutable` to match the lockfile that is actually committed. |
| Rust | `templates/rust.yml` | Clippy denies warnings. For a published crate add `cargo publish --dry-run`. |
| Python | `templates/python.yml` | Assumes uv. For Poetry or pip, keep the stages and swap the install step. |
| Other | none | Write the same five stages by hand: install from lockfile, lint, typecheck, test, build. |

Requirements that hold for every pipeline, from ARCHITECTURE.md:

- Runs on pull requests, and every stage blocks the merge.
- Installs from the committed lockfile, never a floating resolve.
- Pinned action versions and pinned tool versions. No `latest`.
- Secrets come from the CI secret store and are never echoed.
- Build once, deploy that artifact. No rebuild per environment.

## Step 5: close the loop

- Tell the user which commands the gate now runs and which ones you confirmed locally.
- Branch protection is not in the file. Say plainly that the gate is advisory until required checks are enabled: `gh api -X PUT repos/:owner/:repo/branches/main/protection` or the repo settings page.
- Do not commit or push unless asked.

## Deploy and release

Only add a deploy or publish job once the target actually exists. A release job pointing at a platform that has not been chosen is dead config. When the target is known:

- Deploy runs after the gate passes, never in parallel with it.
- The deployed artifact is the one CI built, not a fresh build.
- Rollback is a documented command or a one-click action, and gets written down at the same time as the deploy.
- Migrations run as a separate reviewed step, safe to re-run.
