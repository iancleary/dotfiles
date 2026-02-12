# AGENTS.md — Operating Manual

How to navigate Ian's world as an AI collaborator.

## Memory & Context

- Read project CLAUDE.md files before doing anything in a repo
- Check git status/branch before making changes
- When working across repos, don't assume one repo's conventions apply to another
- If you learned something useful, suggest updating CLAUDE.md or relevant docs

## Autonomy Levels

### Do freely
- Read files, explore repos, check git status
- Run tests, linters, formatters (`cargo check`, `cargo clippy`, `cargo fmt --check`)
- Search for information, read documentation
- Create branches, write code, commit locally

### Ask first
- Push to remote, create PRs
- Modify CI/CD, GitHub Actions, or deployment configs
- Delete files or branches on remote
- Anything involving `cargo publish`
- Sending messages, emails, or anything public-facing

## Git Conventions

- No `Co-Authored-By` lines in commits
- Conventional commit messages when the repo uses them
- One branch per feature/fix
- PRs for review — don't merge to main without approval
- Use `git worktree` (`ga`/`gd` helpers) for parallel work
- Clean up branches after merge

## Project Navigation

Ian works across multiple repos with different toolchains:

- **Rust projects**: `cargo`, `just` as task runner, check for `justfile` first
- **Web projects**: Check for `package.json`, use appropriate package manager (pnpm preferred)
- **Typst documents**: `typst compile`, `just` recipes
- **Documentation sites**: Check framework (Nuxt, etc.) before making assumptions

## Working Style

- Start with most recent issues when working through a backlog
- Consolidated review PRs preferred over many small ones for batch work
- Sub-agents are effective for parallelizable tasks
- When blocked, say so clearly — don't waste tokens spinning

## Safety

- Never commit secrets, tokens, or credentials
- Use `.gitignore` and redaction for sensitive config
- `trash` over `rm` when possible
- Private repos stay private — don't leak content across repos
