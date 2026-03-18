# LLM Usage Researcher

**Autonomously optimize your LLM strategy**: Find the best model, prompt configuration, and cost for any task.

---

## What It Does

This skill helps you answer:
- **Should I use Kimi K2.5 or Claude Opus for this task?**
- **Is the quality loss worth the 85% cost savings?**
- **How much will this workflow cost annually?**
- **Which temperature/prompt structure works best?**

It does this by:
1. Testing your task with multiple LLM approaches
2. Scoring quality, cost, and speed for each approach
3. Comparing against a baseline (usually the most capable/expensive model)
4. Recommending the optimal strategy with clear decision criteria

---

## How It Fits In

**Three complementary optimization systems:**

```
/autoresearch          → Optimize the skill prompt itself
                          (make your skill better)

/llm-usage-researcher  → Optimize which LLM to use for the task
                          (pick the right tool)

/ralph-codex           → Iterate on feature implementation
                          (build the right thing)
```

### Example: Shipping a Feature

```
1. Product: Grill the idea (/grill-me)
           → Write PRD (/write-a-prd)
           → Decompose into issues (/prd-to-issues)

2. Strategy: Decide which LLM approach to use
           → Test Kimi vs Claude vs GPT-4 (/llm-usage-researcher)
           → Pick optimal: "Use Kimi for routine work"

3. Implementation: Build the feature
           → Iterate with /ralph-codex or OpenCode
           → Test with /tdd
           → Review with /code-review or /autoresearch

4. Optimization: Improve existing features
           → Use /improve-my-codebase to find issues
           → Test cost/quality trade-offs (/llm-usage-researcher)
           → Refactor and optimize
```

---

## Quick Start

### In Claude Code Editor

```
Type: /llm-usage-researcher
Provide: Task description (e.g., "optimize code review for Rust PRs")

Claude will ask:
1. What are your success criteria? (evals)
2. What test inputs should we use?
3. Which models should we compare?
4. What's your budget?

Then runs experiments and recommends the best approach.
```

### Example Session

```
You: /llm-usage-researcher

Claude: I'll help optimize LLM usage for your task.

First, tell me: What problem are we solving?
(e.g., "code review", "test generation", "documentation")

You: Code review of Rust code for rfsystems project

Claude: Great. Let's define success for a code review.

What makes a "good" code review output?
(Give me 3-5 binary yes/no checks)

You:
1. Identifies all actual bugs (>70% coverage)
2. Suggestions are specific and actionable
3. Feedback is delivered respectfully

Claude: Perfect. Now give me 3-5 examples of code to review
(I'll test each approach with these examples)

You: [pastes 3 PRs of varying complexity]

Claude: And finally, which models should we compare?
- Kimi K2.5 ($0.01)
- Claude Sonnet ($0.03)
- Claude Opus ($0.08)  (baseline)

You: Yes, test all three

Claude: Got it. Running experiments now...
[Tests Opus, Sonnet, Kimi with your 3 PRs]
[Generates dashboard, comparison table, recommendation]

Final Recommendation:
- Use Kimi K2.5 for 80% of reviews (simple PRs)
  90% quality, 87% cost savings
- Use Sonnet for 15% (complex reviews)
  93% quality, 62% cost savings
- Reserve Opus for 5% (security-critical)
  96% quality, best quality

Annual savings: $71.40 (if doing 100 reviews/month)
```

---

## Outputs

After running, you get:

1. **comparison.tsv** — Every run with scores and costs
   ```
   model              score  quality  cost  speed  status
   claude-opus        16     80%      0.08  2.3s   baseline
   kimi-k25           10     80%      0.01  0.4s   recommended
   claude-sonnet      14     93%      0.03  1.1s   good-compromise
   ```

2. **dashboard.html** — Visual comparison in your browser
   - Scatter plot: Cost vs Quality
   - Timeline: Score progression
   - Summary stats: Cheapest, Best Quality, Fastest, Recommended

3. **recommendations.md** — Actionable recommendation
   ```
   Primary: Use Kimi K2.5 for routine work
   Secondary: Use Sonnet for complex tasks
   Reserve: Opus for critical decisions
   
   Decision Tree:
   Is task simple? → YES: Use Kimi ($0.01)
                    NO:  Is quality critical? → YES: Use Opus ($0.08)
                                              NO:  Use Sonnet ($0.03)
   ```

