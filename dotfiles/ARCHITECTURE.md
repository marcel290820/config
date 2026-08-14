# Architecture and Delivery Requirements

These are requirements, not suggestions. They apply to every project by default: libraries, CLIs, embedded and systems code, applications, and services.

- A requirement is skipped only when I explicitly waive it, or when the project has a documented convention that contradicts it. Either way, write `WAIVED: <rule> - <reason>` in your output so the deviation is visible.
- If a requirement blocks the task or conflicts with what I asked for, stop and tell me which requirement and why. Never silently drop one.
- These rules govern the shape of a system, not its size. Build the smallest thing that satisfies the current requirement and still obeys them. Scope discipline (the YAGNI ladder in CLAUDE.md) still wins over speculative structure.

---

## Universal requirements

Apply to all code, in every language, at every level.

- Separate the core from the edges. Domain logic must be callable without a network, a database, a framework, a UI, or a real clock. I/O, framework glue, and vendor SDKs live at the boundary.
- Dependencies point inward. The core never imports the transport, the framework, or a vendor SDK. Layering is acyclic: if A depends on B, B must never depend on A.
- No global mutable state. Dependencies are passed in. Singletons, ambient config, and module-level mutable state need a waiver.
- Importing a module has no side effects. Nothing opens a socket, reads a file, spawns a thread, or parses config at import or static-init time.
- One source of truth per piece of state. Do not store what can be derived, and do not keep two copies that a human has to keep in sync.
- Separate expected failure from a bug. Expected failure is a value in the return type (`Result`, an error return, a typed exception); a bug fails loudly and immediately. Never convert one into the other to simplify a signature.
- Release every acquired resource on every path, including the error path. Prefer scope-bound release (RAII, `defer`, `with`, try-with-resources) over manual cleanup.
- Validate at the boundary and encode the result in the type. Data inside the core is already valid and does not get re-checked at every call site.
- Every shared mutable value has exactly one documented owner or one documented lock, with the invariant written next to it.
- Every module states its contract: what it takes, what it returns, how it fails, and what it explicitly does not do.
- Anything published is a contract: a public API, an exported type, a CLI flag, an env var name, a file format, a wire format, a database column. Changing one is a breaking change and is versioned as such.

## Libraries, packages, and crates

- Semantic versioning, strictly. Breaking change means a major bump; new capability means a minor. Nothing else may alter the public surface.
- Keep the public surface as small as the use case requires. Everything else stays private. Widening later is cheap; narrowing costs a major version.
- Do not take a dependency the caller could provide. Every dependency a library adds is inherited by every consumer and cannot be removed by them.
- Library code does not log, print, exit, install signal handlers, or read env vars. It returns values and lets the application decide.
- Heavy or optional functionality sits behind a feature flag or optional dependency. Default features stay minimal.
- Every public item is documented with what it does, how it fails, and one example. The example is compiled or run in CI.
- No panic, `unwrap`, or assertion on caller-supplied input. Return an error instead.

## Command line tools

- Data goes to stdout, diagnostics go to stderr. Exit 0 on success, non-zero on failure, always.
- Never prompt interactively when stdin is not a TTY. Accept a flag or fail with a clear message.
- Destructive actions require an explicit flag or confirmation, and support `--dry-run` where the operation allows it.

## Systems and low-level code

- State the memory and lifetime model up front: who allocates, who frees, how long a borrow lives, and whether a type is thread-safe.
- Every `unsafe` block, raw pointer, and FFI call carries a comment naming the invariant that makes it sound and who upholds it.
- No unbounded allocation, recursion, or loop driven by untrusted input. Every buffer and queue has a bound.
- Handle integer overflow, truncation, and endianness explicitly at parse and serialize boundaries. Never assume them.
- Check the return of every syscall and FFI call. No ignored error codes.
- Document blocking calls, allocations, and lock acquisitions in any hot path, interrupt handler, or real-time path. If none are permitted there, say so in the comment.
- Hardware and timing values are named, calibratable constants, never magic numbers buried in logic. Real clocks drift and real sensors read off.

## Applications and services

Follow the twelve-factor methodology (12factor.net). The factors that get broken most often:

- Config lives in the environment. No environment-specific config files committed to the repo, and no `if env == "production"` branch in application code. A new deploy target needs new env vars, not a code change.
- Backing services are attached resources. Database, cache, queue, object store, and mail provider are reached through a URL or credential in config, so each can be swapped without touching application code.
- Processes are stateless. No session, upload, or cache in process memory or on local disk. Anything that must survive a restart goes to a backing service. Sticky sessions are never a requirement.
- Build, release, and run stay separate. Releases are immutable and never edited in place on a server.
- Processes are disposable. Fast startup, graceful shutdown on SIGTERM, and workers that can die mid-job without losing or duplicating work.
- Dev/prod parity. Same backing service types in every environment. SQLite locally and Postgres in production is a bug waiting for production.
- Logs go to stdout as a stream of events. The application does not open log files, rotate them, or ship them.
- Admin tasks are scripts in the repo, run against the release. Migrations, backfills, and repairs are reviewed code, never typed into a production console.

Beyond the twelve factors:

- Anything slow, retryable, or dependent on a third party belongs on a queue, not in the request path.
- Handlers for webhooks, payments, and queue jobs are idempotent. They will be delivered twice.
- Migrations stay backwards compatible with the currently running release: add, backfill, switch reads, drop later. Never make a destructive change in the same deploy that stops using the column.
- Public API changes are additive. Version the API; never change or remove a field a client depends on without a deprecation path.
- Store timestamps in UTC and money in integer minor units. Convert at the boundary for display only.
- Emit structured logs carrying a request id on every entry, so one request can be traced end to end.

## Multi-tenant SaaS

- Every tenant-scoped query filters by tenant, enforced at the data-access layer rather than in each handler.
- Never take the tenant id from client input. Derive it from the authenticated session.
- Authorize where the data is read, not where it is rendered. A hidden button is not access control.
- Include the tenant id in structured log entries and error reports.

## CI/CD

- Every repo has CI from the first commit. A green pipeline is a merge gate, not a status signal.
- A project with no pipeline is an open requirement, so raise it rather than working around it. On a new project, set CI up before the first feature lands. In an existing repo with no pipeline, say what is currently unprotected and ask whether to add one, then respect the answer for the rest of the session. Both paths run the `ci-setup` skill, which asks what the project is and where it deploys before writing anything.
- The pipeline installs from the lockfile, then lints, typechecks, tests, and builds. All of it runs on every pull request, and all of it blocks the merge.
- CI runs the same commands I can run locally. If a check cannot be reproduced locally with one command, that is a bug in the repo.
- Build once and deploy that artifact. Never rebuild per environment.
- The pipeline is code in the repo, reviewed like code. No pipeline configured by clicking in a web UI.
- Builds are deterministic: pinned tool versions, pinned base images, committed lockfiles. Never `latest`.
- Secrets come from the CI secret store, never from the repo, and are never printed in a log.
- Deploys are automated, repeatable, and reversible, rollback included. A deploy only one person can run by hand is an outage waiting to happen.
- Migrations run as a separate reviewed step that is safe to re-run and safe against the previous release.
- A flaky test gets quarantined or fixed. Never retry a job until it goes green.
- Tags and releases are cut by CI, with the changelog generated from conventional commits.
