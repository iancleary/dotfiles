# Ralph-Codex: Autonomous Feature Development Loop

Ralph-Codex is a CLI-based autonomous loop that spawns fresh Codex sessions iteratively until a feature converges to completion.

**Inspired by**: [Ralph by Ryan Carson](https://github.com/snarktank/ralph)  
**Enhanced for**: OpenClaw + Codex CLI  
**Pattern**: PRD → Codex Session #1 → Review → Codex Session #2 → ... → Complete

---

## Why Ralph-Codex?

Traditional development:
- ❌ Manual iteration between you and the AI
- ❌ Context accumulates (tokens waste)
- ❌ Progress tracking is implicit
- ❌ Hard to know when you're done

Ralph-Codex loop:
- ✅ Fresh context each iteration (CLI spawn)
- ✅ Automated convergence detection
- ✅ Explicit progress tracking (progress.txt)
- ✅ Full git history of how solution evolved
- ✅ Parallel to sub-agent patterns (familiar to OpenClaw users)

---

## Installation

Ralph-Codex ships with dotfiles. Make it executable:

```bash
chmod +x ~/.dotfiles/skills/ralph-codex/ralph-codex.sh
```

Or add to your PATH:

```bash
ln -s ~/.dotfiles/skills/ralph-codex/ralph-codex.sh ~/.local/bin/ralph-codex
```

---

## Quick Start

### 1. Create a PRD

```bash
cat > prd.json << 'EOF'
{
  "title": "User Authentication",
  "description": "Implement secure user login with sessions",
  "requirements": [
    "[ ] Login page with email/password inputs",
    "[ ] Password validation (8+ chars, mixed case)",
    "[ ] Session token generation (JWT)",
    "[ ] Session persistence (cookie)",
    "[ ] Logout functionality",
    "[ ] Unit tests (90%+ coverage)",
    "[ ] Rate limiting (5 attempts/hour)"
  ]
}
EOF
```

### 2. Run Ralph-Codex

```bash
./ralph-codex.sh prd.json 10
```

**Arguments:**
- `prd.json` — Your PRD file (required)
- `10` — Max iterations (default: 10)

### 3. Codex Sessions Loop Automatically

Ralph-Codex will:
1. Spawn a Codex session with your PRD
2. Show you the prompt
3. Wait for your Codex session to complete
4. Detect if the feature is done
5. If not done, spawn another session with accumulated progress
6. Repeat until convergence or max iterations

---

## How It Works

### Iteration Flow

```
Iteration 1:
  - Codex Session: "Implement login page + session tokens"
  - Output: iteration-1.md with partial implementation
  - Progress check: Not done yet
  - Update progress.txt with status
  - Commit to git
  
Iteration 2:
  - Codex Session: "Here's what we have... continue with logout + tests"
  - Output: iteration-2.md with more work done
  - Progress check: Not done yet
  - Update progress.txt
  - Commit to git
  
Iteration 3:
  - Codex Session: "Continue... add rate limiting and full coverage"
  - Output: iteration-3.md
  - Progress check: [CONVERGENCE: COMPLETE]
  - Done! Feature ready.
```

### State Files

Ralph-Codex creates:

```
my-project/
├── .ralph-codex/
│   ├── iterations/
│   │   ├── iteration-1.md          # Codex output
│   │   ├── iteration-1-prompt.txt  # Prompt sent to Codex
│   │   ├── iteration-2.md
│   │   └── iteration-2-prompt.txt
│   ├── progress.txt                # Current progress summary
│   └── state.json                  # Loop state (iteration #, status)
└── prd.json                        # Your requirements
```

All tracked in git for full history.

---

## Integration with Codex

### Running a Session

Ralph-Codex will show you:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Codex Prompt for Iteration 1:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
You are implementing a feature based on this PRD...
[requirements]
[previous progress]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Option A: Manual (Prototyping)**

Copy the prompt into your Codex CLI:

```bash
codex

# Paste the prompt, get output
# Save to: .ralph-codex/iterations/iteration-1.md
# Then resume:
./ralph-codex.sh --resume-iteration 1
```

**Option B: Automated (Production)**

Once integrated with OpenClaw's `sessions_spawn`:

```bash
./ralph-codex.sh prd.json 10
# Ralph-Codex spawns Codex sessions automatically
# Loops until convergence
```

---

## Convergence Detection

Ralph-Codex watches for these markers:

- `[CONVERGENCE: COMPLETE]`
- `✓ ALL ITEMS COMPLETE`
- `READY TO MERGE`

When detected, the loop exits and declares success.

---

## Examples

### Example 1: Simple Feature

**prd.json**:
```json
{
  "title": "Dark mode toggle",
  "requirements": [
    "[ ] Add theme toggle button",
    "[ ] Persist preference (localStorage)",
    "[ ] Apply CSS classes",
    "[ ] Test all color combinations"
  ]
}
```

**Expected**: 2-3 iterations for convergence

### Example 2: Complex Feature

**prd.json**:
```json
{
  "title": "Payment processing",
  "requirements": [
    "[ ] Stripe integration",
    "[ ] Card validation",
    "[ ] Transaction logging",
    "[ ] Webhook handling",
    "[ ] Error recovery",
    "[ ] 95%+ test coverage",
    "[ ] Documentation"
  ]
}
```

**Expected**: 5-8 iterations for convergence

---

## Tips & Tricks

### Use Checkboxes for Progress Tracking

Keep your PRD requirements as checkboxes:

```
[ ] Not started
[x] In progress or done
```

Ralph-Codex scans these to understand progress.

### Accumulate Context Wisely

Ralph-Codex keeps ~50 lines of previous output for context. For large features, periodically summarize:

```
## Summary so far:
- ✓ API endpoints implemented
- ✓ Database migrations
- ⏳ Tests (currently at 65% coverage)
- ⏳ Documentation
```

### Use with Git Branches

Each iteration is a commit. You can:

```bash
# See progression
git log --oneline .ralph-codex/

# Revert to earlier iteration if needed
git revert <commit-hash>

# Cherry-pick specific iterations
git cherry-pick <commit-hash>
```

### Combine with Just

Add to your justfile:

```justfile
@ralph FILE MAX_ITERATIONS='10':
    ./skills/ralph-codex/ralph-codex.sh {{FILE}} {{MAX_ITERATIONS}}

@ralph-auth:
    just ralph examples/prd-auth.json 8
```

---

## Integration with OpenClaw (Production)

When integrating with OpenClaw's `sessions_spawn`:

```bash
# ralph-codex.sh (enhanced version)
codex_session=$(spawn_codex_session iteration_prompt)
wait_for_session "$codex_session"
output=$(get_session_output "$codex_session")
```

This is the roadmap for full automation.

---

## Troubleshooting

### "PRD file not found"

Make sure the file exists:

```bash
ls -la prd.json
./ralph-codex.sh prd.json
```

### "Not a git repository"

Ralph-Codex will init git for you, or:

```bash
git init
./ralph-codex.sh prd.json
```

### "Codex session hanging"

If a Codex session doesn't finish:

1. Kill the session
2. Save any progress to `.ralph-codex/iterations/iteration-N.md`
3. Run `./ralph-codex.sh --resume-iteration N`

---

## Architecture Notes

### Why CLI-based (not API)?

- ✅ Fresh process each iteration (clean state)
- ✅ No connection management
- ✅ Mirrors OpenClaw sub-agent pattern
- ✅ Easy to debug (files on disk)
- ✅ Works with any Codex-compatible tool

### Why State Files (not just memory)?

- ✅ Full history in git
- ✅ Audit trail of how solution evolved
- ✅ Can resume/retry specific iterations
- ✅ Inspection between iterations

### Why Convergence Detection?

- ✅ Stops infinite loops
- ✅ Knows when feature is ready
- ✅ Can integrate with CI/CD

---

## Alternative Engines: Cursor vs Codex

Ralph-Codex currently uses Codex CLI, but **Cursor** is worth exploring as an alternative:

| Aspect | Codex CLI | Cursor |
|--------|-----------|--------|
| Interface | Terminal/CLI | IDE (VS Code) |
| Autonomy | Single-pass | Agent-based |
| Codebase understanding | Manual context | Built-in |
| Interactive | ❌ No | ✅ Yes |
| Automation-friendly | ✅ Yes | ⚠️ Depends on CLI/API |

**Recommendation**: Keep Codex CLI for ralph-codex loops (automation), use Cursor for interactive development.

**Full analysis**: See `../../docs/cursor-ai-workflow-integration.md` for detailed comparison, integration patterns, and roadmap.

---

## References

- **Ralph** (Ryan Carson): https://github.com/snarktank/ralph
- **Ralph Article**: https://x.com/ryancarson/status/2008548371712135632
- **Geoffrey Huntley**: https://ghuntley.com/ralph/
- **Codex**: https://openai.com/research/codex
- **Cursor**: https://cursor.com
- **Workflow Integration Guide**: `../../docs/cursor-ai-workflow-integration.md`

---

**Status**: Prototype (manual Codex invocation)  
**Next**: Automated integration with OpenClaw's sessions_spawn  
**Cursor Integration**: In progress (see docs/cursor-ai-workflow-integration.md)  
**Last Updated**: 2026-03-17
