# LLM Usage Eval Patterns

Common evaluation patterns for comparing LLM approaches on the same task.

---

## Code Review Evals

**Good evals for assessing code review output:**

```
EVAL 1: Coverage
Question: Did the review identify >80% of actual bugs/issues?
Pass: Points out 4+ out of 5 seeded bugs
Fail: Points out <3 bugs

EVAL 2: Actionability
Question: Are suggestions specific and implementable?
Pass: Includes code examples or specific line numbers
Fail: Suggestions are vague ("improve error handling")

EVAL 3: Tone
Question: Is feedback delivered respectfully?
Pass: No harsh language, constructive framing
Fail: Contains words like "obviously", "bad", "wrong"
```

---

## Documentation Quality Evals

```
EVAL 1: Completeness
Question: Does it cover the main concepts without omissions?
Pass: All major components explained, no TODOs or "TK"
Fail: Skips major components or marked as incomplete

EVAL 2: Clarity
Question: Is it understandable by target audience?
Pass: A junior dev could implement based on doc
Fail: Requires re-reading or external knowledge to understand

EVAL 3: Accuracy
Question: Are code examples syntactically correct?
Pass: All examples compile/run without errors
Fail: Examples have syntax errors or won't execute
```

---

## Test Generation Evals

```
EVAL 1: Coverage
Question: Do tests cover happy path, edge cases, and error paths?
Pass: >70% branch coverage, tests 3+ cases per function
Fail: <50% coverage or only happy path

EVAL 2: Clarity
Question: Are test names descriptive and readable?
Pass: Can tell what's being tested from test name alone
Fail: Vague names like test_1, test_function, etc.

EVAL 3: Independence
Question: Are tests independent and non-flaky?
Pass: Tests pass 5/5 runs, no timing dependencies
Fail: Tests fail intermittently or depend on execution order

EVAL 4: Assertions
Question: Are assertions specific?
Pass: Each test has clear, specific assertions
Fail: Uses generic assertions or mock-checks everything
```

---

## Feature Implementation Evals

```
EVAL 1: Completeness
Question: Does code implement full feature spec?
Pass: All acceptance criteria from spec are met
Fail: Missing features or partial implementation

EVAL 2: Code Quality
Question: Does code follow team standards?
Pass: Passes linting, has no obvious code smells
Fail: Style violations or complex logic without comments

EVAL 3: Test Coverage
Question: Is code testable and tested?
Pass: >80% code coverage, tests included
Fail: <50% coverage or no tests

EVAL 4: No Regressions
Question: Does it avoid breaking existing functionality?
Pass: Existing tests still pass
Fail: Existing tests fail or have to be modified
```

---

## Analysis & Research Evals

```
EVAL 1: Depth
Question: Does analysis go beyond surface level?
Pass: Includes reasoning, trade-offs, and nuance
Fail: One-sentence answers or obvious statements

EVAL 2: Sources
Question: Are claims backed by evidence?
Pass: Includes specific examples, citations, or reasoning
Fail: Unsupported assertions or "just trust me"

EVAL 3: Structure
Question: Is information organized logically?
Pass: Clear sections, easy to scan and understand
Fail: Rambling, hard to extract key points

EVAL 4: Actionability
Question: Does analysis lead to a decision or next step?
Pass: Clear recommendation or decision criteria
Fail: "It depends" without decision framework
```

---

## API/Integration Evals

```
EVAL 1: Correctness
Question: Does code correctly use the API?
Pass: API calls match documentation, no errors
Fail: Incorrect method signatures or parameter order

EVAL 2: Error Handling
Question: Does code handle API errors gracefully?
Pass: Catches errors, retries on transient failures
Fail: Ignores errors or crashes on API failures

EVAL 3: Efficiency
Question: Does code minimize API calls?
Pass: No N+1 queries, batches when appropriate
Fail: Redundant API calls or inefficient patterns

EVAL 4: Security
Question: Are credentials and data handled safely?
Pass: No hardcoded secrets, proper auth headers
Fail: Secrets in code or insecure data handling
```

---

## What Makes a Good Eval

✅ **Binary** — Yes or no. Not "rate 1-10" or "pretty good"
✅ **Measurable** — Can be verified by running the code or reading the output
✅ **Independent** — Doesn't require other evals to pass to be meaningful
✅ **Fair** — Doesn't advantage one model's style over another's
✅ **Stable** — Same output would pass/fail consistently
✅ **Focused** — Each eval checks one thing, not multiple things at once

---

## What Makes a Bad Eval

❌ **Vague**: "Is this good?" (unmeasurable)
❌ **Compound**: "Does it handle errors AND is it efficient?" (two evals in one)
❌ **Scale-based**: "Rate quality 1-10" (introduces grader variability)
❌ **Unfair**: Optimizes for output format instead of actual quality
❌ **Unmeasurable**: "Does it feel right?" (subjective)
❌ **Biased**: "Does it use my preferred coding style?" (favors one approach)

---

## eval workflow for llm-usage-researcher

1. **User describes the task**
2. **You propose 3-5 eval candidates** based on patterns above
3. **User confirms or refines them** (make sure they're binary and fair)
4. **Lock them in before testing** (don't change evals mid-experiment)
5. **Use them consistently** across all models