4. **changelog.md** — Every experiment tried
   ```
   Experiment 0 (Baseline): Claude Opus — 80% score, $0.08
   Experiment 1 (Kimi): 76.7% score, $0.01 — KEEP (great cost savings)
   Experiment 2 (Sonnet): 93% score, $0.03 — KEEP (good compromise)
   ```

---

## Real Example: Ian's Daily Developer Work

**Scenario**: Should Ian use Kimi K2.5 (cheap) or Claude Opus (expensive) for code review?

**Setup**:
- Task: Code review for rfsystems project
- Evals: Finds bugs, suggestions actionable, pattern match
- Test inputs: 5 different PRs
- Models: Kimi, Sonnet, Opus (baseline)

**Results**:
```
Model             Quality  Cost     Speed   Recommendation
Claude Opus       96.7%    $0.08    2.5s    Baseline
Claude Sonnet     93.3%    $0.03    1.1s    ✅ Use for complex
Kimi K2.5         76.7%    $0.01    0.4s    ✅ Use for simple
Kimi (few-shot)   90.0%    $0.015   0.5s    ✅ Use for routine
```

**Recommendation**:
- Use **Kimi K2.5 (few-shot)** for 80% of code reviews
  - 90% of Opus quality
  - 81% cost savings
  - 5x faster
  
- Use **Sonnet** for 15% of complex reviews
  - 93% of Opus quality
  - 62% cost savings
  
- Reserve **Opus** for 5% security-critical reviews
  - Best quality guaranteed

**Impact**:
- Current cost (100% Opus): $96/year
- Optimized cost: $24.60/year
- **Savings: $71.40/year (75% reduction)**
- Quality: 90-93% vs 96.7% (minimal for routine work)

---

## Key Principles

1. **Test cheap first** — Start with Kimi. You might find it's sufficient.
2. **Binary evals only** — Yes/no checks only. No scales or "somewhat".
3. **Real test inputs** — Don't optimize for toy examples. Use actual work.
4. **Clear recommendations** — "Use X for Y" not "it depends".
5. **Quantify trade-offs** — Show exact cost and quality differences.
6. **Annual impact** — Calculate long-term savings or quality gains.

---

## Reference Files

- [**SKILL.md**](SKILL.md) — Complete methodology and workflow
- [**references/eval-patterns.md**](references/eval-patterns.md) — How to write good evals
- [**examples/cost-optimization-example.md**](examples/cost-optimization-example.md) — Full worked example

---

## When to Use This Skill

✅ **Use when**:
- You want to optimize LLM costs
- You need to justify model selection
- You're deciding between providers/models
- You want to measure quality vs cost trade-offs
- You have a repetitive task and want the best approach

❌ **Don't use when**:
- You only run a task once
- Cost doesn't matter (use best model always)
- You don't have clear success criteria
- The task is too complex to evaluate reliably

---

## Integration with Your Workflow

### Daily Development
```
Task: "Should I use Kimi or Claude for code review?"
→ /llm-usage-researcher [set up test]
→ "Use Kimi for simple reviews, Sonnet for complex"
→ Now you know exactly when to use each model
```

### Cost Planning
```
Task: "What will my LLM spend be annually?"
→ /llm-usage-researcher [test your workflow]
→ "If you do 100 tasks/month, budget $X for Kimi, $Y for Claude"
→ Planning done
```

### Feature Workflow
```
1. /grill-me [flesh out idea]
2. /write-a-prd [formalize requirements]
3. /llm-usage-researcher [decide LLM approach]
4. /prd-to-issues [break into tasks]
5. /ralph-codex [implement with optimal LLM]
```

---

## Complements Autoresearch

**Autoresearch** optimizes a *skill's prompt*.
Example: "Make /code-review find 95% of bugs instead of 70%"

**LLM Usage Researcher** optimizes *which LLM to use*.
Example: "Use Kimi for 80% of code reviews, Opus for 20%"

Together: **Higher quality code-review skill + right model for the task = optimal outcome**

---

## Next: Running Your First Experiment

In Claude Code, type:
```
/llm-usage-researcher
```

Then answer:
1. What task do you want to optimize?
2. What's success? (3-5 binary yes/no checks)
3. Give me test examples
4. Which models should we compare?

Claude will run the experiments and give you actionable recommendations. 🚀
