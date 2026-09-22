# Agent instructions

- Read `README.md` and `docs/release.md` before release work.
- Use the `create-release-process` skill to maintain the release workflow.
  Keep `release.toml`, `scripts/release.py`, `scripts/cut_release.py`, and
  `scripts/check.sh` aligned with the docs.
- Use the `cut-release` and `release-runner` skills with the repo-local runner
  for ordinary releases. Do not reconstruct tag, push, or GitHub release
  commands by hand.
- Releases use `YYYY.MM.DD.XX`; the first release of a day ends in `.00`.
- Validate release changes with `bash scripts/check.sh`. A release runner
  requires clean, current `main` before publishing.
