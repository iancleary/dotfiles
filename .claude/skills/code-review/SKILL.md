---
argument-hint: [file, PR, or branch to review]
description: Review code changes for quality, bugs, and style
allowed-tools: Bash, Read, Glob, Grep
---

Review code changes for quality, bugs, and style.

## 1. Get the diff

- If reviewing a PR: `gh pr diff`
- If reviewing a branch: `git diff main...HEAD`
- If reviewing a file: `git diff HEAD -- <file>`
- If reviewing staged changes: `git diff --cached`

## 2. Review for

- **Bugs**: Logic errors, edge cases, off-by-ones, null/None handling
- **Style**: Consistency with project conventions
- **Performance**: Unnecessary allocations, O(n²) where O(n) is possible
- **Security**: Input validation, SQL injection, path traversal
- **Tests**: Are new code paths tested?

## 3. Format feedback

Use these markers for each finding:

- 🐛 **Bug**: Definite or likely bug
- 💡 **Suggestion**: Improvement idea
- ⚠️ **Warning**: Potential issue worth investigating
- ✅ **Looks good**: Notable positive aspects

## 4. Summarize

End with an overall assessment: approve, request changes, or comment.

## Language-specific checks

### Rust
- Check for `unwrap()` in non-test code
- Verify error handling uses proper `Result`/`?` patterns
- Look for unnecessary `.clone()`
- Check lifetime annotations make sense
- Verify `#[must_use]` on functions returning important values

### TypeScript
- Check for `any` types that should be narrower
- Verify async/await error handling
- Look for missing null checks
