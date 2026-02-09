# OpenClaw Improvement Suggestions

Actionable suggestions for better leveraging OpenClaw skills, agents, rules, and workspace files across Ian's development setup.

---

## 1. Sync OpenClaw Workspace Files via Dotfiles

The `sync-dotfiles.sh` script already syncs `.claude/` and `.codex/` files but ignores OpenClaw workspace files entirely. Add them to `COMMON_DOTFILES`:

```bash
# In sync-dotfiles.sh, add to COMMON_DOTFILES:
COMMON_DOTFILES+=(
    # ... existing entries ...
    ".openclaw/workspace/SOUL.md"
    ".openclaw/workspace/AGENTS.md"
    ".openclaw/workspace/USER.md"
    ".openclaw/workspace/IDENTITY.md"
    ".openclaw/workspace/TOOLS.md"
    ".openclaw/workspace/HEARTBEAT.md"
    ".openclaw/workspace/MEMORY.md"
)
```

Then add template files to the repo. Example `SOUL.md` template:

```markdown
# SOUL.md

You are Ian's personal AI assistant. You help with:
- Software development (Rust, TypeScript, Nix)
- RF engineering projects
- Managing development workflows across multiple repos
- Dotfiles and system configuration

## Personality
- Direct and practical — skip fluff
- Proactive about suggesting improvements
- Comfortable with CLI-first workflows
```

Example `USER.md` template:

```markdown
# USER.md

## About Ian
- Software/RF engineer
- Primary languages: Rust, TypeScript
- Uses Nix for system config, Tailscale for networking
- Multi-project workflow in ~/Development/
- Prefers CLI tools, eza, ripgrep, fd, just, cargo

## Devices
- Mac Mini (primary dev machine)
- Syncs dotfiles across machines

## Communication
- Signal (primary), iMessage, webchat
```

**Why:** If you ever reset OpenClaw or set up a new machine, `./sync-dotfiles.sh push` restores your agent's personality and context instantly.

---

## 2. Custom OpenClaw Skills

Create skills in `~/.openclaw/workspace/skills/` for recurring tasks.

### 2a. RF Designer Launcher

```
~/.openclaw/workspace/skills/rf-designer/SKILL.md
```

```markdown
# RF Designer Launcher

Start/stop RF Designer and serve it over Tailscale.

## Commands

### Start
1. Launch the RF Designer application
2. Verify it's running: `pgrep -f "RF Designer" || open -a "RF Designer"`
3. If serving over Tailscale, ensure `tailscale serve` is configured:
   ```bash
   tailscale serve --bg https+insecure://localhost:8080
   ```

### Stop
1. `tailscale serve off`
2. `pkill -f "RF Designer"` or `osascript -e 'quit app "RF Designer"'`

### Status
- `tailscale serve status`
- `pgrep -f "RF Designer" && echo "Running" || echo "Stopped"`
```

### 2b. Dotfiles Sync

```
~/.openclaw/workspace/skills/dotfiles-sync/SKILL.md
```

```markdown
# Dotfiles Sync

Manage dotfiles from OpenClaw without leaving the chat.

## Usage

### Pull (backup home → repo)
```bash
cd ~/Development/dotfiles && ./sync-dotfiles.sh pull
```

### Push (restore repo → home)
```bash
cd ~/Development/dotfiles && ./sync-dotfiles.sh push
```

### Status (show diffs)
```bash
cd ~/Development/dotfiles && ./sync-dotfiles.sh status
```

### After changes
```bash
cd ~/Development/dotfiles && git add -A && git commit -m "sync: update dotfiles" && git push
```

## Notes
- Always `pull` before editing repo files to avoid overwriting newer home versions
- The script handles platform detection (macOS vs Linux vs Windows)
```

### 2c. Development Project Navigator

```
~/.openclaw/workspace/skills/dev-navigator/SKILL.md
```

```markdown
# Development Project Navigator

List and manage projects in ~/Development/.

## List all projects
```bash
ls -1d ~/Development/*/ | sed 's|.*/||' | sort
```

## List with git status (dirty/clean)
```bash
for d in ~/Development/*/; do
  if [ -d "$d/.git" ]; then
    status=$(cd "$d" && git status --porcelain | head -1)
    branch=$(cd "$d" && git branch --show-current)
    if [ -z "$status" ]; then
      echo "✅ $(basename $d) ($branch)"
    else
      echo "🔴 $(basename $d) ($branch) — uncommitted changes"
    fi
  fi
done
```

## List worktrees (from agents-git-trees.sh convention)
Worktrees follow the pattern `branch--repo` in ~/Development/:
```bash
ls -1d ~/Development/*--*/ 2>/dev/null | sed 's|.*/||'
```

## Open project in editor
```bash
cd ~/Development/<project> && nvim .
```
```

