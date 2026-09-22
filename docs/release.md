# Release process

Dotfiles uses GitHub tag-only releases with local-calendar version numbers
`YYYY.MM.DD.XX`. The first release of a day ends in `.00`; later releases on
that day use `.01` through `.99`. A release does not change a version file.

`release.toml` defines the release contract. `scripts/release.py` is an
unchanged vendored runner from `iancleary/release-skills`; its source revision
and SHA-256 are recorded in the contract. `scripts/cut_release.py` infers the
next daily number from fetched tags and delegates to that runner.

From a clean, up-to-date `main` checkout with GitHub CLI authentication:

```sh
uv run --script scripts/cut_release.py --print-current-version
uv run --script scripts/cut_release.py --print-next-version
uv run --script scripts/cut_release.py --dry-run
uv run --script scripts/cut_release.py
```

The dry run fetches tags and performs validation but does not publish. The
runner checks shell syntax, parses all Nix files, and builds both example Home
Manager profiles without activating either one. The applied run requires clean
`main` containing `origin/main`, checks GitHub access, creates and pushes an
annotated tag, and publishes a GitHub release. By default, its notes are
`Release VERSION`; pass `--notes-file PATH` for reviewed Markdown notes.

If publication fails after a tag is pushed, inspect the remote tag and GitHub
release before retrying. Do not move or force-push the tag. Follow the
`release-runner` skill's documented resume procedure for a matching tag.
Use `create-release-process` to change this workflow and `cut-release` for
ordinary releases.
