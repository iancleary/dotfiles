# Cursor + Ralph-Codex + Linear: Modern AI Dev Workflow

**Research Date**: 2026-03-17  
**Status**: Investigation complete, integration recommendations ready

---

## What is Cursor?

**Cursor** is an AI-powered IDE (VS Code fork) with:
- ✅ Autonomous agent capabilities ("runs in parallel, builds/tests/demos")
- ✅ Autonomy slider (tab completion → full autonomous)
- ✅ Multi-model support (OpenAI, Anthropic, Gemini, xAI, custom)
- ✅ Codebase understanding (learns your repo, no matter scale)
- ✅ Enterprise adoption (40K+ NVIDIA engineers, Fortune 500 companies)

**Key Quote** (Andrej Karpathy, Eureka Labs CEO):
> "The best LLM applications have an autonomy slider: you control how much independence to give the AI. In Cursor, you can do Tab completion, Cmd+K for targeted edits, or you can let it rip with the full autonomy agentic version."

---

## Cursor vs Your Current Tools

| Aspect | Codex CLI | Claude Code | Cursor |
|--------|-----------|-------------|--------|
| **Interface** | Terminal/CLI | IDE plugin/terminal | Full IDE (VS Code) |
| **Autonomy** | Stateless (CLI) | Session-based | Agent-based |
| **Codebase Context** | Manual prompts | Growing context | Built-in codebase understanding |
| **Multi-model** | OpenAI only | Anthropic | OpenAI, Anthropic, Gemini, etc. |
| **Interactive** | ❌ Not IDE-native | ⚠️ Plugin mode | ✅ Native IDE experience |
| **Best For** | Scripted automation | Sub-agent loops | Interactive development |
| **Price** | Pay-per-use (API) | Subscription | Subscription |

---

## Where Cursor Fits Your Workflow

### Current Flow (Ralph-Codex)

```
PRD → Codex CLI session #1 → Code → Progress
  ↓
Not converged?
  ↓
Codex CLI session #2 → Code → Progress
  ↓
Repeat until complete
```

**Problem**: Manual, CLI-only, no IDE experience

### Enhanced Flow (Cursor + Ralph-Codex)

```
Linear Issue (with PRD) 
  ↓
Cursor Agent (autonomous mode)
  ↓
Implements feature, runs tests, commits code
  ↓
If converged → Done
If not → Ralph-Codex loop with Cursor as engine
```

**Benefit**: IDE experience, better codebase understanding, autonomous agents

---

## Three Integration Patterns

### Pattern 1: Cursor as Interactive Dev (Today)

**Use case**: Interactive feature development

```bash
# You have a Linear issue:
# RFX-50: Add dark mode toggle

# Open Cursor IDE
# @codebase "implement dark mode based on RFX-50"
# Cursor uses agent mode to:
# - Understand existing design system
# - Implement toggle + persistence
# - Run tests
# - Commit code
```

**Pros**:
- ✅ Full IDE experience
- ✅ Easy refactoring (AI-assisted)
- ✅ Built-in testing
- ✅ Interactive feedback loop

**Cons**:
- ⚠️ Still requires user to initiate
- ⚠️ Not fully autonomous loop

---

### Pattern 2: Cursor as Ralph Engine (Next)

**Use case**: Autonomous feature loops

```bash
# ralph-codex.sh enhanced with Cursor agent mode

spawn_codex_iteration() {
  local prompt=$1
  local iteration=$2
  
  # Instead of: codex < prompt.txt
  # Use:
  cursor agent \
    --task "$prompt" \
    --model claude-opus \
    --autonomy full \
    --output ".ralph-codex/iterations/iteration-${iteration}.md"
}
```

