# Ralph: Autonomous AI Agent Loop

Ralph is an autonomous AI agent loop that runs AI coding tools repeatedly until all PRD (Product Requirements Document) items are complete. Each iteration is a fresh instance with clean context, and memory persists via git history, progress.txt, and prd.json.

**Project**: https://github.com/snarktank/ralph  
**Based on**: [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/)  
**Author**: Ryan Carson  

---

## Why Ralph?

Ralph automates the iterative development process:

1. You write a PRD (Product Requirements Document)
2. Ralph runs an AI coding tool (Amp or Claude Code) to implement it
3. The tool finishes and generates progress.txt
4. Ralph detects incomplete items and runs again with fresh context
5. Process repeats until all PRD items are complete

This avoids:
- **Context pollution** — each iteration gets a clean slate
- **Manual handoffs** — Ralph orchestrates the flow automatically
- **Lost context** — memory persists via git history and structured files

---

## Key Features

- **Autonomous loops**: Runs AI tools repeatedly without manual intervention
- **Fresh context**: Each iteration starts with clean slate, avoiding token wastage
- **Persistent memory**: Git history, progress.txt, prd.json track state across runs
- **Tool flexibility**: Works with Amp CLI or Claude Code
- **Built-in skills**:
  - `/prd` — Generate detailed Product Requirements Documents
  - `/ralph` — Convert PRDs to prd.json format for automation
- **Automatic context handoff**: When context window fills, Ralph hands off to next iteration
- **Structured requirements**: Everything driven by PRDs (removes ambiguity)

---

## Installation

### Prerequisites

Choose one AI coding tool:

- **Amp CLI** (default) — [ampcode.com](https://ampcode.com)
- **Claude Code** — `npm install -g @anthropic-cli/claude-code`

Also install:
- **jq** — `brew install jq` (macOS) or `apt-get install jq` (Linux)
- **Git** — version control for storing state

### Setup

1. **Copy Ralph into your project**:
   ```bash
   mkdir -p scripts/ralph
   cp /path/to/ralph/ralph.sh scripts/ralph/
   chmod +x scripts/ralph/ralph.sh
   ```

2. **Copy the prompt template** (choose one):
   ```bash
   # For Amp
   cp /path/to/ralph/prompt.md scripts/ralph/prompt.md
   
   # For Claude Code
   cp /path/to/ralph/CLAUDE.md scripts/ralph/CLAUDE.md
   ```

3. **Copy Ralph skills** to your AI tool config:
   ```bash
   # For Amp
   cp -r skills/prd ~/.config/amp/skills/
   cp -r skills/ralph ~/.config/amp/skills/
   
   # For Claude Code
   cp -r skills/prd ~/.claude/skills/
   cp -r skills/ralph ~/.claude/skills/
   ```

4. **For Claude Code, add the marketplace** (optional):
   ```bash
   /plugin marketplace add snarktank/ralph
   /plugin install ralph-skills@ralph-marketplace
   ```

---

## Usage

### Creating a PRD

Ask your AI tool to create a requirements document:

```
"create a prd for a user authentication system"
"write prd for a real-time dashboard"
"plan this feature with a prd"
```

The `/prd` skill will generate a structured Product Requirements Document.

### Converting to Ralph Format

Convert your PRD to prd.json (the format Ralph uses):

```
"convert this prd to ralph format"
"turn this into prd.json"
"create prd.json for this feature"
```

The `/ralph` skill transforms the PRD into structured JSON.

### Running Ralph

Once you have prd.json and ralph.sh in place:

```bash
cd /path/to/project
scripts/ralph/ralph.sh
```

Ralph will:
1. Run your AI tool with the PRD
2. Implement all items
3. Generate progress.txt showing what's done
4. Detect incomplete items
5. If needed, run again with fresh context
6. Repeat until PRD is complete

### Advanced: Auto-Context Handoff

For large features that exceed a single context window, enable automatic handoff in Amp:

**~/.config/amp/settings.json**:
```json
{
  "amp.experimental.autoHandoff": { "context": 90 }
}
```

This allows Ralph to seamlessly continue when context fills up.

---

## File Structure

A Ralph project looks like this:

```
my-project/
├── scripts/ralph/
│   ├── ralph.sh           # Main automation script
│   ├── prompt.md          # AI tool instructions (for Amp)
│   └── CLAUDE.md          # AI tool instructions (for Claude Code)
├── prd.json               # Structured requirements (auto-generated)
├── progress.txt           # Completion status (auto-generated)
├── .gitignore             # (should include progress.txt, .ralph.json)
└── src/
    └── ... (your code)
```

### Suggested .gitignore additions

```
# Ralph workflow
progress.txt
.ralph.json
.ralph.state
```

---

## Integration with Dotfiles

Ralph can be integrated into your development environment:

1. **Create a ralph-init script** that sets up a new project:
   ```bash
   scripts/setup-ralph.sh
   ```

2. **Add to your just task runner**:
   ```justfile
   @ralph:
       scripts/ralph/ralph.sh

   @prd FEATURE:
       echo "Creating PRD for: {{FEATURE}}"
       amp "create a prd for {{FEATURE}}"
   ```

3. **Include ralph.json template** in project scaffolding

4. **Track prd.json in git** for reproducibility across team

---

## Comparison: Ralph vs Traditional Development

| Aspect | Traditional | Ralph |
|--------|-------------|-------|
| **Requirements** | Manual written spec | PRD generated by AI |
| **Implementation** | Manual coding or single AI run | Autonomous looping |
| **Context handling** | Single pass (may exceed window) | Fresh context each iteration |
| **State tracking** | Developer memory + comments | git history + progress.txt |
| **Completeness** | Manual verification | Automated until done |
| **Iteration** | Code review cycle | Embedded in Ralph loop |

---

## Real-World Example

1. **You write a PRD**:
   ```
   ## User Authentication System
   - [ ] Login page with email/password
   - [ ] Session token generation
   - [ ] Password reset flow
   - [ ] Rate limiting (5 attempts/hour)
   - [ ] Test coverage (90%+)
   ```

2. **Run Ralph**:
   ```bash
   scripts/ralph/ralph.sh
   ```

3. **Ralph loops** until all items complete:
   - Iteration 1: Implements login page, session tokens
   - Iteration 2: Adds password reset, rate limiting
   - Iteration 3: Adds test coverage, all items checked

4. **Your code is ready** — all PRD items complete

---

## Tips & Tricks

### Use with TypeScript/Rust Projects

Ralph works great with type-safe languages where compile errors provide clear feedback:

```bash
# Ralph will iterate until your TypeScript compiles
# Each loop fixes type errors automatically
```

### Combine with Criterion Benchmarks

For performance-critical code:

```
PRD item: "Add benchmarks showing <1ms latency"
Ralph loops until criterion results meet goal
```

### Use for Refactoring

Ralph is excellent for large refactoring tasks:

```
"Refactor auth module to use async/await, maintain 100% test coverage"
Ralph ensures both requirements are met before finishing
```

---

## Resources

- **Ralph Repository**: https://github.com/snarktank/ralph
- **Ralph Article**: https://x.com/ryancarson/status/2008548371712135632
- **Geoffrey Huntley's Pattern**: https://ghuntley.com/ralph/
- **Amp**: https://ampcode.com
- **Claude Code**: https://docs.anthropic.com/en/docs/claude-code

---

**Last Updated**: 2026-03-17
