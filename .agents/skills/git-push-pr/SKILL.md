---
name: git-push-pr
description: Automate git workflow (stage, commit, push, create/update pull request). Use when you need to commit changes and open or update a PR in one go. Handles: staging files with optional filtering, writing commit messages, pushing with fallback (upstream setup), creating new PRs with gh, updating existing PRs.
---

# Git Push PR Workflow

Automate the full git workflow: stage files, commit, push, and create or update a pull request.

## Workflow Steps

Follow these steps in order:

### 1. Understand Changes

- Run `git status` and `git diff` (both staged and unstaged)
- Summarize the changes to yourself before proceeding

### 2. Stage Files

- **If the user specified files:** Stage only those files with `git add <files>`
- **Otherwise:** Stage all modified and new files with `git add -A`
- **Security:** Never stage files that look like secrets (`.env`, credentials, tokens, etc.). Warn the user if such files are present

### 3. Create Commit

- **If user provided a commit message:** Use it as-is
- **Otherwise:** Write a concise, descriptive commit message based on the staged changes
  - Focus on the "why" not the "what"
  - Use conventional commit style if the repo already does (`feat:`, `fix:`, `docs:`, etc.)
- Execute: `git commit -m "<message>"`

### 4. Push to Remote

- Run: `git push origin HEAD`
- **If push fails due to upstream not set:** `git push -u origin HEAD`
- **If push fails due to network error:** Retry up to 3 times with 2-second waits between attempts
- **If push fails for other reasons:** Report the error to the user

### 5. Check for Existing PR

- Run: `gh pr view --json number,title,body 2>/dev/null`
- If the command succeeds, a PR already exists → go to **Update PR** step
- If the command fails (exit code 1), no PR exists → go to **Create PR** step

### 6. Create PR (if new)

- Run: `gh pr create --fill` to auto-fill from recent commits
- Update the PR body with a proper description using `gh pr edit --body "..."`
- PR description should include:
  - **## Summary** — Brief overview of changes
  - **## Changes** — Bulleted list of what was done
  - **## Testing** — How to verify the changes (if applicable)

### 7. Update PR (if exists)

- Use `gh pr edit --title "..."` and `gh pr edit --body "..."` to update
- Preserve existing content (e.g., linked issues) unless explicitly changing
- Update the Summary and Changes sections to reflect the latest commits
- Add/revise Testing section if the approach has changed

## Edge Cases

- **Detached HEAD:** Verify the user is on a real branch before pushing
- **Force push required:** Ask the user before force-pushing; don't do it automatically
- **Merge conflicts:** If upstream is ahead, suggest `git pull --rebase` before retrying
- **PR already merged:** If the PR is merged but the branch still has commits, create a new PR for the new changes

## Error Handling

Report all errors to the user with context:
- Git errors (auth, network, etc.)
- GitHub CLI errors (API rate limits, permissions)
- Invalid commit messages or PR descriptions

Don't retry automatically without asking, except for transient network errors (up to 3 attempts).
