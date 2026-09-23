# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.3.0] - 2026-09-23

### Fixed

- A key that two features both resolved to no longer disables one of them
  without saying so. Every binding is now collected before any of it reaches
  tmux, a key you set outranks one the plugin defaulted, and the losing action
  stays unbound instead of overwriting the winner. Setting
  `@tiling_revamped_key_pick_layout` to `P` silently lost the layout picker to
  the pane jumper's default `P`, because the jumper was bound later.
- The navigator, workspace, project and vim-aware picker bindings went straight
  to `bind-key` and could overwrite each other in the same way. They now go
  through the same registry.
- With `@tiling_revamped_alt_keys` and `@tiling_revamped_navigator` both on, the
  navigator's `M-j` took the jump-to-mark key and nothing said so. The navigator
  still wins, and the collision is now reported.
- The entry point loads on the bash 3.2 that macOS ships as `/bin/bash`
  instead of printing a raw `declare: -A: invalid option` and binding nothing.
  Associative arrays were declared at file scope, above the version guard meant
  to prevent exactly that, and the guard used `return` outside a function, which
  is invalid when TPM runs the file through `run-shell` rather than sourcing it,
  so it never stopped anything.
- The test helper no longer exports its `tmux` override and socket path to every
  child process. A real tmux server could pick them up and run your installed
  plugins against a test socket that is deleted when the run ends, leaving those
  plugins blocked on it indefinitely.

### Added

- `@tiling_revamped_conflicts` holds every resolved key conflict after start, so
  a clobbered binding is diagnosable once the start-up message is gone.
- `@tiling_revamped_warn_conflicts` (default `1`) silences that message.

## [2.2.0] - 2026-06-30

### Added

- Dynamic layout by pane count. Map pane-count thresholds to layouts with
  `@tiling_revamped_dynamic_layout` (for example `1:monocle 2:main-vertical
  3:dwindle 5:grid`). The auto-apply hook selects the layout whose threshold is
  the greatest value not exceeding the current pane count.
- App-aware tiling rules. List newline-delimited `command:action` rules in
  `@tiling_revamped_app_rules` to auto-assign an action (`master`, `float`, or
  `scratchpad`) to a new pane based on its running command.
- Focus history stack. A capped back/forward stack of focused pane ids lives in
  a window option. Enable it with `@tiling_revamped_focus_history` and walk it
  with the focus-back (`[`) and focus-forward (`]`) keys. Closed panes are
  skipped when navigating.
- Global pane jumper. Press `P` for an fzf popup over every pane across all
  sessions with capture-pane previews. It degrades to `choose-tree` when fzf or
  a popup-capable tmux is unavailable.

## [2.1.0] - 2026-06-30

### Added

- Status-line layout indicator. The active layout name lives in the
  `@tiling_revamped_layout` window option, and a new `status` command renders it
  with a per-layout glyph for use in `status-right`.
- Help overlay. Press `?` to see every resolved keybinding in a popup that
  reflects your custom keys. Falls back to a message on tmux older than 3.2.
- Swap with biggest pane. The `swap-biggest` command swaps the focused pane with
  the largest pane by area, bound to `=` by default.
- Smart borders. With `@tiling_revamped_smart_borders` enabled, pane border
  chrome hides while a window holds one pane and returns when a second appears.
- Layout redo. The `redo` command re-applies an undone layout, bound to `r`. The
  redo stack clears on a fresh layout change.
- Workspace back-and-forth. One key toggles between the current window and the
  one most recently left.

## [2.0.2] - 2026-06-24

### Internal

- Added a `coverage` make target and a CI coverage job so line coverage is now
  gated at 95 percent, matching the rest of the plugin family.
- Moved the eight layout ASCII previews into a single `previews.sh`, excluded
  from coverage measurement, and deepened the operations and features tests.
  Coverage rose from 82 to 95 percent.
- Cleared the actionlint warnings in the workflow: dropped the unused shell
  variables and replaced an `ls` pipeline with `find`.

## [2.0.1] - 2026-06-22

### Fixed

- Setting a `@tiling_revamped_key_*` option to an empty string now disables that
  binding, as the README documents. Option lookup treated an explicit blank the
  same as unset and fell back to the default key, so keys such as `pick_layout`
  could not be disabled.
- A blank standard key no longer leaves the default bound or emits an "unknown
  key" error. Empty keys are skipped during binding.

## [2.0.0] - 2026-04-04

### Added

