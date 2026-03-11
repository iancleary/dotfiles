---
argument-hint: [bug description, file, or function that regressed]
description: Investigate a regression using git history to find when/why it broke and why no test caught it
allowed-tools: Bash, Read, Glob, Grep, Agent
---

Investigate a regression using git history. Find the breaking commit, understand why it happened, and determine why no test caught it.

## Phase 1: Confirm the Regression

1. **Reproduce the bug** — get a concrete failing test or reproduction step
2. **Verify it's a regression** — check that the behavior previously worked:
   - `git stash && git checkout HEAD~N` to test older versions
   - Or use `git log --oneline -20 -- <file>` to see recent changes to the affected file

## Phase 2: Find the Breaking Commit

Use git history to pinpoint exactly when the regression was introduced.

**Start narrow, then widen:**

1. **Check recent changes to the affected file(s):**
   ```
   git log --oneline -20 -- <file>
   git log --oneline --all -- <file>
   ```

2. **Read diffs of suspect commits:**
   ```
   git show <commit> -- <file>
   git diff <before>..<after> -- <file>
   ```

3. **If the culprit isn't obvious, use git bisect:**
   ```
   git bisect start
   git bisect bad          # current commit is broken
   git bisect good <hash>  # known-good commit
   # test at each step, mark good/bad
   git bisect reset        # when done
   ```

4. **For function-level history:**
   ```
   git log -p -S '<function_name>' -- <file>
   git log -L :<function_name>:<file>
   ```

## Phase 3: Analyze the Breaking Commit

Once you've found the commit, answer these questions:

1. **What changed?** — Read the full diff carefully
2. **What was the intent?** — Read the commit message, linked PR/issue
3. **How did it break things?** — Trace the data flow from the change to the broken behavior
4. **Was it a direct cause or a side effect?** — Did the author touch the broken code, or did a change elsewhere cascade?

Use `gh pr list --search '<commit hash>'` or `git log --oneline --grep='<keyword>'` to find related PRs and context.

## Phase 4: Investigate the Test Coverage Gap

Determine why no test caught this regression:

1. **Search for existing tests:**
   ```
   grep -r '<function_name>' tests/ src/ --include='*test*'
   ```
   Or use Grep to find test files referencing the affected code.

2. **Classify the gap:**
   - **No test existed** — the behavior was never tested
   - **Test existed but was insufficient** — didn't cover this case/input
   - **Test was removed or weakened** — check `git log -p --diff-filter=D -- '*test*'` and the breaking commit's diff
   - **Test exists but wasn't run** — CI configuration issue, feature flag, conditional compilation

3. **Check if the breaking commit modified tests:**
   ```
   git show <commit> -- '*test*' '*/tests/*'
   ```

## Phase 5: Produce Findings and Recommendations

Summarize your investigation with:

### Report Format

**Regression:** [one-line description of what broke]

**Breaking commit:** `<hash>` — `<commit message summary>`
- Author: `<name>`
- Date: `<date>`
- PR: `<link if found>`

**Root cause:** [explanation of how the change caused the regression]

**Test gap:** [why no test caught it — use the classification from Phase 4]

**Recommendations:**
1. **Immediate:** Write a test that would have caught this regression (describe the test case)
2. **Preventive:** What review checklist item, CI check, or coding pattern would prevent this class of regression
3. **Systemic:** If this reveals a pattern (e.g., "refactors in module X frequently break Y"), note it

## Red Flags — Indicators of Deeper Issues

- Breaking commit had no tests at all — suggests a testing culture gap
- Breaking commit modified tests to make them pass with wrong behavior — suggests insufficient review
- Multiple recent regressions in the same area — suggests the module needs refactoring or better integration tests
- The regression survived for many commits — suggests the affected behavior lacks any automated verification
