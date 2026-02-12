---
argument-hint: [file or function to test]
description: Generate tests for existing code
allowed-tools: Bash, Read, Write, Glob, Grep
---

Generate tests for existing code.

## 1. Identify the testing framework

- **Rust**: built-in `#[cfg(test)]` + `#[test]`, or `tests/` dir for integration tests
- **TypeScript**: check for vitest/jest/playwright in `package.json`
- **Python**: check for pytest/unittest

## 2. Read the target code

Read the file/function to understand:
- Input types and ranges
- Return types and possible values
- Side effects
- Error conditions

## 3. Generate tests covering

- **Happy path**: Normal expected usage
- **Edge cases**: Empty input, zero, None/null, boundary values, max values
- **Error cases**: Invalid input, missing data, network failures
- **Integration**: How the function interacts with dependencies (if applicable)

## 4. Place tests conventionally

- **Rust**: `#[cfg(test)] mod tests {}` at bottom of file, or `tests/` dir for integration tests
- **TypeScript**: `__tests__/` or `*.test.ts` adjacent to source
- **Python**: `tests/` directory with `test_` prefix

## 5. Run and verify

Run the tests to verify they pass:
- Rust: `cargo test`
- TypeScript: `npx vitest run` or `npx jest`
- Python: `pytest`

## Style guidelines

- Test names should describe the behavior: `test_empty_input_returns_none`
- One assertion per test when practical
- Use descriptive assertion messages
- Arrange-Act-Assert pattern
