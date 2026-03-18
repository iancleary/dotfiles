---
name: solution-iterator
description: "Autonomously iterate on solutions by calling Claude Code or Codex CLIs directly, evaluating outputs, mutating prompts, and converging to an optimal solution. Like ralph-codex but with direct CLI integration. Use when: solve this problem iteratively, find the best solution, converge on this task, auto-improve this solution, iterate until good enough. Outputs: solution-iterator-[problem-name]/ with: results.tsv (all attempts), solutions/ (every version), dashboard.html (progress), convergence-log.md (every iteration + reasoning), and final-solution.md (best approach with full implementation)."
---

# Solution Iterator

Most problems have multiple valid approaches. You could build them all, but that's expensive. Instead: **iterate to the best one**.

This skill adapts the autonomous experimentation methodology to actual solution development. It calls Claude Code or Codex CLIs directly, evaluates every solution, mutates the approach when scores are low, and keeps improving until convergence.

---

## the core job

Take a problem description, define what "good solution" looks like (binary evals), then autonomously:

1. **Call Claude Code or Codex** with an initial prompt
2. **Evaluate the solution** against success criteria
3. **Score it** (quality, performance, code style, tests)
4. **Analyze failures** — what went wrong?
5. **Mutate the approach** — change the prompt strategy
6. **Iterate** — run again with improved prompt
7. **Converge** — stop when good enough or budget exhausted
8. **Deliver** — best solution + full implementation + decision log

**Outputs:**
- `final-solution.md` — The best solution you found
- `solutions/solution-[n].code` — Every version attempted
- `results.tsv` — Score for every attempt
- `convergence-log.md` — Why each iteration succeeded/failed
- `dashboard.html` — Visual progress

---

## before starting: gather context

**STOP. Confirm all fields with the user before proceeding.**

1. **The problem** — What are you trying to solve?
   - Example: "Implement a caching layer for the user dashboard"
   - Example: "Design a multi-tenant account isolation system"
   - Example: "Write a performance profiler for Rust code"

2. **Success criteria (evals)** — 3-5 binary yes/no checks
   - Examples for caching: "Reduces response time by >50%?", "Zero stale data?", "No cache invalidation bugs?"
   - Examples for multi-tenant: "All queries scoped to account?", "No data leaks?", "Passes isolation tests?"
   - Examples for profiler: "Shows actual bottlenecks?", "Works with real code?", "Clear output format?"

3. **Test context** — What should the solution work with?
   - Code samples to test against?
   - Real data to use?
   - Performance benchmarks?
   - Existing codebase to integrate with?

4. **CLI to call** — Which tool should iterate?
   - **Claude Code**: `claude-code` command (lighter, faster)
   - **Codex**: `codex` command (more features, background agents)
   - **Either**: Try Claude Code first, upgrade to Codex if needed

5. **Constraints & Budget**
   - Max iterations? (default: 10)
   - Max time per iteration? (default: no limit)
   - Total budget cap? (e.g., $50 max spend)
   - Language/framework constraints?

---

## step 1: understand the problem

Before iterating, understand exactly what you're solving.

1. Read the problem statement carefully
2. Identify the measurable outcome (what counts as "success"?)
3. Note constraints (performance targets, compatibility, safety)
4. Identify what would make solutions *different* (algorithm, architecture, approach)
5. Confirm evals with user (lock them in before starting)

---

## step 2: build evaluation suite

Convert success criteria into 3-5 binary yes/no checks.

**Examples:**

For "caching layer":
```
EVAL 1: Performance Gain
Question: Does it reduce response time by >50%?
Pass: Timed measurements show <50% of baseline time
Fail: Performance improvement <50% or times out

EVAL 2: Data Consistency
Question: Is cached data always current (no stale data)?
Pass: All tests pass, no cache invalidation bugs
Fail: Any test shows stale data or missing updates

EVAL 3: Code Quality
Question: Is code maintainable and well-tested?
Pass: >80% coverage, clear variable names, documented
Fail: Low coverage, unclear logic, no tests
```

For "multi-tenant isolation":
```
EVAL 1: Query Isolation
Question: Are all queries scoped to the account context?
Pass: Code review shows every query filters by account_id
Fail: Any query can access cross-account data

EVAL 2: No Data Leaks
Question: Do isolation tests pass (no cross-account data exposure)?
Pass: 100% of isolation tests pass
Fail: Any test reveals cross-account access

EVAL 3: Implementation Safety
Question: Is this safe to deploy (no obvious bugs)?
Pass: Code review identifies no security issues
Fail: Potential vulnerabilities or incomplete implementation
```

---

## step 3: generate live dashboard

