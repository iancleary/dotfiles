# AGENTS.md — Operating Manual

How to navigate Ian's projects as an AI coding agent.

## Before You Start

- Read project CLAUDE.md or README.md for conventions
- Check `git status` and current branch
- Look for `justfile`, `Cargo.toml`, `package.json` to understand the toolchain
- Don't assume conventions from one repo apply to another

## Autonomy

**Do freely:** Read files, explore, run checks/tests/linters, create branches, write code, commit locally

**Ask first:** Push to remote, create PRs, delete remote branches, `cargo publish`, anything public-facing

## Git

- No `Co-Authored-By` lines in commits
- One branch per feature, PRs for review
- Use worktrees (`ga`/`gd`) for parallel work
- Clean up branches after merge
- Conventional commits when the repo uses them

## Toolchains

- **Rust**: `cargo` + `just` (check `justfile` first)
- **Web**: pnpm preferred
- **Docs**: Typst for PDFs, check framework for sites
- **CLI tools**: rg, eza, bat, delta, zoxide — use them

## Safety

- Never commit secrets or credentials
- `trash` > `rm`
- Private repos stay private

## Workflows

These are distilled from Claude Code skills. Use the right workflow for the situation.

### Cargo + Just

If a `justfile` exists, prefer `just <task>` over raw cargo. Run `just --list` to see available tasks. Always show the command before running it. Full pre-commit check: `cargo fmt -- --check && cargo clippy -- -D warnings && cargo test`

### Git Push + PR

1. `git status` + `git diff` to review changes
2. Stage files (`git add -A` or specific files). Never stage secrets.
3. Commit with a concise message (conventional commits if repo uses them)
4. `git push origin HEAD` (or `-u origin HEAD` if no upstream)
5. `gh pr view` to check for existing PR — create with `gh pr create --fill` or update with `gh pr edit`

### Debugging

**No fixes without root cause investigation.** Read error messages fully → reproduce consistently → check recent changes (`git diff`) → trace data flow backward. Form one hypothesis, test minimally, verify. If 3+ fixes fail, stop — it's likely architectural. In Rust: run failing test with `-- --nocapture`, read compiler messages carefully, draw ownership diagrams for borrow checker errors.

### Brainstorming

Before non-trivial work: explore context (files, tests, commits) → ask clarifying questions one at a time → propose 2-3 approaches with trade-offs → present design for approval → before coding, ask "What are the edge cases I haven't considered?" → get sign-off before coding. Apply YAGNI ruthlessly.

### Planning

For multi-file features: break into tasks with exact file paths, what to create/modify, verification steps, and commit messages. Target 5-15 min per task. Every task includes tests. Save plan to GitHub issue or `notes/<feature>-plan.md`. Before executing, ask: "What are the edge cases I haven't considered?"

### Code Review

Get the diff (`gh pr diff` or `git diff main...HEAD`). Check for: bugs, style consistency, performance, security, test coverage. In Rust: watch for `unwrap()` in non-test code, unnecessary `.clone()`, proper `Result`/`?` patterns. Mark findings as 🐛 Bug / 💡 Suggestion / ⚠️ Warning / ✅ Good.

### Test Writing

Read target code → generate tests covering happy path, edge cases, error cases. Rust: `#[cfg(test)] mod tests {}` at bottom or `tests/` for integration. Names describe behavior: `test_empty_input_returns_none`. Run `cargo test` to verify.

### Grill

When asked to grill an idea: interrogate relentlessly. Surface every assumption, blind spot, edge case, and constraint. Challenge vague language. Push back on the problem itself. Only propose a plan after all unknowns are surfaced.

### Shaping

Collaborative problem/solution shaping: iterate between problem definition (requirements) and solution options (shapes). Map workflows into affordance tables showing UI and code affordances with their wiring.
