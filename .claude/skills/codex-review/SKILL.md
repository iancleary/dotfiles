---
name: codex-review
description: Send the current plan to OpenAI Codex CLI for iterative review. Claude and Codex go back-and-forth until Codex approves the plan.
user_invocable: true
---

## Codex Plan Review (Iterative)

Send the current implementation plan to OpenAI Codex for review. Claude revises the plan based on Codex's feedback and re-submits until Codex approves. Max 5 rounds.

## When to Invoke

- When the user runs `/codex-review` during or after plan mode
- When the user wants a second opinion on a plan from a different model

## Agent Instructions

When invoked, perform the following iterative review loop:

### Step 1: Create Secure Temp Files

Create temp files with restrictive permissions and register cleanup trap:

```bash
umask 077
PLAN_FILE=$(mktemp /tmp/claude-plan-XXXXXX.md)
REVIEW_FILE=$(mktemp /tmp/codex-review-XXXXXX.md)
CONTEXT_FILE=$(mktemp /tmp/codex-context-XXXXXX.md)

# Only register cleanup trap if --keep-artifacts was NOT passed
if [[ "$KEEP_ARTIFACTS" != "true" ]]; then
  trap 'rm -f "$PLAN_FILE" "$REVIEW_FILE" "$CONTEXT_FILE"' EXIT INT TERM
fi
```

Track the resolved model name for consistent reporting:

```bash
CODEX_MODEL="${USER_OVERRIDE_MODEL:-default from config}"
```

If the user specified a model (e.g., `/codex-review o4-mini`), validate it matches `^[A-Za-z0-9._-]+$` before use. If invalid, reject and ask the user to correct it.

### Step 2: Capture the Plan

Write the current plan to the secure temp file. The plan is whatever implementation plan exists in the current conversation context (from plan mode, or a plan discussed in chat).

- Write the full plan content to `$PLAN_FILE`
- If there is no plan in the current context, ask the user what they want reviewed

### Step 3: Initial Review (Round 1)

Run Codex CLI in non-interactive mode to review the plan:

```bash
codex exec \
  ${MODEL_FLAG} \
  -s read-only \
  -o "$REVIEW_FILE" \
  "Review the implementation plan in $PLAN_FILE. Focus on:
1. Correctness - Will this plan achieve the stated goals?
2. Risks - What could go wrong? Edge cases? Data loss?
3. Missing steps - Is anything forgotten?
4. Alternatives - Is there a simpler or better approach?
5. Security - Any security concerns?

Be specific and actionable. If the plan is solid and ready to implement, end your review with EXACTLY this line on its own: VERDICT: APPROVED

If changes are needed, end with EXACTLY this line on its own: VERDICT: REVISE

You MUST end with one of these two verdict lines — no exceptions."
```

Where `MODEL_FLAG` is empty (use config default) or `-m <validated_model>` if user specified one.

Extract the Codex session ID from the review file (which captures the full output including session metadata):

```bash
CODEX_SESSION_ID=$(grep -Eio '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' "$REVIEW_FILE" | head -1)
```

If no valid UUID is found in the output file, log a warning — session resume won't be possible, but the skill can still fall back to fresh exec calls with the context file.

Notes:
- Omit `-m` to use the default model from `~/.codex/config.toml`. If the user specifies a different model (e.g., `/codex-review o4-mini`), add `-m <model>` after validation.
- Use `-s read-only` so Codex can read the codebase for context but cannot modify anything.
- Use `-o` to capture the output to a file for reliable reading.

### Step 4: Read Review & Check Verdict

- Read `$REVIEW_FILE`
- Present Codex's review to the user:

```
## Codex Review — Round N (model: $CODEX_MODEL)

[Codex's feedback here]
```

- Check the verdict by examining the **last 5 lines** of the review file for the exact verdict token (the prompt text also contains these strings, so only check the tail):

```bash
VERDICT=$(tail -5 "$REVIEW_FILE" | grep -xo 'VERDICT: \(APPROVED\|REVISE\)' | tail -1)
```

The `-x` flag ensures the verdict must be the **entire line**, not a substring match.

  - If `VERDICT: APPROVED` → go to Step 7 (Done)
  - If `VERDICT: REVISE` → go to Step 5 (Revise & Re-submit)
  - If **neither verdict is found in the last 5 lines** → ask Codex to restate its verdict in the next round with explicit instruction to end with `VERDICT: APPROVED` or `VERDICT: REVISE`. Do NOT assume approval from ambiguous output.
  - If max rounds (5) reached → go to Step 7 with a note that max rounds hit

