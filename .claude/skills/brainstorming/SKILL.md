# Adapted from obra/superpowers (MIT) — https://github.com/obra/superpowers

---
name: brainstorming
description: Use before any non-trivial feature work — new modules, architectural changes, or multi-file modifications. Explores intent, requirements, and design before implementation.
---

# Brainstorming Ideas Into Designs

## Overview

Help turn ideas into designs through collaborative dialogue. Understand the project context, ask clarifying questions, then present a design for approval before writing code.

**Do NOT start coding until you have a design and the user has approved it.**

This applies to non-trivial work — if someone asks for a one-line fix, use your judgment.

## Process

### 1. Explore Context

- Check relevant files, tests, recent commits
- Understand the current state of the codebase
- For Rust crates: check `Cargo.toml`, existing module structure, public API

### 2. Ask Clarifying Questions

- One question at a time — don't overwhelm
- Prefer multiple-choice when possible
- Focus on: purpose, constraints, success criteria, scope
- Ask about edge cases and error handling early

### 3. Propose Approaches

- Present 2-3 approaches with trade-offs
- Lead with your recommendation and explain why
- Apply YAGNI — remove unnecessary scope ruthlessly

### 4. Present Design

- Scale to complexity: a few sentences for small features, detailed breakdown for large ones
- Cover: module structure, public API, data flow, error handling, testing approach
- For Rust: specify which files to create/modify, new structs/traits, public functions
- Get approval before proceeding

### 5. Document (optional)

For significant features, save the design:
- As a GitHub issue with the plan
- Or as `notes/<topic>.md` in the repo
- Skip this for small/medium features — the conversation is the record

### 6. Edge Case Gut-Check

Before moving to implementation, ask: **"What are the edge cases I haven't considered?"**

Spend a moment actively looking for:
- Inputs you didn't think about (empty, huge, malformed, concurrent)
- Failure modes you assumed away
- Interactions with existing code you didn't trace
- Assumptions that feel obvious but aren't proven

Surface anything you find. This is the last chance to catch design gaps cheaply.

### 7. Transition to Implementation

Once approved and edge cases addressed, either:
- Start implementing directly (for focused work)
- Create a plan with task breakdown (for larger work — see `planning` skill)
- Spawn sub-agents with clear task descriptions (for parallel work)

## Key Principles

- **One question at a time** — don't overwhelm
- **YAGNI ruthlessly** — remove unnecessary features from all designs
- **Explore alternatives** — always consider at least 2 approaches
- **Be flexible** — the design will evolve during implementation, and that's fine
- **Right-size the process** — a config change doesn't need the same rigor as a new module
