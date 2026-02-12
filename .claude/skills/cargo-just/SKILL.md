---
argument-hint: [build|test|lint|fmt|run|check or just task name]
description: Smart project task runner for Rust projects using cargo and just
allowed-tools: Bash, Read, Glob
---

Smart project task runner for Rust projects using cargo and just.

## 1. Check for justfile

If a `justfile` exists in the project root, prefer `just <task>` over raw cargo commands.

List available tasks:
```bash
just --list
```

## 2. Common task mappings

| Task | Just | Cargo |
|---|---|---|
| Build | `just build` | `cargo build` |
| Test | `just test` | `cargo test` |
| Lint | `just lint` | `cargo clippy -- -D warnings` |
| Format | `just fmt` | `cargo fmt` |
| Format check | `just fmt-check` | `cargo fmt -- --check` |
| Run | `just run` | `cargo run` |
| Check | — | `cargo check` (fast compile check) |
| Doc | — | `cargo doc --open` |

## 3. Workspace projects

For workspace projects, specify the package:
```bash
cargo test -p <package>
cargo clippy -p <package> -- -D warnings
```

## 4. Always show the command

Before running any command, display it so the user knows what's being executed.

## 5. Common patterns

### Full pre-commit check
```bash
cargo fmt -- --check && cargo clippy -- -D warnings && cargo test
```

### Watch for changes
```bash
cargo watch -x check -x test
```

### Build for release
```bash
cargo build --release
```
