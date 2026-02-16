---
name: edge-cases
description: Use after planning or brainstorming, before implementation. Surfaces edge cases, blind spots, and untested assumptions.
---

# Edge Case Gut-Check

## Overview

Before you start coding, stop and ask: **"What are the edge cases I haven't considered?"**

This is the cheapest time to find design gaps. Run through each category below and surface anything that applies.

## Checklist

### Inputs
- Empty, null, zero-length
- Extremely large or deeply nested
- Malformed, unexpected types
- Unicode, special characters, whitespace-only
- Concurrent or duplicate inputs

### Boundaries
- Off-by-one (0, 1, N-1, N, N+1)
- Integer overflow / underflow
- Floating point precision (NaN, Inf, -0.0, subnormals)
- Max/min values for the type

### Failure Modes
- Network timeouts, partial responses
- Disk full, permission denied
- Dependency unavailable or returning errors
- Interrupted operations (what state is left behind?)
- Retries: is the operation idempotent?

### State & Ordering
- Race conditions, concurrent access
- Out-of-order events
- Stale data, cache invalidation
- Re-entrant calls (calling the same function while it's running)

### Interactions
- Side effects on existing code paths
- Assumptions about data another module provides
- API contract changes that aren't enforced by types
- Config or feature flags that change behavior

### Rust-Specific
- `unwrap()` / `expect()` on values that could be `None`/`Err`
- Ownership moves that leave things in an unexpected state
- `unsafe` blocks: are invariants actually upheld?
- Trait impl assumptions (e.g., `Ord` consistency with `PartialOrd`)
- Serialization round-trips: does `deserialize(serialize(x)) == x`?

## Process

1. Read through the design or plan
2. Walk each checklist category — skip what clearly doesn't apply
3. For each finding: state the edge case and its potential impact
4. Propose mitigations (guard clause, test, doc comment, or design change)
5. Update the plan or design with any changes before proceeding

## Output

Present findings as a table:

| Edge Case | Impact | Mitigation |
|-----------|--------|------------|
| Empty input to `parse()` | Panic on `unwrap()` | Return `Result`, add test |
| Concurrent writes to config | Data corruption | Add mutex or serialize access |

If nothing significant surfaces, say so and move on. Don't invent problems that don't exist.