### Step 5: Revise the Plan

Based on Codex's feedback:

- Revise the plan — address each issue Codex raised. Update the plan content in the conversation context and rewrite `$PLAN_FILE` with the revised version.
- Append a round summary to `$CONTEXT_FILE` for fallback reconstruction:

```
### Round N Summary
- Issues raised: [list]
- Revisions made: [list]
```

- Briefly summarize what you changed for the user:

```
### Revisions (Round N)
- [What was changed and why, one bullet per Codex issue addressed]
```

- Inform the user: "Sending revised plan back to Codex for re-review..."

### Step 6: Re-submit to Codex (Rounds 2-5)

Resume the existing Codex session so it has full context of the prior review. Capture full output to the review file:

```bash
codex exec resume ${CODEX_SESSION_ID} \
  "I've revised the plan based on your feedback. The updated plan is in $PLAN_FILE.

Here's what I changed:
[List the specific changes made]

Please re-review. If the plan is now solid and ready to implement, end with EXACTLY: VERDICT: APPROVED
If more changes are needed, end with EXACTLY: VERDICT: REVISE" 2>&1 | tee "$REVIEW_FILE"
RESUME_EXIT=${PIPESTATUS[0]}
```

Note: `codex exec resume` does NOT support `-o` flag. Use `tee` to capture full output to the review file while also displaying it. Do NOT use `tail` — it can truncate the verdict.

Check `RESUME_EXIT` — if non-zero, the resume failed. Fall back to a fresh `codex exec` call with the context file.

**Fallback:** If `resume ${CODEX_SESSION_ID}` fails (e.g., session expired or ID was not captured), fall back to a fresh `codex exec` call. Include the contents of `$CONTEXT_FILE` (accumulated round summaries) and the current plan in the prompt to reconstruct context.

Then go back to Step 4.

### Step 7: Present Final Result

Once approved (or max rounds reached):

```
## Codex Review — Final (model: $CODEX_MODEL)

**Status:** ✅ Approved after N round(s)

[Final Codex feedback / approval message]

---
**The plan has been reviewed and approved by Codex. Ready for your approval to implement.**
```

If max rounds reached without approval:

```
## Codex Review — Final (model: $CODEX_MODEL)

**Status:** ⚠️ Max rounds (5) reached — not fully approved

**Remaining concerns:**
[List unresolved issues from last review]

---
**Codex still has concerns. Review the remaining items and decide whether to proceed or continue refining.**
```

### Step 8: Cleanup

Cleanup is handled automatically by the `trap` registered in Step 1. If `--keep-artifacts` was passed by the user, skip cleanup and print the file paths for debugging/audit:

```bash
if [[ "$KEEP_ARTIFACTS" == "true" ]]; then
  echo "Artifacts preserved:"
  echo "  Plan:    $PLAN_FILE"
  echo "  Review:  $REVIEW_FILE"
  echo "  Context: $CONTEXT_FILE"
else
  rm -f "$PLAN_FILE" "$REVIEW_FILE" "$CONTEXT_FILE"
fi
```

## Loop Summary

```
Round 1: Claude sends plan → Codex reviews → REVISE?
Round 2: Claude revises → Codex re-reviews (resume session) → REVISE?
Round 3: Claude revises → Codex re-reviews (resume session) → APPROVED ✅
```

Max 5 rounds. Each round preserves Codex's conversation context via session resume. Round summaries are persisted to a context file for fallback reconstruction.

## Rules

- Claude actively revises the plan based on Codex feedback between rounds — this is NOT just passing messages, Claude should make real improvements
- Default model: use whatever is configured in `~/.codex/config.toml`. Accept model override from user arguments (e.g., `/codex-review o4-mini`). Validate model name matches `^[A-Za-z0-9._-]+$` before shell interpolation.
- Always use `read-only` sandbox mode — Codex should never write files
- Max 5 review rounds to prevent infinite loops
- Show the user each round's feedback and revisions so they can follow along
- If Codex CLI is not installed or fails, inform the user and suggest `npm install -g @openai/codex`
- If a revision contradicts the user's explicit requirements, skip that revision and note it for the user
- Require exact `VERDICT: APPROVED` or `VERDICT: REVISE` tokens — never infer approval from ambiguous output
- Use `mktemp` for all temp files, `umask 077` for permissions, `trap` for guaranteed cleanup
- Support `--keep-artifacts` flag to preserve temp files for debugging