- Layout undo/redo with 10-entry history stack per window (prefix+u)
- Configurable BSP split ratio via `@tiling_revamped_split_ratio` (20-80)
- Workspace switching: Alt+1-9 switches windows, Alt+Shift+1-9 moves panes
- International keyboard support via `@tiling_revamped_shiftnum`
- Project launcher: fzf popup for opening project directories in new windows
- Interactive layout picker with ASCII diagram previews (from PR #2 by @shivamashtikar)
- tmux-resurrect integration: `restore-layouts` re-applies stored layouts
- Layout validation: `validate` detects and fixes stale layout metadata
- Health check: `doctor` verifies bash, tmux, fzf, and plugin state
- Layout info: `info` shows current layout, orientation, and undo depth
- Pane swap with fzf preview: `swap-pick` lists panes for targeted swapping
- Pane minimum size guard with configurable thresholds
- Help command: `tiling.sh help` prints usage reference in terminal
- 48 balance invariant tests covering all 8 layouts at pane counts 1-10
- Hook deduplication prevents accumulation on config reload
- Bash 4.0+ and tmux 3.2+ version gates with fail-fast messages
- Deprecation framework for future option migrations
- CONTRIBUTING.md with guidelines for adding layouts and operations

### Changed

- main-center layout distributes panes evenly between left and right columns
- BSP split ratio applies at depth 0 only, deeper levels remain 50/50
- Extracted `_reapply_current_layout` shared helper, deduplicated 3 operation files
- Spiral ASCII art aligned with dwindle frame structure (same geometry, different numbering)
- ASCII previews moved from .txt files to exported variables in layout modules
- Deck added to default cycle layout order
- README diagrams updated to match source preview variables

### Fixed

- BSP orientation normalization in pick-layout, cycle, presets, and new-window hook
- fzf version check validates 0.44.0 (--tmux requirement) instead of 0.19.0
- fzf preview uses inline variable expansion (exported functions don't survive tmux popup)
- Missing main-vertical/main-horizontal in presets apply_preset
- flip.sh flag replacement uses direct substitution
- Default key `p` conflict with tmux previous-window documented in conflict table

## [1.1.0] - 2026-03-25

### Added

- Layouts: main-vertical (master left, stack right) and main-horizontal (master top, stack bottom)
- Operations: resize-master (grow/shrink master pane by configurable step), sync (toggle synchronize-panes), swap-direction (swap pane with directional neighbor)
- Default layout for new windows via `@tiling_revamped_default_layout` option and `after-new-window` hook
- Alt keybinding mode via `@tiling_revamped_alt_keys` (binds all actions to `Alt+<key>` without prefix)
- Vim-aware pane navigation via `@tiling_revamped_navigator` (M-h/j/k/l with vim/nvim/fzf detection)
- Integration test suite (60 tests against a real tmux server)
- New keybindings: `v` (main-vertical), `V` (main-horizontal), `+` (grow master), `-` (shrink master), `S` (sync)
- New options: `@tiling_revamped_master_ratio`, `@tiling_revamped_resize_step`

### Fixed

- Spiral pane ordering: `_bsp_fix_pane_order()` is now called after `select-layout` so panes occupy correct BSP depth positions
- Balance operation re-applies the correct layout instead of destroying BSP topology with `even-vertical`
- Main-center layout re-resizes center pane after `move-pane` resets widths
- Scratchpad session name and command are now properly quoted
- Promote and circulate now use recursion guards when re-applying grid/deck layouts
- Grid and deck layouts use `trap RETURN` for the recursion guard, preventing leaked state on early exit
- Unmark by name now clears the pane option on the target pane

### Changed

- Default cycle order includes main-vertical and main-horizontal
- README "How It Works" rewritten to describe the actual BSP algorithm (layout string computation, not flatten-rearrange-size)

## [1.0.0] - 2026-03-20

### Added

- BSP layouts: dwindle (16 orientations) and spiral
- Built-in layouts: grid, main-center, monocle, deck
- Auto-reapplication via tmux hooks (after-split-window, after-kill-pane, pane-exited, window-resized)
- Layout operations: balance, equalize, rotate (90/180/270), flip (h/v)
- Pane operations: promote/demote, circulate (next/prev), autosplit (smart split direction)
- Focus-resize: expand focused pane toward golden ratio on focus change
- Layout cycling through configurable layout list
- Named pane marks with fzf jump-to-mark
- Named scratchpad popups via display-popup (tmux 3.2+)
- Layout presets: save and restore named configurations
- All keybindings configurable via @tiling_revamped_key_* options
- Per-window layout memory via tmux user options
- Recursion guard for hook-based auto-reapplication
- bats-core test suite
- CI for Ubuntu and macOS
