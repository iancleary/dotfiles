---
argument-hint: [commit message or instructions]
description: Git add, commit, push, and create or update a pull request
allowed-tools: Bash, Read, Glob, Grep
---

Automate the full git workflow: stage files, commit, push, and create or update a pull request.

Follow these steps in order:

## 1. Review changes

Run `git status` and `git diff` (both staged and unstaged) to understand what has changed. Summarize the changes for yourself before proceeding.

## 2. Stage files

- If the user specified files, stage only those files with `git add`.
- Otherwise, stage all modified and new files with `git add -A`.
- Never stage files that look like secrets (`.env`, credentials, tokens, etc.). Warn the user if such files are present.

## 3. Commit

- If the user provided a commit message in the arguments, use it: `$ARGUMENTS`
- Otherwise, write a concise, descriptive commit message based on the staged changes. Focus on the "why" not the "what". Use conventional commit style if the repo already does.
- Use `git commit -m "<message>"`.

## 4. Push

- Run `git push origin HEAD`.
- If the push fails due to an upstream not being set, run `git push -u origin HEAD`.
- If the push fails due to network errors, retry up to 3 times with 2-second waits between attempts.

## 5. Create or update the pull request

- Check if a PR already exists for the current branch: `gh pr view --json number,title,body 2>/dev/null`.
- **If no PR exists**: Create one with `gh pr create --fill` to auto-fill from commits, then update the body with a proper description using `gh pr edit`.
- **If a PR already exists**: Update its title and body with `gh pr edit` to reflect the latest changes. Preserve any existing content that is still relevant and append or revise sections as needed.
- The PR description should include:
  - A `## Summary` section with a brief overview of the changes
  - A `## Changes` section with a bulleted list of what was done