**Pros**:
- ✅ Fully autonomous loop (like Ralph, but with Cursor's agents)
- ✅ Better codebase understanding
- ✅ Multi-model capability
- ✅ CI/CD friendly

**Cons**:
- ⚠️ Requires Cursor agent CLI (may not exist yet)
- ⚠️ Different from current Codex setup

---

### Pattern 3: Linear ↔ Cursor ↔ Ralph Pipeline (Ideal)

**Use case**: Full CI/CD integration

```
Linear Issue Created (RFX-50)
  ↓
GitHub Action triggers
  ↓
Cursor agent spawns (autonomous mode)
  ↓
Reads issue description as PRD
  ↓
Ralph-Codex loop (Cursor as engine)
  ↓
Iterates until:
  - Tests pass (90%+ coverage)
  - Converged signal in commit messages
  ↓
Auto-create PR with Cursor-generated code
  ↓
Human review + merge
  ↓
Linear issue auto-closes
```

**Pros**:
- ✅ Fully autonomous (PR generation)
- ✅ Linear integration
- ✅ No manual steps
- ✅ Audit trail (commits + issue history)

**Cons**:
- ⚠️ Most complex to implement
- ⚠️ Requires Cursor agent API
- ⚠️ Need error handling for failures

---

## Key Differences from Ralph (Amp/Claude Code)

### Ralph (Original)
- PRD → Amp/Claude Code → Script-based loop → Converge
- Designed for: Autonomous script-based autonomy

### Cursor-Enhanced Ralph
- PRD → Cursor agent → IDE-based autonomy → Converge
- Designed for: Interactive + autonomous mixed workflow

### Why Cursor's "Autonomy Slider" Matters

Andrej Karpathy's insight:
- **Tab completion** = human-directed, incremental
- **Cmd+K edits** = targeted AI assistance
- **Full autonomy** = let AI "rip" and handle it end-to-end

This matches your need:
- ✅ Interactive: Click button, AI generates code (you review)
- ✅ Batch: Set PRD, AI loops autonomously

---

## Cursor Codebase Understanding

**How Cursor learns your repo**:
1. Reads `package.json`, `Cargo.toml`, etc. (architecture detection)
2. Scans relevant files (not whole codebase)
3. Builds mental model (dependencies, patterns, style)
4. Uses this context in agent mode (better suggestions)

**For rfsystems**:
- Cursor would understand Axum + SQLx + HTML templates
- Better at suggesting changes that fit your architecture
- Fewer hallucinations about non-existent modules

---

## Workflow Integration: Linear → Cursor → Ralph

### Hypothetical rfsystems Example

1. **Create Linear Issue** (RFX-51):
   ```
   Title: Implement dark mode toggle
   Description:
   - Add theme toggle button
   - Persist to localStorage
   - Apply CSS variables
   - 90%+ test coverage
   - Ready: [CONVERGENCE: COMPLETE]
   ```

2. **Option A: Interactive (Cursor GUI)**
   ```bash
   # Open Cursor IDE
   # Paste RFX-51 description
   # @codebase "implement this issue"
   # Review suggestions → accept → commit
   ```

3. **Option B: Autonomous (Ralph + Cursor)**
   ```bash
   # Export RFX-51 as prd.json
   # Run: just ralph prd.json 10 --engine cursor
   # Cursor agent loops until [CONVERGENCE: COMPLETE]
   # Auto-creates PR when done
   ```

---

## Implementation Roadmap

### Now (Q2 2026)
- ✅ Test ralph-codex with Codex CLI
- ✅ Understand convergence patterns

### Next (Q2 2026, after ralph-codex proves out)
- Option A: Add Cursor as alternative engine to ralph-codex
- Option B: Explore Cursor agent CLI/API
- Option C: Hybrid (use Cursor for interactive, keep Codex for batch)

### Future (Q3+ 2026, if all works)
- Linear ↔ Cursor ↔ Ralph full pipeline
- GitHub Actions trigger autonomous PRs
- Minimal human intervention

---

## Recommendations for Your Setup

### Use Cursor If:
- ✅ You want IDE-native development (not CLI-only)
- ✅ You need better codebase understanding
- ✅ You like interactive + autonomous hybrid
- ✅ You want multi-model flexibility
- ✅ You're willing to pay subscription ($20-200/month)

### Stick with Codex/Claude Code If:
- ✅ CLI automation is priority (Ralph-style loops)
- ✅ You want to avoid learning new IDE
- ✅ API cost predictability matters
- ✅ You don't need GUI interaction

### Hybrid Approach (Recommended):
- **Cursor**: Interactive feature development (you drive)
- **Ralph-Codex**: Autonomous batch work (scripted PRDs)
- **Linear**: Issue tracking + convergence signals
- **Codex CLI**: Fallback for automation when Cursor isn't available

---

## Questions for Testing

Once you've validated ralph-codex locally:

1. **Does Cursor have agent CLI mode?** (Essential for ralph-codex engine swap)
2. **Can Cursor integrate with Linear?** (Issue → PRD pipeline)
3. **What's Cursor's error recovery?** (If agent fails mid-iteration)
4. **How good is Cursor's codebase understanding for rfsystems?** (Test with small feature)
5. **Cost comparison**: Cursor subscription vs API usage (Codex)?

---

## References

- **Cursor**: https://cursor.com
- **Cursor Docs**: https://docs.cursor.com
- **Andrej Karpathy on Autonomy Sliders**: https://twitter.com/karpathy (quotes from interviews)
- **Ralph**: https://github.com/snarktank/ralph

---

## Next Steps

1. **Finish ralph-codex validation** (Phase 1 local testing)
2. **Try Cursor for interactive development** (feel for the workflow)
3. **Research Cursor agent API** (can it be scripted like Codex?)
4. **Decide**: Cursor as primary, or Cursor + Ralph hybrid?
5. **Prototype integration** if Cursor agent CLI exists

---

**Status**: Research complete, ready for your feedback  
**Last Updated**: 2026-03-17

---

## TL;DR

**Cursor** is a stronger IDE than Codex/Claude Code for interactive work, with autonomous agents as a bonus. For your ralph-codex loop, it's an alternative engine if Cursor agent CLI exists. **Worth exploring** after ralph-codex proves out, but don't let it block current prototype testing.

**Decision**: Keep Codex for automation, test Cursor for interactive development in parallel. They complement each other.