Create `solution-iterator-[problem]/dashboard.html` with:
- **Line chart**: Iteration number vs quality score (show convergence)
- **Bar chart**: Each iteration with color-coded status (keep, improved, failed)
- **Status table**: Attempt, score, approach, evaluation notes
- **Summary**: Best score achieved, iterations run, convergence status
- **Live status**: "Running iteration [N]..." or "Converged"

Generate as self-contained HTML with Chart.js from CDN. Auto-refreshes every 5 seconds from results.json.

**Open it immediately**: Let user watch convergence happen in real-time.

---

## step 4: establish baseline

Write an **excellent initial prompt** and run it once.

1. Create working directory: `solution-iterator-[problem]/`
2. Write a detailed prompt that:
   - Explains the problem clearly
   - Lists success criteria
   - Provides context (code samples, architecture, constraints)
   - Asks for a specific output format
   - Includes examples if helpful

3. **Call Claude Code or Codex with this prompt:**
   ```bash
   claude-code --prompt "$(cat initial-prompt.md)" \
               --output solution-0.code \
               --language rust  # or ts, py, etc.
   ```

4. Score the output against all evals
5. Record baseline score in results.tsv:
   ```
   iteration  score  max_score  approach                    status
   0          15     20         Initial prompt              baseline
   ```

6. Save solution to `solutions/solution-0.code`

---

## step 5: run the iteration loop

**Core loop**: Analyze → Hypothesize → Mutate prompt → Run → Score → Decide

**LOOP:**

### A. Analyze Failures
Read the solution code. Which evals failed?
- Did it miss functionality? (incomplete implementation)
- Did it use wrong approach? (inefficient algorithm)
- Did it lack tests? (quality issues)
- Did it have bugs? (failed to compile/run)

Identify the **root cause** of lowest-scoring eval.

### B. Form Hypothesis
What change to the prompt would help? One specific thing:

Good mutations:
- Add a missing requirement that the solution ignored
- Specify a different approach/algorithm
- Ask for more tests or better error handling
- Provide a code example showing the expected pattern
- Rewrite vague instruction to be explicit
- Move critical requirement higher in prompt (priority = position)
- Add anti-pattern ("Do NOT do X" if solution keeps doing it)

