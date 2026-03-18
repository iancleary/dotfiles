---
name: llm-usage-researcher
description: "Autonomously test and optimize LLM usage patterns to find the best model, prompt strategy, and cost for your task. Run the same task with different models/approaches, track quality/cost/speed, and converge on optimal configuration. Similar to autoresearch but for LLM strategy instead of skill prompts. Use when: optimize my LLM costs, find the best model for this task, reduce token spend, improve output quality, compare LLM approaches, benchmark models, test different prompts. Outputs: usage-researcher-[task-name]/ directory with: comparison.tsv (all runs), results.json (live data), dashboard.html (visual comparison), recommendations.md (best approach + reasoning), and changelog.md (every iteration tried)."
---

# LLM Usage Researcher

Most teams throw expensive models at every problem. But not every task needs Claude Opus or GPT-4 Turbo. A faster, cheaper model might work just as well. The problem: **how do you know without testing?**

This skill adapts the autoresearch methodology to LLM strategy. Instead of optimizing a skill's prompt, you optimize your **LLM usage pattern** — which model to use, what temperature setting, what prompt structure, what provider, what context length.

---

## the core job

Take a task, define what "good output" looks like as binary yes/no checks, then run an autonomous loop that:

1. **Runs the task with different LLM approaches** (Kimi + Fireworks, Claude + direct API, GPT-4, local Ollama, etc.)
2. **Tracks quality, cost, and speed** for every run
3. **Compares against a baseline** (usually the most expensive approach)
4. **Analyzes trade-offs** (is 20% cheaper worth 5% quality loss?)
5. **Recommends the optimal approach** for this specific task

**Output:** A comparison matrix + dashboard + detailed recommendations explaining which model to use, when, and why.

---

## before starting: gather context

**STOP. Ask the user for all fields before proceeding.**

1. **The task** — What problem are we solving? (e.g., "code review of Rust code", "generate test cases", "explain architecture", "write documentation")

2. **Success criteria (evals)** — 3-5 binary yes/no checks that define "good output"
   - Examples: "Does output include all edge cases?", "Is explanation understandable by a junior dev?", "Are code examples syntactically correct?"
   - See [references/eval-guide.md](../autoresearch/references/eval-guide.md) for how to write good evals

3. **Test inputs** — 3-5 representative examples (variety matters to avoid overfitting)
   - For "code review": 3 code samples of different complexity levels
   - For "test generation": 3 functions from different domains
   - For "documentation": 3 different architecture examples

4. **Models to test** — Which LLM approaches should we compare?
   - Option A: Different providers (Claude, GPT-4, Kimi, Gemini, local Llama)
   - Option B: Same provider, different tiers (Claude Opus vs Sonnet, GPT-4 vs GPT-4 Mini)
   - Option C: Different configurations (temp 0.3 vs 0.7, max_tokens 2k vs 8k)
   - Option D: Different prompt structures (few-shot vs zero-shot, system prompt variants)
   - **Typical: pick 3-5 configurations to compare** (not 20 — too many combinations)

5. **Budget and constraints**
   - Max spend per run? (default: no limit)
   - Max total spend? (default: $100)
   - Speed requirement? ("must be <5s per run" or "no constraint")
   - Context length available? (some tasks need long context)

---

## step 1: understand the task

Before testing anything, understand exactly what you're optimizing for.

