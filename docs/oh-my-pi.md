# Oh My Pi harness

Oh My Pi (`omp`) is a fast-moving coding-agent harness. Mise owns its executable
in this repository. The shared `mise.toml` requests the latest release, while
`mise.lock` fixes reviewed Linux x64 and macOS arm64 artifacts and checksums.
The optional work-machine profile makes the same request.

Oh My Pi owns its writable state. Its default agent directory is
`~/.omp/agent`: `config.yml` contains user settings, `agent.db` contains stored
provider authentication, and the remaining state includes sessions and other
runtime data. Do not commit that directory, credentials, session history, or
machine-local provider configuration here.

Oh My Pi discovers repository `AGENTS.md` files and compatible skills and MCP
configuration already present under locations such as `.codex` and `.claude`.
Keep those sources with their current owners; do not copy them into `.omp` just
to make them visible to the harness.

## Install and verify

After updating this checkout on an enrolled machine:

```sh
mise install --locked 'github:can1357/oh-my-pi'
omp --version
omp config path
```

The version must match `mise.lock`, and `omp config path` should report the
machine-local agent directory. Home Manager consumers may import
`dotfiles.homeManagerModules.ompCompletion` to generate Zsh completion from the
active `omp` executable.

To inspect the harness without sharing default-profile state, use a named
profile:

```sh
omp --profile trial
```

For normal use, start `omp` in a repository and run `/login` when the selected
provider needs authentication:

```sh
cd /path/to/repository
omp
```

Authentication is per machine. Validate a new installation with a small
read-only request first, inspect the loaded context and tools, then approve a
small edit in a disposable branch or worktree before relying on it for normal
work.

## Update

Resolve and review a new cross-platform candidate on the lead machine:

```sh
MISE_SAFE=1 mise lock --global --bump \
  'github:can1357/oh-my-pi' \
  --platform linux-x64,macos-arm64 --json
mise install --locked 'github:can1357/oh-my-pi'
omp --version
```

Commit the manifest and lockfile together. On each follower, pull the reviewed
commit, install with `--locked`, verify the version, and run the read-only and
small-edit checks again. Retain the previous mise installation until the new
harness passes those checks.