---

## 3. New Claude Code Skills

Complement the existing `interview` and `git-push-pr` skills:

### 3a. Code Review Skill

```
~/.claude/skills/code-review/SKILL.md
```

```markdown
# Code Review Skill

Review code changes for quality, bugs, and style.

## Trigger
User asks for a code review, or says "review this", "review PR", etc.

## Steps
1. Get the diff: `git diff main...HEAD` (or the specified range)
2. Review for:
   - **Bugs**: Logic errors, edge cases, off-by-ones
   - **Style**: Consistency with project conventions
   - **Performance**: Unnecessary allocations, O(n²) where O(n) is possible
   - **Security**: Input validation, SQL injection, path traversal
   - **Tests**: Are new code paths tested?
3. Format feedback as:
   - 🐛 Bug: ...
   - 💡 Suggestion: ...
   - ⚠️ Warning: ...
   - ✅ Looks good: ...
4. Summarize with an overall assessment

## For Rust specifically
- Check for unwrap() in non-test code
- Verify error handling uses proper Result/? patterns
- Look for unnecessary clones
- Check lifetime annotations make sense
```

### 3b. Test Writer Skill

```
~/.claude/skills/test-writer/SKILL.md
```

```markdown
# Test Writer Skill

Generate tests for existing code.

## Trigger
User asks to "write tests", "add tests", "test this", etc.

## Steps
1. Read the target file/function
2. Identify the testing framework in use:
   - Rust: built-in `#[cfg(test)]` + `#[test]`
   - TypeScript: check for vitest/jest/playwright in package.json
3. Generate tests covering:
   - Happy path
   - Edge cases (empty input, zero, None/null, boundary values)
   - Error cases
4. Place tests in the conventional location:
   - Rust: `#[cfg(test)] mod tests {}` at bottom of file, or `tests/` dir for integration tests
   - TypeScript: `__tests__/` or `*.test.ts` adjacent to source
5. Run the tests to verify they pass

## Style
- Test names should describe the behavior: `test_empty_input_returns_none`
- One assertion per test when practical
- Use descriptive assertion messages
```

### 3c. Cargo/Just Runner Skill

```
~/.claude/skills/cargo-just/SKILL.md
```

```markdown
# Cargo & Just Runner Skill

Smart project task runner for Rust projects using cargo and just.

## Trigger
User asks to build, test, lint, format, or run a Rust project.

## Steps
1. Check if a `justfile` exists in the project root
   - If yes, prefer `just <task>` over raw cargo commands
   - List available tasks: `just --list`
2. Common mappings:
   - Build: `just build` or `cargo build`
   - Test: `just test` or `cargo test`
   - Lint: `just lint` or `cargo clippy -- -D warnings`
   - Format: `just fmt` or `cargo fmt`
   - Run: `just run` or `cargo run`
   - Check: `cargo check` (fast compile check)
3. For workspace projects, specify the package: `cargo test -p <package>`
4. Always show the command before running it
```

---

## 4. Codex Rules Improvements

Add these to `.codex/rules/user-policy.rules`:

```python
# --- Cargo (Rust) ---
# Read-only cargo commands
prefix_rule(pattern=["cargo", "check"], decision="allow")
prefix_rule(pattern=["cargo", "clippy"], decision="allow")
prefix_rule(pattern=["cargo", "fmt", "--check"], decision="allow")
prefix_rule(pattern=["cargo", "doc"], decision="allow")
prefix_rule(pattern=["cargo", "tree"], decision="allow")
prefix_rule(pattern=["cargo", "metadata"], decision="allow")

# Mutating cargo commands (build artifacts, modify lock file)
prefix_rule(pattern=["cargo", "build"], decision="prompt")
prefix_rule(pattern=["cargo", "test"], decision="prompt")
prefix_rule(pattern=["cargo", "run"], decision="prompt")
prefix_rule(pattern=["cargo", "fmt"], decision="prompt")
prefix_rule(pattern=["cargo", "add"], decision="prompt")
prefix_rule(pattern=["cargo", "remove"], decision="prompt")
prefix_rule(pattern=["cargo", "install"], decision="prompt")
prefix_rule(pattern=["cargo", "publish"], decision="forbidden", justification="Publishing crates requires explicit human action.")

