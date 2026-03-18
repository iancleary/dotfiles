# Codebase Improvements

Prioritized by risk and impact. Generated 2026-03-17.

---

## 1. [BUG] `ga()` returns exit code 1 on success

**Issue**: In `.common/agents-git-trees.sh:21`, `ga()` returns `1` after successfully creating and switching to a worktree. This signals failure to the calling shell — any `ga && next_command` chain would skip `next_command`, and `set -e` contexts would abort.

**Solution**:

```bash
# Before (line 21)
return 1

# After
return 0
```

**Files to Change**: `.common/agents-git-trees.sh`

**Acceptance Criteria**:
- [ ] `ga feature-x && echo "success"` prints "success"
- [ ] Works in `set -e` scripts

**Effort**: 1 minute
**Risk**: None

---

## 2. [BUG] `cmd_diff` only lists OS-specific files in usage hint

**Issue**: In `sync-dotfiles.sh:328`, `cmd_diff` shows "Available files" from only `DOTFILES[]` (the OS-specific list), omitting `COMMON_DOTFILES[]`. Users can't see that they can diff skill files or `.common/` files.

**Solution**:

```bash
# Before (lines 328-330)
for f in "${DOTFILES[@]}"; do
    echo "  $f"
done

# After
build_file_list
for f in "${ALL_FILES[@]}"; do
    echo "  $f"
done
```

**Files to Change**: `sync-dotfiles.sh`

**Acceptance Criteria**:
- [ ] `./sync-dotfiles.sh diff` with no args shows all tracked files

**Effort**: 2 minutes
**Risk**: None

---

## 3. [ROBUSTNESS] `gd()` silently does nothing when not in a worktree directory

**Issue**: In `.common/agents-git-trees.sh:38`, if the current directory doesn't contain `--` in its name, `$root == $branch` and the function silently skips deletion after the user already confirmed. No feedback is given.

**Solution**:

```bash
if [[ "$root" != "$branch" ]]; then
    cd "../$root"
    git worktree remove "$worktree" --force
    git branch -D "$branch"
else
    echo "Error: current directory '$worktree' doesn't match worktree naming convention (branch--repo)"
    echo "Navigate to a worktree created with 'ga' first."
fi
```

**Files to Change**: `.common/agents-git-trees.sh`

**Acceptance Criteria**:
- [ ] Running `gd` outside a worktree dir shows a clear error after confirmation
- [ ] Running `gd` inside a correctly named worktree works as before

**Effort**: 2 minutes
**Risk**: None

---

## 4. [DUPLICATION] `install-cargo-tools.sh` duplicates tools from `cargo-tools.txt`

**Issue**: `install-cargo-tools.sh` hardcodes `TOOLS=(cargo-watch cargo-mutants cargo-semver-checks cargo-edit)` while `install.sh` reads the same tools from `cargo-tools.txt`. If you add a tool to one, you'd need to update the other — and they use different install flags (`--locked` vs not).

**Solution**: Make `install-cargo-tools.sh` read from `cargo-tools.txt` like `install.sh` does, filtering to only the slow-to-compile tools:

```bash
# Option A: Read from cargo-tools.txt, filtering to known "slow" ones
SLOW_TOOLS="cargo-watch cargo-mutants cargo-semver-checks cargo-edit"

# Option B: Delete install-cargo-tools.sh entirely and add a --only-cargo flag to install.sh
```

Also add `--locked` to be consistent with `install.sh`.

**Files to Change**: `install-cargo-tools.sh` (or delete it)

**Acceptance Criteria**:
- [ ] No hardcoded tool list that can drift from cargo-tools.txt
- [ ] Uses `--locked` consistently

**Effort**: 15 minutes
**Risk**: Low

---

## 5. [ROBUSTNESS] `ga()` doesn't verify it's in the main worktree

**Issue**: If you're already inside a worktree (e.g., `../feature-x--myrepo/`) and run `ga new-branch`, the relative path `../new-branch--feature-x--myrepo` produces a broken naming convention. This also means `gd` wouldn't parse the directory name correctly.

**Solution**: Check if the current directory is the main worktree before creating a new one:

```bash
function ga() {
  # ... existing arg check ...

  # Ensure we're in the main worktree, not a child
  local main_worktree
  main_worktree="$(git worktree list --porcelain | head -1 | sed 's/^worktree //')"
  if [[ "$PWD" != "$main_worktree" ]]; then
    echo "Error: run 'ga' from the main worktree, not a child worktree."
    echo "Main worktree: $main_worktree"
    return 1
  fi

  # ... rest of function ...
}
```

**Files to Change**: `.common/agents-git-trees.sh`

