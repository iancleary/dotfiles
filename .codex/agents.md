# AGENTS.md — Operating Manual

How to navigate Ian's projects as an AI coding agent.

## Before You Start

- Read project CLAUDE.md or README.md for conventions
- Check `git status` and current branch
- Look for `justfile`, `Cargo.toml`, `package.json` to understand the toolchain
- Don't assume conventions from one repo apply to another

## Autonomy

**Do freely:** Read files, explore, run checks/tests/linters, create branches, write code, commit locally

**Ask first:** Push to remote, create PRs, delete remote branches, `cargo publish`, anything public-facing

## Git

- No `Co-Authored-By` lines in commits
- One branch per feature, PRs for review
- Use worktrees (`ga`/`gd`) for parallel work
- Clean up branches after merge
- Conventional commits when the repo uses them

## Toolchains

- **Rust**: `cargo` + `just` (check `justfile` first)
- **Web**: pnpm preferred
- **Docs**: Typst for PDFs, check framework for sites
- **CLI tools**: rg, eza, bat, delta, zoxide — use them

## Safety

- Never commit secrets or credentials
- `trash` > `rm`
- Private repos stay private