# --- Just (task runner) ---
prefix_rule(pattern=["just", "--list"], decision="allow")
prefix_rule(pattern=["just", "--summary"], decision="allow")
prefix_rule(pattern=["just"], decision="prompt")

# --- Docker Compose ---
prefix_rule(pattern=["docker", "compose", "ps"], decision="allow")
prefix_rule(pattern=["docker", "compose", "logs"], decision="allow")
prefix_rule(pattern=["docker", "compose", "config"], decision="allow")
prefix_rule(pattern=["docker", "compose", "up"], decision="prompt")
prefix_rule(pattern=["docker", "compose", "down"], decision="prompt")
prefix_rule(pattern=["docker", "compose", "build"], decision="prompt")
prefix_rule(pattern=["docker", "compose", "exec"], decision="prompt")
prefix_rule(pattern=["docker", "compose", "rm"], decision="prompt")

# --- Tailscale ---
prefix_rule(pattern=["tailscale", "status"], decision="allow")
prefix_rule(pattern=["tailscale", "ip"], decision="allow")
prefix_rule(pattern=["tailscale", "ping"], decision="allow")
prefix_rule(pattern=["tailscale", "whois"], decision="allow")
prefix_rule(pattern=["tailscale", "serve", "status"], decision="allow")
prefix_rule(pattern=["tailscale", "serve"], decision="prompt")
prefix_rule(pattern=["tailscale", "funnel"], decision="prompt")
prefix_rule(pattern=["tailscale", "up"], decision="prompt")
prefix_rule(pattern=["tailscale", "down"], decision="prompt")

# --- Eza / fd / ripgrep (safe read-only tools) ---
prefix_rule(pattern=["eza"], decision="allow")
prefix_rule(pattern=["fd"], decision="allow")
prefix_rule(pattern=["bat"], decision="allow")
prefix_rule(pattern=["dust"], decision="allow")
prefix_rule(pattern=["tokei"], decision="allow")
```

---

## 5. OpenClaw AGENTS.md Customization

Add project-specific context to `~/.openclaw/workspace/AGENTS.md`:

```markdown
## Development Preferences

### Rust
- Use `thiserror` for library errors, `anyhow` for application errors
- Prefer `&str` over `String` in function signatures when possible
- Run `cargo clippy -- -D warnings` before committing
- Use `#[must_use]` on functions that return important values
- Prefer `impl Trait` over `dyn Trait` when the concrete type is known at compile time

### TypeScript
- Prefer `const` over `let`, never `var`
- Use Biome for formatting and linting (not ESLint/Prettier)
- Prefer `pnpm` as package manager

### RF Engineering Context
- Ian works on RF circuit design and simulation
- Common tools: RF Designer, QUCS, KiCad
- When discussing dB, dBm, S-parameters, impedance matching — use proper RF terminology
- Smith chart references are welcome

### Multi-Project Setup
- All projects live in `~/Development/`
- Git worktrees follow the convention: `~/Development/<branch>--<repo>/`
  - Created with `ga <branch>` (from agents-git-trees.sh)
  - Removed with `gd` (interactive confirmation)
- When asked about "my projects", scan `~/Development/` for git repos
- Worktree directories (containing `--`) are temporary; base directories are the main repos

### Git Conventions
- Commit messages: conventional commits (feat:, fix:, docs:, chore:, refactor:, test:)
- Always create feature branches, never commit to main directly
- Use `gh pr create` for pull requests (GitHub CLI)
- Prefer rebase over merge for feature branches
```

---

## 6. Multi-Agent Setup

Consider running two OpenClaw agents for separation of concerns:

### Agent 1: Personal Assistant (main)
- **Channel:** Signal, iMessage
- **Purpose:** Calendar, reminders, emails, weather, general questions
- **Model:** A fast model (Claude Sonnet) for quick responses
- **Heartbeat:** Frequent (every 30 min) — checks inbox, calendar, notifications

### Agent 2: Coding Agent
- **Channel:** Webchat (localhost), or a dedicated Signal group
- **Purpose:** Code review, project management, builds, deployments
- **Model:** Claude Opus for deep reasoning on code
- **Heartbeat:** Less frequent (every 2-4 hours) — checks git status, CI/CD, build health

### When this makes sense
- **Context separation:** The coding agent's MEMORY.md stays focused on code; the personal agent doesn't get polluted with technical context
- **Model optimization:** Use cheaper/faster models for casual chat, powerful models for code
- **Concurrent work:** Personal agent handles a message while coding agent runs a long build

### How to set up
```bash
# Agent 1 runs on default port
openclaw gateway start

