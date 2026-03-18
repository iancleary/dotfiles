# Solution Iterator

**Autonomously iterate to the best solution by directly calling Claude Code or Codex CLIs.**

---

## What It Does

This skill solves problems iteratively:

1. **Initial attempt** → Call Claude Code with your problem description
2. **Evaluate** → Score the solution against success criteria
3. **Analyze** → Understand why it failed
4. **Mutate** → Change the prompt to fix the failure
5. **Repeat** → Run again with improved prompt
6. **Converge** → Stop when good enough

Each iteration calls the **real CLI** (Claude Code or Codex), not a simulator. You get actual code solutions that improve over time.

---

## How It Differs from Ralph-Codex

**Ralph-Codex** (iteration loop with subprocess):
- Runs Codex in a shell loop
- Manual convergence detection
- Good for feature development
- Focuses on "does it work?"

**Solution Iterator** (CLI-integrated):
- Calls Claude Code or Codex CLI directly
- Automatic scoring against evals
- Good for problem-solving and architecture
- Focuses on "is this the *best* solution?"
- Tracks all versions and scores

**When to use each:**
- **Ralph-codex**: Building a feature from scratch, iterating toward working code
- **Solution-iterator**: Finding the optimal approach, comparing architectural options

---

## Quick Start

### In Claude Code Editor

```
Type: /solution-iterator
Provide: Problem description

Claude will ask:
1. What are your success criteria? (evals)
2. What test context should I use?
3. Claude Code or Codex?

Then runs iterations and shows you convergence.
```

### Example Session

```
You: /solution-iterator

Claude: What problem are we solving?

You: Implement multi-tenant account isolation for rfsystems

Claude: Great. What makes a "good" solution?
(Give me 3-5 binary yes/no checks)

You:
1. All queries scoped to account_id
2. Isolation tests pass (no cross-account data)
3. Code passes security review

Claude: What test context should I use?

You: [pastes test suite + example queries]

Claude: Claude Code or Codex?

You: Claude Code (faster)

Claude: Running iterations...

Iteration 0 (Baseline):
  Score: 2/3 (67%)
  Issue: Some queries missing account filtering
  
Mutation: Add middleware to enforce account context

Iteration 1:
  Score: 3/3 (100%)
  ✅ CONVERGED

Final Solution:
- Full implementation (production-ready)
- All tests passing
- Security-reviewed
- Ready to merge
```

---

## How It Works

### Phase 1: Setup
1. User describes the problem
2. You help define success criteria (evals)
3. You gather test context

### Phase 2: Baseline
1. Write an excellent initial prompt
2. Call Claude Code/Codex with that prompt
3. Score the output
4. Record baseline

### Phase 3: Iteration Loop
**Repeat until converged:**
1. **Analyze**: Read solution, identify failing evals
2. **Hypothesize**: What change would help?
3. **Mutate**: Edit prompt strategically (ONE change)
4. **Run**: Call Claude Code/Codex with new prompt
5. **Score**: Evaluate against all evals
6. **Decide**: Keep (improved) or discard (no improvement)

### Phase 4: Convergence
Stop when:
- Score hits 95%+ for 2 consecutive iterations
- 3 iterations with no improvement
- Hit iteration cap (default 10)
- Budget exhausted

### Phase 5: Delivery
Return:
- `final-solution.md` — Production-ready code
- `solutions/` — All attempts (for learning)
- `convergence-log.md` — Why each iteration worked/failed
- `dashboard.html` — Visual progress

---

## Example: Multi-Tenant Isolation

### The Problem
Implement account isolation so users can only see their own data.

### Success Criteria
1. All queries scoped to account?
2. Isolation tests pass?
3. Security-approved?

### Baseline (Score: 2/3)
Claude Code generates:
```rust
let posts = posts::table
    .filter(posts::account_id.eq(account_id))
    .load::<Post>(conn)?;
```
Works for this query, but doesn't guarantee *all* queries are scoped.

### Iteration 1 (Mutation: Add Middleware)
Prompt change: "Add a middleware that enforces account context validation"

Claude Code generates:
```rust
pub fn validate_account_context(req: &Request) -> Result<AccountId> {
    req.extensions().get::<AccountId>()
        .ok_or("Missing account context")
}

// Now in handlers:
let account_id = validate_account_context(&req)?;
```

