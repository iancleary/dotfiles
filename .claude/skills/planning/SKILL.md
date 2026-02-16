# Adapted from obra/superpowers (MIT) — https://github.com/obra/superpowers

---
name: planning
description: Use when you have a spec or requirements for a multi-step task, before touching code. Breaks work into clear, actionable tasks.
---

# Writing Implementation Plans

## Overview

Break approved designs into concrete, actionable tasks. Each task should be clear enough that a sub-agent (or future-you with no context) can execute it without ambiguity.

**Announce at start:** "Creating an implementation plan for [feature]."

## When to Use

- Feature requires changes across multiple files or modules
- Work will be split across sub-agents
- Task is complex enough that jumping in would lead to rework
- You want human checkpoints between phases

Skip this for single-file changes or obvious implementations.

## Task Structure

Each task should include:

```markdown
### Task N: [Clear Name]

**Files:**
- Create: `src/module.rs`
- Modify: `src/lib.rs` (add `pub mod module;`)
- Test: `tests/module_tests.rs` or inline `#[cfg(test)]`

**What to do:**
[Specific description — what structs, functions, traits to add. Include key signatures.]

**Verification:**
- `cargo test` passes
- `cargo clippy` clean
- [Any specific behavior to verify]

**Commit:** `Add module with [feature]`
```

## Task Sizing

- Target **5-15 minutes** per task for sub-agent work
- Larger tasks (30+ min) are fine for focused human work
- Each task should be independently committable
- If a task feels too big, split it

## Plan Document

For significant features, save the plan:

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence]
**Crate:** [which crate/repo]
**Branch:** [branch name]

---

### Task 1: ...
### Task 2: ...
```

Save to: GitHub issue body, or `notes/<feature>-plan.md` in the repo.

## Rust-Specific Guidance

- Specify exact `pub` vs private visibility
- Include `use` imports that will be needed
- Note any `Cargo.toml` dependency additions
- Specify whether tests are unit (`#[cfg(test)]` in module) or integration (`tests/`)
- Include `cargo clippy` as a verification step on every task
- For new public API: include doc comments in the plan

## Execution

After saving the plan, offer:

1. **Sequential** — work through tasks in order, commit after each
2. **Sub-agents** — spawn one sub-agent per task (or group of related tasks)
3. **Human review** — present plan for approval, then execute with checkpoints

Match the approach to the scope: sub-agents for large batch work, sequential for focused sessions.

## Key Principles

- **Exact file paths** — no ambiguity about where changes go
- **Complete enough to execute** — don't write "add validation" when you mean "add `validate()` that checks X, Y, Z"
- **DRY** — if multiple tasks need the same setup, do it once in Task 1
- **Tests with every task** — not necessarily test-first, but every task includes its tests
- **Frequent commits** — one commit per task, clean history
