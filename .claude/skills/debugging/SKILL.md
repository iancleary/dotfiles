# Adapted from obra/superpowers (MIT) — https://github.com/obra/superpowers

---
name: debugging
description: Use when encountering any bug, test failure, or unexpected behavior. Systematic root cause analysis before proposing fixes.
---

# Systematic Debugging

## Overview

Random fixes waste time and create new bugs. **Always find root cause before attempting fixes.**

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## The Four Phases

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read error messages carefully**
   - Don't skip past errors or warnings
   - Read stack traces completely — they often contain the answer
   - Note line numbers, file paths, error codes

2. **Reproduce consistently**
   - Can you trigger it reliably?
   - What are the exact steps / test command?
   - For Rust: `cargo test <specific_test> -- --nocapture` to see output

3. **Check recent changes**
   - `git diff`, recent commits
   - New dependencies, Cargo.toml changes
   - Any `unsafe` blocks or `.unwrap()` calls nearby?

4. **Trace data flow**
   - Where does the bad value originate?
   - Trace backward through the call stack
   - Fix at source, not at symptom

### Phase 2: Pattern Analysis

1. **Find working examples** — similar working code in the same codebase
2. **Compare** — what's different between working and broken?
3. **List every difference** — don't assume "that can't matter"
4. **Check types** — in Rust, type mismatches and ownership issues are common root causes

### Phase 3: Hypothesis and Testing

1. **Form a single hypothesis** — "I think X is the root cause because Y"
2. **Test minimally** — smallest possible change, one variable at a time
3. **Verify** — did it work? If not, form a NEW hypothesis. Don't stack fixes.

**If 3+ fixes have failed:** Stop. The issue is likely architectural, not a simple bug. Discuss with the user before attempting more fixes.

### Phase 4: Implementation

1. **Write a failing test** that demonstrates the bug
2. **Implement the fix** — address root cause, not symptom
3. **Verify** — test passes, no other tests broken
4. **`cargo clippy`** — ensure no new warnings

## Red Flags — Stop and Return to Phase 1

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "I don't fully understand but this might work"
- "Let me fix multiple things at once"
- Proposing solutions before tracing data flow

**ALL of these mean: STOP. Return to Phase 1.**

## Rust-Specific Debugging

| Situation | First Step |
|-----------|-----------|
| `cargo test` failure | Run the specific failing test with `-- --nocapture` |
| Compilation error | Read the full error — Rust compiler messages are excellent |
| Borrow checker error | Draw the ownership/lifetime diagram before "fixing" |
| `unwrap()` panic | Find which `.unwrap()` panicked, understand why the value is `None`/`Err` |
| Clippy warning | Read the suggested fix — clippy is almost always right |
| CI failure but local passes | Check Rust version, feature flags, OS differences |

## Quick Reference

| Phase | Key Activity | Done When |
|-------|-------------|-----------|
| 1. Root Cause | Read errors, reproduce, trace data | Understand WHAT and WHY |
| 2. Pattern | Find working examples, compare | Identified the difference |
| 3. Hypothesis | Form theory, test one change | Confirmed or new theory |
| 4. Fix | Write test, fix, verify | Bug resolved, all tests pass, clippy clean |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes. Process is fast for simple bugs. |
| "Emergency, no time" | Systematic is FASTER than guess-and-check thrashing. |
| "Just try this first" | First fix sets the pattern. Do it right from the start. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