Score: 3/3 (100%) ✅ **CONVERGED**

---

## Outputs

### 1. dashboard.html
Live browser dashboard showing:
- Score progression (line chart)
- Iteration status (color-coded bars)
- Summary: Best score, iterations run, convergence status

### 2. results.tsv
Log of every iteration:
```
iteration  score  max  approach                status
0          2      3    Initial prompt          baseline
1          3      3    Add middleware          keep
```

### 3. convergence-log.md
Why each iteration worked or failed:
```markdown
## Iteration 1 — KEEP (+1 score)

**Mutation**: Added middleware validation
**Reasoning**: Query filtering alone doesn't guarantee account scope
**Result**: Middleware enforces context validation
**New Baseline**: Use middleware for all handlers
```

### 4. final-solution.md
Production-ready solution with:
- Clean, documented code
- Integration instructions
- Testing validation
- Architecture explanation

### 5. solutions/
All attempted solutions:
```
solution-0.code    # Baseline
solution-1.code    # Iteration 1
solution-2.code    # Iteration 2
...
```

---

## Key Principles

1. **Real CLI calls** — Not simulation. Actual Claude Code or Codex output.
2. **Binary evals only** — Yes/No. No subjective scoring.
3. **One change per iteration** — So you know what helped.
4. **All versions saved** — Full audit trail of attempts.
5. **Converge intelligently** — Stop at 95% quality or diminishing returns.

---

## When to Use Solution Iterator

✅ **Use when:**
- You're solving a complex problem with multiple valid approaches
- You want the *best* solution, not just a working one
- Performance/architecture decisions matter
- You want to compare different strategies objectively
- You need a decision log for why you picked this approach

❌ **Don't use when:**
- The problem is simple (just call Claude Code once)
- You only need proof-of-concept (ralph-codex might be faster)
- The solution is trivial and convergence won't help
- You have unlimited time/budget (diminishing returns)

---

## Complements Other Skills

**Three iteration systems:**

```
/ralph-codex
  → Iterate on feature implementation
  → "Build and refine the feature"
  → Uses subprocess loop

/solution-iterator (NEW)
  → Iterate to optimal solution
  → "Find and converge to the best approach"
  → Calls Claude Code/Codex CLI directly

/autoresearch
  → Iterate on skill prompts
  → "Make the skill better"
  → Measures and optimizes behavior
```

---

## Integration with Workflow

### Architecture Decision
```
1. /grill-me [what should we build?]
2. /shaping [shape the idea]
3. /solution-iterator [find the best architectural approach]
4. /write-a-prd [formalize the chosen approach]
5. /ralph-codex [implement and refine]
```

### Optimization Work
```
1. /improve-my-codebase [identify issues]
2. /solution-iterator [find multiple fix approaches]
3. /compare them [which is best?]
4. /implement the winner
```

### Research/Evaluation
```
1. /solution-iterator [generate N different solutions]
2. /benchmark them [performance comparison]
3. /document findings [why you picked this one]
```

---

## CLI Integration

Internally, solution-iterator calls:

**Claude Code (lightweight):**
```bash
claude-code --prompt "$(cat prompt.md)" \
            --output solution.code \
            --language rust
```

**Codex (full-featured):**
```bash
codex \
  --task "$(cat prompt.md)" \
  --output solution.code \
  --agent "main"
```

You specify which one during setup. The skill handles the rest.

---

## Example: Finding the Best Caching Strategy

**Problem**: Add caching to the user dashboard

**Evals**:
1. Response time reduced >50%?
2. No stale data?
3. Code is maintainable?

**Baseline**: Simple in-memory cache
- Score: 1/3 (stale data issue)

**Iteration 1**: Add Redis
- Score: 2/3 (fast, but complexity)

**Iteration 2**: Redis + smart invalidation
- Score: 3/3 ✅ **CONVERGED**

**Convergence-log**: "Smart invalidation (Event-based) was key. TTL alone wasn't enough."

---

## Next Steps

In Claude Code, type:
```
/solution-iterator
```

Then answer:
1. What problem are you solving?
2. What makes a good solution? (3-5 yes/no checks)
3. What test context should I use?
4. Claude Code or Codex?

Claude will iterate to find the best solution and show you the journey. 🚀