# Agent 2 runs on a different port with its own workspace
# (Exact config depends on OpenClaw's multi-instance support)
# Check: openclaw gateway --help for port/workspace flags
```

### When NOT to bother
- If you're only messaging a few times a day, one agent is fine
- If context bleed between personal/code isn't a problem for you
- Added complexity of managing two agents may not be worth it until you're a heavy user

---

## 7. Heartbeat Automation

Update `~/.openclaw/workspace/HEARTBEAT.md` with useful periodic checks:

```markdown
# HEARTBEAT.md

## Checks (rotate through these)

### Git Repo Health (check 2x daily)
Run this across all repos in ~/Development/:
```bash
for d in ~/Development/*/; do
  [ -d "$d/.git" ] || continue
  name=$(basename "$d")
  branch=$(cd "$d" && git branch --show-current 2>/dev/null)
  dirty=$(cd "$d" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  behind=$(cd "$d" && git rev-list --count HEAD..@{u} 2>/dev/null || echo "?")
  ahead=$(cd "$d" && git rev-list --count @{u}..HEAD 2>/dev/null || echo "?")
  [ "$dirty" != "0" ] && echo "🔴 $name ($branch): $dirty uncommitted files"
  [ "$behind" != "0" ] && [ "$behind" != "?" ] && echo "⬇️  $name: $behind commits behind remote"
  [ "$ahead" != "0" ] && [ "$ahead" != "?" ] && echo "⬆️  $name: $ahead commits ahead (unpushed)"
done
```
Only notify if something needs attention.

### Tailscale Connectivity (check 2x daily)
```bash
tailscale status --json | jq -r '.Peer[] | select(.Online==false) | .HostName' 2>/dev/null
```
Notify if a usually-online device is offline.

### Stale Worktrees (check 1x daily)
```bash
# Find worktrees older than 7 days with no recent commits
for d in ~/Development/*--*/; do
  [ -d "$d/.git" ] || continue
  last_commit=$(cd "$d" && git log -1 --format=%ct 2>/dev/null || echo 0)
  now=$(date +%s)
  age_days=$(( (now - last_commit) / 86400 ))
  [ "$age_days" -gt 7 ] && echo "🧹 $(basename $d): last commit ${age_days}d ago — consider cleanup with gd"
done
```

### Cargo Build Health (check 1x daily, if Rust projects exist)
```bash
for d in ~/Development/*/; do
  [ -f "$d/Cargo.toml" ] || continue
  name=$(basename "$d")
  (cd "$d" && cargo check 2>&1 | tail -1) | grep -q "error" && echo "❌ $name: cargo check has errors"
done
```
Only run this during work hours. Skip if on battery.

## Schedule
- Morning (9 AM): Git health + Tailscale
- Afternoon (2 PM): Stale worktrees + Cargo health
- Evening: HEARTBEAT_OK (quiet time)
- Night (11 PM - 8 AM): HEARTBEAT_OK always
```

---

## Summary

| Suggestion | Effort | Impact |
|---|---|---|
| Sync OpenClaw files in dotfiles | Low | High — portability + backup |
| Custom OpenClaw skills | Medium | High — automate daily tasks |
| New Claude Code skills | Low | Medium — faster code workflows |
| Codex rules for cargo/just/docker/tailscale | Low | Medium — safer CLI usage |
| AGENTS.md customization | Low | High — better agent context |
| Multi-agent setup | High | Medium — only if needed |
| Heartbeat automation | Medium | High — proactive monitoring |

**Recommended priority:** Start with #1 (sync), #4 (codex rules), and #5 (AGENTS.md) — they're low effort, high impact. Then add skills (#2, #3) as you find yourself repeating tasks. Heartbeats (#7) are great once the foundation is set. Multi-agent (#6) can wait until you're hitting limits with one agent.