1. Read the task description carefully
2. Identify the measurable outcome (what counts as "success"?)
3. Note any constraints (response time, cost limits, tokens available)
4. Gather or create the test inputs (if user didn't provide them)
5. Confirm evals with the user (don't proceed until evals are locked in)

---

## step 2: build the eval suite

Convert success criteria into 3-5 binary yes/no checks. See autoresearch's eval guide.

**Examples for "code review" task:**
- EVAL 1: "Does output identify all potential bugs?" (Yes if ≥80% coverage, No otherwise)
- EVAL 2: "Are suggestions actionable?" (Yes if specific code changes, No if vague)
- EVAL 3: "Is feedback delivered respectfully?" (Yes if no harsh language, No if tone is critical)

**Max score = [number of evals] × [number of test inputs]**
- Example: 4 evals × 4 test inputs = 16 max score

---

## step 3: generate the comparison dashboard

Create `usage-researcher-[task-name]/dashboard.html` with:
- A table comparing all models: Cost/Output, Quality Score, Speed, Recommended?
- A scatter plot: X-axis = cost per run, Y-axis = quality score (hover shows model name)
- A bar chart: Model on X, score on Y
- A timeline: Which runs improved/degraded from baseline
- Summary stats: Cheapest, Best Quality, Fastest, Recommended

Format should make trade-offs obvious. Example:
```
Model              Quality  Cost    Speed    Recommendation
Claude Opus        18/20    $0.08   2.3s     Baseline
Kimi K2.5          16/20    $0.01   0.4s     👍 95% quality at 87% cheaper
GPT-4 Turbo        19/20    $0.12   1.8s     Best quality, most expensive
Claude Sonnet      17/20    $0.03   1.1s     Good compromise
```

Generate as self-contained HTML with inline CSS/JS. Chart.js from CDN for visualization.

---

## step 4: establish baseline

Pick one configuration as the baseline (usually the most capable/expensive model: Claude Opus or GPT-4 Turbo).

1. Create working directory: `usage-researcher-[task-name]/`
2. Run baseline with all test inputs (e.g., 4 test inputs = 4 runs)
3. Score each output against evals
4. Record baseline score and cost
5. Create `comparison.tsv` with baseline row:

```
model               score   max_score  quality    cost   speed_ms  status      notes
claude-opus         16      20         80%        0.08   2300      baseline    Original expensive approach
```

---

## step 5: test alternative approaches

**Run experiments in order of increasing cost/complexity:**

**Run 1: Cheapest option first** (e.g., Kimi on Fireworks)
- Cost: often 5-10x cheaper
- Quality: might be 70-90% of baseline
- If it hits 90%+ on evals, you've found your winner

**Run 2: Speed-optimized** (smaller model, lower temp)
- Cost: medium
- Quality: medium
- Best for: tasks where latency matters

**Run 3: Few-shot variant** (same model as baseline, but with examples)
- Cost: same as baseline (maybe slightly more tokens)
- Quality: often better (10-15% improvement)
- Shows if prompt structure helps

**Run 4: Temperature trade-off** (baseline at temp 0.3 vs 0.7)
- Cost: same
- Quality: varies by task
- Shows if less determinism helps

**For each experiment:**
1. Run with all test inputs
2. Score each output
3. Calculate cost, speed, quality
4. Log in comparison.tsv
5. Compare to baseline

---

## step 6: analyze trade-offs

This is the key insight: **cost vs quality**.

Create a decision matrix:
```
Task Type              Best Model          Quality/Cost Ratio  Note
Simple bug fix         Kimi K2.5            95% / 1x cost       Use this by default
Complex refactor       Claude Sonnet        90% / 3x cost       Worth extra cost
Algorithm design       Claude Opus          100% / 8x cost      Only if truly novel
```

---

## step 7: recommendations

After testing, write `recommendations.md`:

```markdown
# LLM Usage Recommendations for [Task]

## Summary
- Baseline: Claude Opus ($0.08/run, 80% score)
- Recommended: Kimi K2.5 via Fireworks ($0.01/run, 80% score)
- **Annual savings at 100 tasks/month: ~$84**

## Analysis

### Top Approaches by Metric
- **Best Quality**: Claude Opus (18/20)
- **Best Cost**: Kimi K2.5 ($0.01, 16/20)
- **Best Speed**: Kimi K2.5 (0.4s)
- **Best Value**: Claude Sonnet (17/20, $0.03)

### Trade-off Analysis
1. **Kimi vs Opus**: 89% quality at 87% cost savings ✅ Recommended
2. **Sonnet vs Opus**: 94% quality at 62% cost savings ✅ Good compromise
3. **Few-shot prompt**: +5% quality, +2% cost (marginal improvement)

### Decision Tree
```
Is output quality critical (≥95%)? → YES: Use Claude Opus
                                    → NO:  Use Kimi K2.5
```

### When to Use Each Model
- **Kimi K2.5**: Simple tasks, routine work, code review of familiar patterns
- **Claude Sonnet**: Medium complexity, when you need better than Kimi
- **Claude Opus**: Novel problems, complex analysis, research-grade output
- **GPT-4 Turbo**: When you need image input or latest knowledge cutoff

### Estimated Annual Usage
```
- 60% tasks on Kimi ($0.01): High-volume, well-scoped work
- 30% tasks on Sonnet ($0.03): Medium complexity
- 10% tasks on Opus ($0.08): Hard problems, design decisions

Monthly: 100 tasks × [0.6×$0.01 + 0.3×$0.03 + 0.1×$0.08] = ~$4.70
Annual: ~$56 (vs $96 with Opus for everything)
```

## Files
- `comparison.tsv` — All runs with scores and costs
- `results.json` — Data powering the dashboard
- `dashboard.html` — Visual comparison
- `changelog.md` — Every experiment attempted
```

---

## step 8: deliver results

Present:
1. **Recommendation**: "Use X for this task because [specific reasons]"
2. **Quality comparison**: Baseline → Recommended (% change)
3. **Cost savings**: Annual impact if used consistently
4. **Trade-offs**: What you gain/lose with the recommended model
5. **When to upgrade**: "Switch to Opus if [specific condition]"
6. **All files**: Directory structure and how to use results

---

## output files

```
usage-researcher-[task-name]/
├── dashboard.html       # Visual comparison (costs, quality, speed)
├── results.json         # Data powering dashboard
├── comparison.tsv       # Every run (model, score, cost, speed)
├── recommendations.md   # Final recommendation + decision tree
└── changelog.md         # Every experiment tried + reasoning
```

---

## example: optimizing "code review" task

**Setup:**
- Task: Review Rust code changes in pull requests
- Evals: (1) Finds all bugs? (2) Suggestions actionable? (3) Tone respectful?
- Test inputs: 4 PRs of varying complexity
- Max score: 12 (3 evals × 4 runs)

**Baseline (Claude Opus):**
- Score: 11/12 (92%)
- Cost: $0.08 per review
- Speed: 2.3s
- Status: Expensive but good baseline

**Experiment 1: Kimi K2.5 (Fireworks)**
- Score: 10/12 (83%)
- Cost: $0.01 per review
- Speed: 0.4s
- Status: **RECOMMENDED** — 87% cost savings, acceptable quality loss
- Why: Simple code review doesn't need Opus-level reasoning

**Experiment 2: Claude Sonnet**
- Score: 11/12 (92%)
- Cost: $0.03 per review
- Speed: 1.1s
- Status: Great compromise if you want Opus-quality at Kimi-speed

**Experiment 3: Few-shot Opus** (baseline with 2 examples)
- Score: 12/12 (100%)
- Cost: $0.09 per review
- Speed: 2.8s
- Status: KEEP — slight cost increase, perfect quality

**Final Recommendation:**
- Use **Kimi K2.5** for simple reviews (87% cost savings)
- Use **Sonnet** for complex changes (62% cost savings, better quality)
- Use **Opus with examples** only when output quality is critical (best quality)
- Annual savings: 80 reviews/month × 11 months × $0.07 savings = ~$62

---

## integration with other patterns

**Feeds from:**
- A task you want to optimize LLM usage for
- User-defined success criteria

**Feeds into:**
- Your actual workflow (use the recommended model going forward)
- Cost tracking and budgeting
- The `/improve-my-codebase` skill (when recommending LLM usage for code optimization)

---

## key principles

1. **Test cheap first** — Start with Kimi, then work up. You might be done at the first model.
2. **Binary evals only** — No scales. Yes/no only.
3. **Quality vs cost trade-off is explicit** — Show the cost of perfectionism.
4. **Recommendation is actionable** — "Use Sonnet" not "consider exploring alternatives"
5. **Decision tree is clear** — "If X, use Y" not "it depends"
6. **Test with real inputs** — Don't optimize for toy examples

---

## the test

A good LLM usage researcher run:

- ✅ Tested at least 3 different approaches
- ✅ Measured quality, cost, and speed for each
- ✅ Used binary evals (not subjective scoring)
- ✅ Compared to a clear baseline
- ✅ Recommended the best approach for the specific task
- ✅ Explained the trade-offs (what you gain/lose)
- ✅ Provided a decision tree for when to use which model
- ✅ Calculated actual cost savings or quality gains
- ✅ Delivered actionable recommendation

If the recommendation is "it depends" without clear decision criteria, the evals are bad or the approaches aren't differentiated enough. Try again with clearer evals.
