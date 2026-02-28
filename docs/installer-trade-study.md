# Installer Trade Study — Cross-Platform Tool Installation

## Goal

One-command setup of all development tools on a fresh macOS or Windows machine, inspired by the Determinate Systems `curl | sh` pattern.

## Strategies Evaluated

### Option A: Single Bash Script (`install.sh`)

**Pattern**: `curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash`

```
install.sh
├── detect OS / arch
├── install package manager (brew / scoop)
├── install tools via package manager
├── install Rust via rustup.rs
├── install Node via nvm
├── install uv via astral.sh
└── summary
```

**Pros**:
- Dead simple — one file, no dependencies beyond bash
- Works immediately from curl pipe (Determinate Systems pattern)
- Easy to read and modify
- Can run `--dry-run` to preview
- Works on macOS and Windows/Git Bash

**Cons**:
- Bash scripting is fragile — error handling is manual
- No parallelism (installs are sequential)
- Hard to test (need actual machines or containers)
- Windows support via Git Bash is janky (Scoop needs PowerShell)
- No lockfile or version pinning — `brew install eza` gets whatever's latest

**Complexity**: Low
**Maintenance**: Low
**Best for**: Personal use, quick setup

---

### Option B: Brewfile + Scoopfile (Declarative Package Lists)

**Pattern**: Separate declarative package lists per platform, thin wrapper script.

```
Brewfile              # macOS: brew bundle
Scoopfile.json        # Windows: scoop import
install.sh            # thin wrapper: detect OS, run the right one
install-extras.sh     # Rust, Node, uv (not in package managers)
```

**macOS Brewfile** (native Homebrew feature):
```ruby
# Core CLI
brew "eza"
brew "bat"
brew "git-delta"
brew "zoxide"
brew "just"
brew "ripgrep"
brew "lazygit"
brew "gum"
brew "fd"
brew "jq"
brew "gh"
brew "neovim"

# Casks
cask "ghostty"
```

**Windows Scoopfile.json**:
```json
{
  "buckets": [{"Name": "main"}, {"Name": "extras"}],
  "apps": [
    {"Name": "eza"}, {"Name": "bat"}, {"Name": "delta"},
    {"Name": "zoxide"}, {"Name": "just"}, {"Name": "ripgrep"},
    {"Name": "lazygit"}, {"Name": "gum"}, {"Name": "fd"},
    {"Name": "jq"}, {"Name": "gh"}
  ]
}
```

**Pros**:
- Declarative — add/remove tools by editing a list, not script logic
- `brew bundle` is idempotent, well-tested, handles dependencies
- Brewfile can include casks (GUI apps like Ghostty)
- Easy to diff — "what changed in my tool list?" is a clean git diff
- Community-standard pattern (many dotfiles repos use Brewfile)

**Cons**:
- Two separate files to maintain (Brewfile + Scoopfile)
- Doesn't cover non-package-manager tools (Rust, nvm, uv) — needs a companion script
- `brew bundle` is macOS only; Scoop import is less mature
- No cross-platform single source of truth

**Complexity**: Low–Medium
**Maintenance**: Low (declarative lists are easy to update)
**Best for**: Separation of concerns, adding GUI apps too

---

### Option C: YAML/TOML Manifest + Rust/Python Runner

**Pattern**: Single manifest file defining all tools, cross-platform runner interprets it.

```
tools.yaml            # single source of truth
install.py            # or install (Rust binary)
```

**tools.yaml**:
```yaml
tools:
  core:
    - name: eza
      macos: { brew: eza }
      windows: { scoop: eza }
      check: "eza --version"
    - name: bat
      macos: { brew: bat }
      windows: { scoop: bat }
      check: "bat --version"
    - name: delta
      macos: { brew: git-delta }
      windows: { scoop: delta }
      check: "delta --version"
    # ...
  
  languages:
    - name: rust
      install: "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
      check: "rustc --version"
    - name: node
      install_macos: "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash"
      install_windows: "scoop install nvm"
      check: "node --version"

  cargo:
    - name: cargo-watch
      install: "cargo install cargo-watch"
      check: "cargo watch --version"
```

**Pros**:
- Single source of truth across platforms
- Adding a tool = adding 3 lines to YAML
- Can generate Brewfile/Scoopfile from the manifest
- Version pinning possible
- Runner can parallelize installs, show progress bars, handle retries