**Acceptance Criteria**:
- [ ] `ga` from main worktree creates correctly named child worktree
- [ ] `ga` from a child worktree shows error with the path to navigate to

**Effort**: 5 minutes
**Risk**: None

---

## 6. [QUALITY] Duplicated color/logging definitions across 3 scripts

**Issue**: `sync-dotfiles.sh`, `install.sh`, and `install-cargo-tools.sh` each define their own color variables and logging helpers. Not a bug, but maintenance overhead — adding a new script means copy-pasting the boilerplate.

**Solution**: Extract into `.common/log-helpers.sh` and source from each script:

```bash
# .common/log-helpers.sh
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'
RESET="$NC"

log_ok()      { echo -e "  ${GREEN}✓${NC} $1"; }
log_skip()    { echo -e "  ${YELLOW}–${NC} $1 ${DIM}(skipped)${NC}"; }
log_fail()    { echo -e "  ${RED}✗${NC} $1"; }
log_section() { echo -e "\n${BOLD}$1${NC}\n"; }
```

**Tradeoff**: `install.sh` is designed to work standalone via `curl | bash`, so it can't source from the repo. This extraction only helps `sync-dotfiles.sh` and `install-cargo-tools.sh` (which already require the repo). Could keep `install.sh` self-contained and extract for the others.

**Files to Change**: New `.common/log-helpers.sh`, update `sync-dotfiles.sh` and `install-cargo-tools.sh`

**Acceptance Criteria**:
- [ ] No duplicated color definitions between sync and cargo scripts
- [ ] `install.sh` remains standalone (no external source dependencies)

**Effort**: 20 minutes
**Risk**: Low — must test that sourcing works from both script locations

---

## 7. [CLEANUP] No mechanism to clean up `.backup.*` files

**Issue**: `sync-dotfiles.sh push` creates timestamped backup files (e.g., `.zshrc.backup.20260317_143022`) in `$HOME` before overwriting. Over time these accumulate. There's no command to list or prune them.

**Solution**: Add a `clean` subcommand:

```bash
cmd_clean() {
    echo ""
    info "Searching for backup files in $HOME_DIR..."

    build_file_list
    local count=0

    for file in "${ALL_FILES[@]}"; do
        local pattern="$HOME_DIR/${file}.backup.*"
        for backup in $pattern; do
            [[ -f "$backup" ]] || continue
            echo "  $backup"
            ((count++)) || true
        done
    done

    if [[ $count -eq 0 ]]; then
        success "No backup files found"
        return
    fi

    echo ""
    warn "Found $count backup file(s). Remove them? [y/N]"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        for file in "${ALL_FILES[@]}"; do
            rm -f "$HOME_DIR/${file}.backup."* 2>/dev/null
        done
        success "Cleaned up $count backup file(s)"
    fi
}
```

**Files to Change**: `sync-dotfiles.sh`

**Acceptance Criteria**:
- [ ] `./sync-dotfiles.sh clean` lists and optionally removes backup files
- [ ] Only removes backup files for tracked dotfiles, not unrelated files

**Effort**: 15 minutes
**Risk**: Low — interactive confirmation protects against accidents

---

## 8. [MINOR] `find -L` in SYNCED_SKILL_DIRS includes hidden/unwanted files

**Issue**: Line 75 of `sync-dotfiles.sh` uses `find -L ... -type f` which follows symlinks and includes any file — including `.DS_Store`, `.gitkeep`, editor temp files, etc.

**Solution**: Exclude hidden files and common junk:

```bash
find -L "$REPO_DIR/$skill_dir" -type f \
    -not -name '.*' \
    -not -name '*~' \
    -print0 2>/dev/null | sort -z
```

**Files to Change**: `sync-dotfiles.sh`

**Effort**: 2 minutes
**Risk**: None

---

## Summary

| # | Issue | Category | Effort | Impact |
|---|-------|----------|--------|--------|
| 1 | `ga()` returns 1 on success | Bug | 1 min | High |
| 2 | `cmd_diff` shows incomplete file list | Bug | 2 min | Medium |
| 3 | `gd()` silently does nothing on mismatch | Robustness | 2 min | Medium |
| 4 | Duplicated cargo tools list | Duplication | 15 min | Medium |
| 5 | `ga()` from child worktree breaks naming | Robustness | 5 min | Medium |
| 6 | Duplicated color/logging boilerplate | Quality | 20 min | Low |
| 7 | No backup file cleanup command | Cleanup | 15 min | Low |
| 8 | `find` includes hidden files | Minor | 2 min | Low |

**Recommended order**: 1 → 2 → 3 → 5 → 8 → 4 → 7 → 6 (bugs first, then quick wins, then larger refactors)
