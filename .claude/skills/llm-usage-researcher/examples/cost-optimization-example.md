# Example: LLM Cost Optimization for Daily Development Work

**Scenario**: Ian needs to decide between Kimi K2.5 (cheap, fast) and Claude Opus (expensive, powerful) for routine development tasks.

---

## Setup

**Task**: Code review and simple feature implementation for rfsystems project

**Test Inputs** (representative work):
1. Review PR #100 (simple bug fix)
2. Implement feature: add user profile endpoint
3. Generate test cases for auth module
4. Refactor database query for performance
5. Explain architecture decision to team member

**Success Criteria** (Evals):
1. Does output identify all actual issues/improvements? (>70% coverage)
2. Are suggestions actionable and specific? (includes code examples)
3. Does output follow team standards? (matches rfsystems patterns)

**Models to Test**:
- Kimi K2.5 via Fireworks
- Claude Sonnet via Anthropic
- Claude Opus via Anthropic (baseline)

---

## Baseline Run: Claude Opus

**Configuration**:
- Model: Claude Opus
- Provider: Anthropic API
- Temperature: 0.3 (deterministic)
- Context: full codebase context available
- Cost: $0.08/run average

**Results**:
```
Test Input                      Score   Issues Found  Actionable?  Pattern Match
1. Review PR #100               3/3     All 2         Yes          100%
2. Feature: user profile        3/3     N/A           Yes          100%
3. Generate tests               2.5/3   ✓✓✓✓✓         Specific     90%
4. Refactor query               3/3     Found N+1     Yes          100%
5. Explain architecture         3/3     N/A           Yes          100%

TOTAL SCORE: 14.5/15 (96.7%)
Cost: $0.40 (5 runs × $0.08)
Speed: ~2.5s avg
```

**Assessment**: Excellent baseline. Very reliable. Expensive.

---

## Experiment 1: Kimi K2.5 via Fireworks

**Configuration**:
- Model: Kimi K2.5
- Provider: Fireworks AI
- Temperature: 0.3
- Context: same as Opus
- Cost: $0.01/run average

**Results**:
```
Test Input                      Score   Issues Found  Actionable?  Pattern Match
1. Review PR #100               2/3     Missed type   Somewhat     70%
2. Feature: user profile        3/3     N/A           Yes          100%
3. Generate tests               2/3     ✓✓✓           Good         70%
4. Refactor query               2/3     Missed index  Somewhat     80%
5. Explain architecture         2.5/3   N/A           Vague        70%

TOTAL SCORE: 11.5/15 (76.7%)
Cost: $0.05 (5 runs × $0.01)
Speed: ~0.4s avg
```

**Assessment**: Good enough for routine work. Much cheaper and faster. Misses subtle issues.

**Trade-off Analysis**:
- Quality: 76.7% vs 96.7% (20 percentage point difference)
- Cost: $0.01 vs $0.08 (87% savings)
- Speed: 0.4s vs 2.5s (6x faster)

---

## Experiment 2: Claude Sonnet

**Configuration**:
- Model: Claude Sonnet
- Provider: Anthropic API
- Temperature: 0.3
- Context: same as Opus
- Cost: $0.03/run average

**Results**:
```
Test Input                      Score   Issues Found  Actionable?  Pattern Match
1. Review PR #100               3/3     All 2         Yes          100%
2. Feature: user profile        3/3     N/A           Yes          100%
3. Generate tests               2.5/3   ✓✓✓✓          Specific     90%
4. Refactor query               2.5/3   Found N+1     Somewhat     90%
5. Explain architecture         3/3     N/A           Yes          100%

TOTAL SCORE: 14/15 (93.3%)
Cost: $0.15 (5 runs × $0.03)
Speed: ~1.1s avg
```

**Assessment**: Almost as good as Opus (93% vs 96%), much cheaper, faster.

**Trade-off Analysis**:
- Quality: 93.3% vs 96.7% (3 percentage point difference)
- Cost: $0.03 vs $0.08 (62% savings)
- Speed: 1.1s vs 2.5s (2.3x faster)

---

## Experiment 3: Kimi K2.5 + Few-Shot Prompt

**Configuration**:
- Model: Kimi K2.5
- Provider: Fireworks AI
- Added: 2 examples showing expected output format and patterns
- Cost: $0.015/run average (slightly more tokens)