**Cons**:
- Needs Python or Rust pre-installed to run the installer (chicken-and-egg)
- Over-engineered for ~20 tools
- More code to maintain (the runner is non-trivial)
- YAML parsing in bash is painful; needs a real language

**Complexity**: Medium–High
**Maintenance**: Medium
**Best for**: Teams, 50+ tools, CI/CD pipelines

---

### Option D: Nix / Home Manager (Fully Declarative)

**Pattern**: Nix flake with home-manager for user-level packages.

```nix
# flake.nix
{
  inputs = { nixpkgs.url = "github:nixpkgs/nixpkgs/nixos-unstable"; home-manager.url = "..."; };
  outputs = { ... }: {
    homeConfigurations."iancleary" = home-manager.lib.homeManagerConfiguration {
      packages = with pkgs; [ eza bat delta zoxide just ripgrep lazygit gum fd jq gh neovim ];
    };
  };
}
```

**Pros**:
- Truly reproducible — same versions everywhere
- Single command: `nix run . -- switch`
- Rollback support
- Massive package repository (90,000+ packages)
- Cross-platform (macOS via nix-darwin, Linux native)

**Cons**:
- Nix learning curve is steep
- Nix doesn't support Windows (only WSL)
- Large disk footprint (~5 GB for Nix store)
- Shell integration (oh-my-zsh, p10k) is awkward in Nix
- Conflicts with Homebrew if both are installed
- Overkill for dotfiles

**Complexity**: High
**Maintenance**: Medium (once set up, very stable)
**Best for**: Linux-first, reproducibility-obsessed, NixOS users

---

### Option E: Ansible Playbook

**Pattern**: Ansible playbook with roles per tool category.

```yaml
# playbook.yml
- hosts: localhost
  roles:
    - role: package-manager  # install brew/scoop
    - role: cli-tools        # eza, bat, delta, etc.
    - role: languages        # rust, node, python
    - role: shell            # oh-my-zsh, p10k
```

**Pros**:
- Mature, well-documented tool
- Idempotent by design
- Good cross-platform support
- Can configure OS settings too (macOS defaults, etc.)
- Roles are reusable and composable

**Cons**:
- Requires Python + Ansible pre-installed
- Verbose YAML for simple `brew install` commands
- Slow startup (Python + Ansible overhead)
- Overkill for personal dotfiles
- Windows support is limited

**Complexity**: Medium
**Maintenance**: Medium
**Best for**: Infrastructure-as-code teams, managing multiple machines

---

## Comparison Matrix

| Criteria | A: Bash | B: Brewfile | C: YAML+Runner | D: Nix | E: Ansible |
|----------|---------|-------------|-----------------|--------|------------|
| Simplicity | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐ | ⭐⭐ |
| Windows support | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ❌ | ⭐ |
| macOS support | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Curl-pipe install | ✅ | ✅ (wrapper) | ❌ | ✅ | ❌ |
| Declarative | ❌ | ✅ | ✅ | ✅ | ✅ |
| No dependencies | ✅ | ✅ | ❌ | ❌ | ❌ |
| Version pinning | ❌ | ❌ | ✅ | ✅ | ❌ |
| GUI apps (casks) | ❌ | ✅ | ✅ | ⭐⭐ | ✅ |
| Maintenance effort | Low | Low | Medium | Medium | Medium |
| Time to implement | 2hr | 1hr | 4hr | 8hr | 4hr |

## Recommendation

**Implement Option A + B hybrid:**

1. **`Brewfile`** for macOS packages (declarative, `brew bundle` handles everything)
2. **`Scoopfile.json`** for Windows packages
3. **`install.sh`** thin wrapper that:
   - Detects OS
   - Installs Homebrew/Scoop if needed
   - Runs `brew bundle` or `scoop import`
   - Installs non-package-manager tools (Rust, nvm, uv)
   - Shows summary
4. **`install-cargo-tools.sh`** separate for cargo installs (slow, optional)

This gives you:
- The `curl | sh` simplicity of Option A
- The declarative tool lists of Option B
- No exotic dependencies (no Python, Nix, or Ansible required)
- Easy to maintain — adding a tool = one line in Brewfile

The sub-agent is currently building Option A (pure bash). I'd suggest we also add the Brewfile/Scoopfile alongside it so you have both patterns to compare.