Bad mutations:
- Vague improvements ("make it better", "improve quality")
- Multiple changes at once (can't tell what helped)
- Rewriting entire prompt instead of targeted fix
- Adding requirements without removing others (prompt bloat)

### C. Mutate Prompt
Edit the prompt strategically. ONE change.

**Examples:**
- Original: "Create a caching layer"
- Mutation 1: "Create a caching layer that reduces response time by 50%. Use Redis. Include cache invalidation strategy."
- Mutation 2: "Create a caching layer. IMPORTANT: Ensure no stale data. Run invalidation tests to verify."
- Mutation 3: "Create a caching layer. Here's an example of proper cache invalidation: [code example]"

### D. Run Iteration
Call Claude Code or Codex with the mutated prompt:

```bash
claude-code --prompt "$(cat prompt-iteration-[N].md)" \
            --output solution-[N].code \
            --model claude-opus  # or override if needed
```

Or upgrade to Codex for complex problems:

```bash
codex \
  --task "$(cat prompt-iteration-[N].md)" \
  --output solution-[N].code \
  --agent "main"
```

### E. Score It
Run the solution (if runnable):
```bash
# Example: test if caching layer works
cd solutions/
cargo test < solution-[N].code  # or npm test, python -m pytest, etc.
```

Score each eval:
- EVAL 1 (Performance): Run benchmark, measure time
- EVAL 2 (Correctness): Run test suite, count failures
- EVAL 3 (Quality): Code review for maintainability, test coverage

Calculate total score: `[passes] / [total evals]`

### F. Decide: Keep or Discard
- Score **improved** → **KEEP.** Update baseline prompt. This is your new reference.
- Score **same** → **DISCARD.** Revert prompt to previous version. Change added complexity without value.
- Score **worse** → **DISCARD.** Revert prompt. This direction doesn't help.

**Log decision:**
```
Iteration 3: +5 points → KEEP
Mutation: Added explicit cache invalidation requirement
Result: Stale data eval now passes
New baseline for iteration 4
```

### G. Repeat
Go back to A. Analyze new failures. Form new hypothesis. Mutate again.

**NEVER STOP EARLY.** Run autonomously until:
- User manually stops you
- Score hits 95%+ for 2 consecutive iterations (diminishing returns)
- Hit iteration cap (default 10)
- Budget exhausted
- Prompt becomes so long it's unmaintainable (unlikely)

---

## step 6: convergence detection

**Stop iterating when:**

1. **Score ceiling hit**: 95%+ score for 2 consecutive iterations
   - Further improvements won't move the needle
   - Law of diminishing returns applies

2. **Plateau detected**: Score unchanged for 3 iterations
   - You've exhausted this approach's potential
   - Need a completely different strategy (rare)

3. **Iteration cap reached**: Default 10, user-specified limit
   - Time/budget constraints

4. **Budget exhausted**: Total spend >cap
   - Cost control

5. **Manual stop**: User interrupts
   - They found what they needed

---

## step 7: deliver results

Present:
1. **Final solution**: `solutions/solution-[best].code` with full implementation
2. **Quality summary**: Baseline → Final score (% improvement)
3. **Total iterations**: How many attempts until convergence
4. **Key insights**: What mutations helped most (from convergence log)
5. **Trade-offs**: Quality vs complexity (did the solution get bloated?)
6. **Integration steps**: How to use this in the actual codebase
7. **Files**:
   - `final-solution.md` — Clean, documented version ready to merge
   - `solutions/` — All attempts (for learning/auditing)
   - `results.tsv` — Every iteration's score
   - `convergence-log.md` — Why each iteration succeeded/failed
   - `dashboard.html` — Visual progress

---

## output files

```
solution-iterator-[problem]/
├── dashboard.html         # Live progress (score vs iteration)
├── results.json          # Data powering dashboard
├── results.tsv           # Iteration log (score, approach, status)
├── convergence-log.md    # Why each iteration succeeded/failed
├── final-solution.md     # Best solution, clean and documented
├── solutions/
│   ├── solution-0.code   # Baseline attempt
│   ├── solution-1.code   # Iteration 1
│   ├── solution-2.code   # Iteration 2
│   └── ...
└── prompts/
    ├── initial-prompt.md
    ├── prompt-1.md       # Mutated for iteration 1
    ├── prompt-2.md       # Mutated for iteration 2
    └── ...
```

---

## example: multi-tenant isolation system

**Problem**: Implement account isolation so account A can't see account B's data.

**Evals**:
1. All queries scoped to account? (Yes/No)
2. Isolation tests pass? (Yes/No)
3. Code passes security review? (Yes/No)

**Baseline attempt** (Iteration 0):
```rust
// Naive approach: filter at query time
let posts = posts::table
    .filter(posts::account_id.eq(account_id))
    .load::<Post>(conn)?;
```

Score: 2/3 (70%)
- ✓ Query scoped to account
- ✓ Isolation test passes
- ✗ Code review finds issue: not all queries have this filter

**Iteration 1 mutation**: "Add a middleware that validates account context on every request"
```rust
// Better: enforce at middleware level
pub fn validate_account_context(req: &Request) -> Result<AccountId> {
    req.extensions().get::<AccountId>()
        .ok_or("Missing account context")
}

// Then in handlers:
let account_id = validate_account_context(&req)?;
let posts = posts::table
    .filter(posts::account_id.eq(account_id))
    .load::<Post>(conn)?;
```

Score: 3/3 (100%)
- ✓ Query scoped
- ✓ Isolation test passes
- ✓ Security review approves (middleware enforces context)

Result: **CONVERGED in 1 iteration**

---

## integration with other skills

**Feeds from:**
- A problem you want to solve (any coding task)
- Success criteria (well-defined evals)

**Feeds into:**
- Your codebase (the final solution is production-ready)
- The `/improve-my-codebase` skill (if you want to refine further)
- The `/test-writer` skill (if you want to expand test coverage)

---

## key principles

1. **Call real CLIs** — Not simulated. Actual Claude Code / Codex output.
2. **Evaluate rigorously** — Binary evals only. Pass or fail.
3. **Mutate one thing** — So you know what helped.
4. **Keep all versions** — Solutions/ directory shows the journey.
5. **Converge with purpose** — Stop when you hit diminishing returns, not arbitrary cap.
6. **Document why** — convergence-log explains every decision.

---

## the test

A good solution iterator run:

- ✅ Established baseline (initial prompt)
- ✅ Ran multiple iterations (tried at least 3 approaches)
- ✅ Scored each solution objectively (binary evals)
- ✅ Changed only one thing per iteration (clear causation)
- ✅ Improved score over baseline (measurable progress)
- ✅ Converged (hit quality ceiling or budget/iteration cap)
- ✅ Delivered production-ready code (final-solution.md is usable)
- ✅ Documented journey (convergence-log explains every step)

If the final solution scores <80%, the evals might be too strict or the problem might be unsolvable with the given constraints. Re-examine evals or constraints before concluding failure.
