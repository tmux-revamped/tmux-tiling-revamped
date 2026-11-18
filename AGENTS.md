# tmux-tiling-revamped

Guidance for anyone, human or agent, changing tmux-tiling-revamped. What it is and how to use it lives in [README.md](README.md).

[FAMILY.md](FAMILY.md) holds everything this plugin shares with the rest of the tmux-revamped family, and it is the same in every member. This file holds only what is exclusive to tmux-tiling-revamped, under the same headings as the agent guide of every member. Read both before changing anything; a rule that would serve the other members goes into [`FAMILY.md`](FAMILY.md) instead of here.

## Layout

| Path | Holds |
|:-----|:------|
| [`tmux-tiling-revamped.tmux`](tmux-tiling-revamped.tmux) | The entry point TPM runs |
| [`src/tiling.sh`](src/tiling.sh) | The script the entry point and the keys call |
| [`src/lib/features/`](src/lib/features) | This member's modules |
| [`src/lib/layouts/`](src/lib/layouts) | This member's modules |
| [`src/lib/operations/`](src/lib/operations) | This member's modules |
| [`src/lib/utils/constants.sh`](src/lib/utils/constants.sh) | This member's constants, including its version |
| [`src/lib/utils/`](src/lib/utils), [`src/lib/tmux/`](src/lib/tmux) | The shared library. Every file there except `constants.sh` is identical in every member |
| [`test/`](test) | The bats suite. `helpers.bash` and `tmux_helpers.bash` are identical in every member; this member's own mocks go in the `_local` files |

## Names

- Settings are tmux options named `@tiling_revamped_<setting>`.
- It has no status placeholders.
- The version constant is `TILING_REVAMPED_VERSION`.
- Its command-line tool, once it exists, is `tmux-tiling-revamped`.

## Behaviour

- Manages pane layouts like a tiling window manager: eight layouts including BSP dwindle and spiral, with layout undo.
- It owns every `M-` plus uppercase letter, listed in the family key allocation.
- A key that cannot act says why in a tmux message, from the dispatcher so the hooks stay quiet: flip and rotate outside dwindle and spiral, undo and redo with no history, focus back and forward while `@tiling_revamped_focus_history` is off, which is its default, and the mark jump with no mark. [`test/integration/keys.bats`](test/integration/keys.bats) presses every key through a second tmux attached to a private server.
- The entry point checks the bash and tmux versions, collects every key binding into a registry, resolves conflicts, writes the bindings, and installs the hooks its options need. State lives in tmux user options at window, pane and global scope.
- `doctor`, `info`, `validate` and `restore-layouts` are commands of [`src/tiling.sh`](src/tiling.sh).

## Domain rules

- A BSP layout is built as a binary tree, turned into a tmux layout string with the 16-bit checksum tmux expects, and placed with one `select-layout` call.
- A hook re-tiles only the window it fired for, and `@tiling_revamped_applying` stops hooks from re-tiling a layout while it is applied.
- Its entry point is [`tmux-tiling-revamped.tmux`](tmux-tiling-revamped.tmux), so its tool is `tmux-tiling-revamped`.

## Release

- `TILING_REVAMPED_VERSION` in [`src/lib/utils/constants.sh`](src/lib/utils/constants.sh) holds the version. Nobody edits it by hand.
- After a green `Tests` run on `main`, [`release.yml`](.github/workflows/release.yml) runs semantic-release from [`.releaserc.json`](.releaserc.json): a `feat` or `fix` since the last tag publishes a release, [`set-version.sh`](.github/scripts/set-version.sh) stamps the constant, and the notes go into [`CHANGELOG.md`](CHANGELOG.md).

## Gaps against FAMILY.md

As of 2026-11-17:

- The Linux jobs of CI install no `fzf`, and five tests in [`test/integration/keys.bats`](test/integration/keys.bats) and [`test/integration.bats`](test/integration.bats) skip without it, so on Linux the mark picker is tested only on a machine that has fzf.
- Every script is bash, under `#!/usr/bin/env bash`, not POSIX `sh`, so it is untested under `dash`, `zsh` and BusyBox `sh`.
- The code lives in [`src/`](src) and [`src/lib/`](src/lib); there is no `bin/tmux-tiling-revamped`, `lib/state.sh` or `lib/core.sh`.
- No `tmux-tiling-revamped` command with `help`, `version` and `doctor` in the family's form, no man page, no completions and no `manifest.json`.
- No gum interface: no `lib/ui.sh`, `lib/table.awk`, themes or `test/bin/gum`.
- No `screens/`: no VHS recording of each feature, no on-screen caption of the keys each recording presses, and no recordings in the README.
- The README sections are not the family's order of Quick start, Usage, topic sections, Portability, Development and License.
- Coverage is kcov with a 95 percent floor on Linux, not bashcov at 100 percent merged from macOS and Linux.
- CI tests GNU, BSD and uutils tools in `tests.yml`, but not the six toolsets through `.github/scripts/toolset.sh`, and no shell matrix under `sh`, `dash`, `bash` and `zsh`.
- No golden transcripts, `call.sh`, `run-matrix.sh` or `linux-container.sh`.
- [`release.yml`](.github/workflows/release.yml) follows `Tests` and has no `recover` job, and [`.releaserc.json`](.releaserc.json) and `set-version.sh` name `src/lib/utils/constants.sh`, so the three differ from the family's copies; there is no `ci-state.sh`, `recover.sh`, `bot-merge.yml` or Renovate.
- CI is `tests.yml` and `security.yml`, not `ci.yml`, and no job starts with `step-security/harden-runner`.
- No `.yamllint.yml` or shfmt; the Makefile has `help`, `test`, `test-unit`, `coverage`, `lint` and `clean`, not the family's targets.
- It needs bash 4 for associative arrays, so on the macOS `/bin/bash` 3.2 it shows a message and binds nothing.
- `get_tmux_option` keeps a tmux option set to nothing as an empty value, where FAMILY.md has it mean the default; the ticker's own reader already takes the default.