**Results**:
```
Test Input                      Score   Issues Found  Actionable?  Pattern Match
1. Review PR #100               2.5/3   Found 1/2     Yes          90%
2. Feature: user profile        3/3     N/A           Yes          100%
3. Generate tests               2.5/3   ✓✓✓✓          Good         80%
4. Refactor query               2.5/3   Found N+1     Yes          90%
5. Explain architecture         3/3     N/A           Yes          100%

TOTAL SCORE: 13.5/15 (90%)
Cost: $0.075 (5 runs × $0.015)
Speed: ~0.5s avg
```

**Assessment**: Kimi improved with examples! 90% quality, still cheap.

**Trade-off Analysis**:
- Quality: 90% vs 96.7% (6.7 percentage point difference)
- Cost: $0.015 vs $0.08 (81% savings)
- Speed: 0.5s vs 2.5s (5x faster)

---

## Comparison Matrix

```
Model                Quality  Cost/Run  Speed   Annual (100 tasks/month)  Recommendation
─────────────────────────────────────────────────────────────────────────────────────
Claude Opus          96.7%    $0.08    2.5s    $96 (12 months)           Baseline
Claude Sonnet        93.3%    $0.03    1.1s    $36                       ✅ Compromise
Kimi (no examples)   76.7%    $0.01    0.4s    $12                       Simple work only
Kimi (few-shot)      90.0%    $0.015   0.5s    $18                       ✅ Best value
```

---

## Recommendation

### Primary Strategy: Use Kimi K2.5 (Few-Shot) for 80% of Work

**Why**: 
- 90% of Opus quality
- 81% cost savings ($0.015 vs $0.08)
- 5x faster response time
- With examples, it handles routine patterns well

**Use for**:
- Simple code reviews
- Routine feature implementation
- Test generation from clear specs
- Documentation and explanations
- Refactoring well-understood code

### Secondary Strategy: Use Claude Sonnet for 15% of Work

**Why**:
- 93% of Opus quality (only 3.7 points better than Kimi few-shot)
- 62% cost savings vs Opus
- 2.3x faster than Opus
- Better for slightly ambiguous or novel problems

**Use for**:
- Complex architectural decisions
- Subtle bugs (Kimi misses ~20% of edge cases)
- Refactoring with performance implications
- Explaining novel solutions

### Reserve: Claude Opus for 5% of Work

**Why**:
- Best quality (96.7%)
- Only for truly critical decisions

**Use for**:
- Security-critical code review
- Highest-stakes architectural decisions
- When you absolutely cannot afford to miss anything

---

## Annual Impact

```
Current approach: 100% Opus
  100 tasks/month × 12 months × $0.08 = $96/year

Optimized approach:
  - 80 tasks on Kimi ($0.015) = $14.40
  - 15 tasks on Sonnet ($0.03) = $5.40
  - 5 tasks on Opus ($0.08) = $4.80
  Total: $24.60/year

SAVINGS: $71.40/year (75% reduction)
QUALITY IMPACT: 90-93% vs 96.7% (minimal for routine work)
```

---

## Implementation Plan

### Week 1: Switch to Kimi + Few-Shot Examples

1. Create few-shot prompt examples for code review
2. Use Kimi for all simple code reviews
3. Monitor: Are we missing important issues?
4. Adjust: If >5% of issues missed, add more examples

### Week 2: Deploy Kimi for Feature Work

1. Use Kimi for routine feature implementation
2. Compare outputs to previous Opus runs
3. Verify: Do implementations pass tests?
4. Adjust: If test failure rate >2%, revert to Sonnet

### Week 3: Selective Sonnet Usage

1. For architectural/performance decisions, use Sonnet
2. Track: Does Sonnet's advice lead to better outcomes?
3. Verify: Is the 3.7 point quality difference worth it?

### Week 4: Annual Review

1. Track costs and quality metrics
2. Assess whether the 75% savings is real
3. Adjust strategy if needed

---

## Decision Tree

```
Is this a SIMPLE, WELL-SCOPED task?
├─ YES: Use Kimi K2.5 (few-shot) → $0.015, 90% quality
└─ NO: Is quality CRITICAL?
   ├─ YES: Use Claude Opus → $0.08, 96.7% quality
   └─ NO: Use Claude Sonnet → $0.03, 93% quality
```

---

## Files Generated

- `comparison.tsv` — All 15 runs detailed
- `results.json` — Data for dashboard
- `dashboard.html` — Visual cost/quality/speed comparison
- `this file` — Detailed analysis and recommendation
- `changelog.md` — Every experiment tried and why
