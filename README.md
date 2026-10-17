<div align="center">

<h1>tmux-tiling-revamped</h1>

<strong>BSP tiling window management for tmux. Eight layouts, nineteen operations, zero dependencies.</strong>

<br>
<br>

[![Tests](https://github.com/tmux-revamped/tmux-tiling-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-tiling-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/github/license/tmux-revamped/tmux-tiling-revamped?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/version-3.0.0-blue?style=flat-square)](CHANGELOG.md)
[![tmux](https://img.shields.io/badge/tmux-3.2%2B-green?style=flat-square)](https://github.com/tmux/tmux)
[![bash](https://img.shields.io/badge/bash-4.0%2B-blue?style=flat-square)](https://www.gnu.org/software/bash/)

</div>

---

**8** layouts  ·  **16** BSP orientations  ·  **19** operations  ·  **36+** commands  ·  **zero** dependencies

<table>
<tr>
<td width="50%" valign="top">

### BSP Tiling

Dwindle and spiral layouts with 16 orientation variants and configurable first-split ratio. Panes cascade into binary space partitions toward any corner.

</td>
<td width="50%" valign="top">

### Layout Undo

Every layout change is saved to a per-window history stack. One keystroke reverts to the previous arrangement. Up to 10 levels deep.

</td>
</tr>
<tr>
<td width="50%" valign="top">

### i3-Style Workspaces

Alt+1-9 switches windows. Alt+Shift+1-9 moves panes between windows. International keyboard support via configurable Shift+number mappings.

</td>
<td width="50%" valign="top">

### fzf Layout Picker

Interactive popup with ASCII diagram previews for all 8 layouts. Shows current layout in the header. Configurable popup dimensions.

</td>
</tr>
<tr>
<td width="50%" valign="top">

### Balanced Distribution

Main-center distributes extra panes evenly between left and right columns. A balance test suite checks every layout at pane counts 1 to 10.

</td>
<td width="50%" valign="top">

### Diagnostics Built In

`doctor` checks your environment. `info` shows current state. `validate` detects stale metadata. `help` prints a complete reference from the terminal.

</td>
</tr>
</table>

## Why

tmux has five built-in layouts. None do BSP tiling. Existing plugins each solve a piece but leave gaps.

| Capability | tiling-revamped | tmux-tilish | tmux-tilit |
|:-----------|:---------------:|:-----------:|:----------:|
| BSP dwindle + spiral | Yes | No | No |
| 16 orientation variants | Yes | No | No |
| Configurable split ratio | Yes | No | No |
| Layout undo/redo | Yes | No | No |
| Layout picker (fzf) | Yes | No | No |
| Balanced main-center | Yes | No | No |
| Workspace switching | Yes | Yes | Yes |
| Project launcher | Yes | Yes | No |
| Pane marks | Yes | No | No |
| Scratchpads | Yes | No | No |
| Presets (save/restore) | Yes | No | No |
| Health check (doctor) | Yes | No | No |
| tmux-resurrect integration | Yes | No | No |
| Rotate / flip | Yes | No | No |
| Auto-reapplication | Yes | Yes | Yes |
| Vim-aware navigation | Yes | Yes | Yes |
| International keyboards | Yes | Yes | Yes |

## Architecture

```mermaid
graph LR
    K[Keybinding] --> D[tiling.sh<br>Dispatcher]
    H[tmux Hook] --> D
    D --> L[Layouts<br>8 modules]
    D --> O[Operations<br>17 modules]
    D --> F[Features<br>7 modules]
    L --> T[Batched tmux<br>Commands]
    O --> T
    F --> T
    T --> S[(tmux State<br>User Options)]
    S -.->|auto-reapply| H
```

State is stored in tmux user options at window, pane, or global scope. No temp files, no external state.

## Layouts

### Dwindle

BSP cascade toward a corner. Each new pane takes half of the remaining space.

**4 panes**

```
┌───────────────────┬───────────────────┐
│                   │                   │
│                   │         2         │
│         1         │                   │
│                   ├─────────┬─────────┤
│                   │         │         │
│                   │    3    │    4    │
└───────────────────┴─────────┴─────────┘
```

### Spiral

Same BSP algorithm as dwindle, but the spiral trajectory reverses pane ordering at each depth. The frame is identical to dwindle, only the pane numbers differ.

**4 panes**

```
┌───────────────────┬───────────────────┐
│                   │                   │
│                   │         2         │
│         1         │                   │
│                   ├─────────┬─────────┤
│                   │         │         │
│                   │    4    │    3    │
└───────────────────┴─────────┴─────────┘
```

### Grid

Even N x M grid. Uses tmux's built-in tiled layout.

**4 panes**

```
┌───────────────────┬───────────────────┐
│                   │                   │
│         1         │         2         │
│                   │                   │
├───────────────────┼───────────────────┤
│                   │                   │
│         3         │         4         │
│                   │                   │
└───────────────────┴───────────────────┘
```

### Main-Center

Wide center pane with balanced side columns. Extra panes distribute evenly.

**6 panes**

```
┌─────────┬───────────────────┬─────────┐
│    2    │                   │    4    │
├─────────┤                   ├─────────┤
│    3    │         1         │    5    │
│         │                   ├─────────┤
│         │                   │    6    │
└─────────┴───────────────────┴─────────┘
```

### Main-Vertical

Master left, stack right. Master size controlled by `@tiling_revamped_master_ratio`.

**4 panes**

```
┌───────────────────┬───────────────────┐
│                   │         2         │
│                   ├───────────────────┤
│         1         │         3         │
│                   ├───────────────────┤
│                   │         4         │
│                   │                   │
└───────────────────┴───────────────────┘
```

### Main-Horizontal

Master top, stack bottom. Master size controlled by `@tiling_revamped_master_ratio`.

**4 panes**

```
┌───────────────────────────────────────┐
│                                       │
│                  1                    │
│                                       │
├───────────┬───────────┬───────────────┤
│     2     │     3     │       4       │
└───────────┴───────────┴───────────────┘
```

### Monocle

Zoom the focused pane to fill the entire window. Press the same key again to toggle zoom off and restore the previous layout.

```
┌───────────────────────────────────────┐
│                                       │
│                                       │
│                  1                    │
│              [ZOOMED]                 │
│                                       │
│                                       │
└───────────────────────────────────────┘
(other panes hidden behind)
```

### Deck

All panes at full height, side by side at equal widths.

**4 panes**

```
┌─────────┬─────────┬─────────┬─────────┐
│         │         │         │         │
│         │         │         │         │
│    1    │    2    │    3    │    4    │
│         │         │         │         │
│         │         │         │         │
└─────────┴─────────┴─────────┴─────────┘
```

## Quick Start

### Prerequisites

| Tool | Version | Install |
|:-----|:--------|:--------|
| tmux | 3.2+ | [github.com/tmux/tmux](https://github.com/tmux/tmux) |
| bash | 4.0+ | Ships with Linux. macOS: `brew install bash` |
| TPM | latest | [github.com/tmux-plugins/tpm](https://github.com/tmux-plugins/tpm) |
| fzf | any | Optional. Enables the layout picker, pane jumper, swap picker, project launcher and fuzzy mark/preset selection. fzf 0.53.0+ opens them with `--tmux`; older releases run inside a `display-popup` |

### Install

Add to `~/.tmux.conf`:

```tmux
set -g @plugin 'tmux-revamped/tmux-tiling-revamped'
```

Press `prefix + I` to install via TPM.

### Verify

Open tmux, create a few panes, then press `prefix + M-D`, Alt and Shift with `d`. All panes rearrange into a dwindle layout.

## Default Keybindings

All keybindings use the tmux prefix. Every default is `M-` plus an uppercase
letter, Alt and Shift with the letter, a range the tmux-revamped family reserves
for this plugin and stock tmux leaves unbound, so no default replaces a tmux key
or another family plugin's key. Every key is configurable via
`@tiling_revamped_key_*` options.

Two features must never resolve to the same key. When they do, the key you set
wins over the one this plugin defaulted, the losing action stays unbound, and
the resolution is reported on start and left in `@tiling_revamped_conflicts`.

With `@tiling_revamped_alt_keys` on, a key that already starts with `M-` binds
as itself in the root table, so the defaults become prefixless `M-D`, `M-S` and
so on, and a plain key such as `d` binds as `M-d`.

| Key | Action | Command | Mnemonic |
|:----|:-------|:--------|:---------|
| `M-A` | Smart split along longest axis | `autosplit` | A for autosplit |
| `M-B` | Balance panes | `balance` | B for balance |
| `M-C` | Circulate panes | `circulate` | C for circulate |
| `M-D` | Apply dwindle layout | `layout dwindle` | D for dwindle |
| `M-E` | Equalize panes | `equalize` | E for equalize |
| `M-F` | Flip layout horizontally | `flip` | F for flip |
| `M-G` | Grow master pane | `resize-master grow` | G for grow |
| `M-H` | Apply main-horizontal layout | `layout main-horizontal` | H for horizontal |
| `M-I` | Show keybinding overlay | `help-overlay` | I for info |
| `M-J` | Jump to marked pane | `jump` | J for jump |
| `M-K` | Mark pane with a name | `mark <name>` | K for mark, M is master |
| `M-L` | Open layout picker | `pick` | L for layout |
| `M-M` | Promote focused pane to master | `promote` | M for master |
| `M-N` | Focus forward in focus history | `focus-forward` | N for next |
| `M-O` | Cycle to next layout | `cycle` | O, the old cycle key |
| `M-P` | Focus previously focused pane | `focus-back` | P for previous |
| `M-Q` | Jump to any pane across sessions | `pane-jump` | Q for query every pane |
| `M-R` | Rotate layout 90 degrees | `rotate` | R for rotate |
| `M-S` | Apply spiral layout | `layout spiral` | S for spiral |
| `M-T` | Toggle scratchpad popup | `scratchpad` | T for terminal |
| `M-U` | Undo last layout change | `undo` | U for undo |
| `M-V` | Apply main-vertical layout | `layout main-vertical` | V for vertical |
| `M-W` | Swap focused pane with the largest | `swap-biggest` | W for widest |
| `M-X` | Shrink master pane | `resize-master shrink` | X to cut the master down |
| `M-Y` | Toggle synchronize panes | `sync` | Y for sync |
| `M-Z` | Redo last undone layout | `redo` | Z, the redo key of most editors |

## Configuration

All options use the `@tiling_revamped_` prefix.

### Behavior

| Option | Default | Description |
|:-------|:--------|:------------|
| `@tiling_revamped_auto_apply` | `1` | Reapply layout when panes are added or removed |
| `@tiling_revamped_enabled` | (empty) | Window option that overrides `@tiling_revamped_auto_apply` for one window: `1` reapplies, any other value does not. Set it with `set -w` |
| `@tiling_revamped_dynamic_layout` | (empty) | Space-separated `count:layout` pairs, for example `1:monocle 2:main-vertical 3:dwindle 5:grid`. On auto-apply the pair with the greatest count not above the pane count wins |
| `@tiling_revamped_app_rules` | (empty) | Newline-separated `command:action` rules matched as globs against a new pane's command; the first match wins. Actions: `master`, `float`, `scratchpad` |
| `@tiling_revamped_default_layout` | (empty) | Auto-apply this layout on new windows |
| `@tiling_revamped_default_orientation` | `brvc` | Default BSP orientation for new windows |
| `@tiling_revamped_focus_resize` | `0` | Expand focused pane toward golden ratio on focus |
| `@tiling_revamped_focus_ratio` | `62` | Percentage of window for focused pane |
| `@tiling_revamped_focus_history` | `0` | Set to `1` to record every pane focus for the focus back and forward keys |
| `@tiling_revamped_focus_max` | `20` | Focus history entries kept per window, clamped to 2-500 |
| `@tiling_revamped_master_ratio` | `60` | Master pane percentage for main-vertical and main-horizontal |
| `@tiling_revamped_main_center_ratio` | `60` | Width percentage for main-center center pane |
| `@tiling_revamped_split_ratio` | `50` | First BSP split ratio (20-80). Useful for ultrawide monitors |
| `@tiling_revamped_resize_step` | `5` | Percentage step for resize-master grow/shrink |
| `@tiling_revamped_cycle_layouts` | `dwindle spiral grid main-vertical main-horizontal main-center monocle deck` | Layout cycle order |
| `@tiling_revamped_alt_keys` | `0` | Use Alt keybindings (`M-<key>`) instead of prefix mode |
| `@tiling_revamped_navigator` | `0` | Vim-aware navigation. Set to `1` to enable `M-h/j/k/l` with vim detection |
| `@tiling_revamped_workspaces` | `0` | Enable i3-style Alt+1-9 workspace switching |
| `@tiling_revamped_shiftnum` | `!@#$%^&*()` | Shift+number characters for international keyboards |
| `@tiling_revamped_project_dir` | (empty) | Root directory for project launcher |
| `@tiling_revamped_project_depth` | `1` | Subdirectory depth for project search |
| `@tiling_revamped_scratch_width` | `80%` | Scratchpad popup width |
| `@tiling_revamped_scratch_height` | `75%` | Scratchpad popup height |
| `@tiling_revamped_pick_width` | `60%` | Layout picker popup width |
| `@tiling_revamped_pick_height` | `40%` | Layout picker popup height |
| `@tiling_revamped_pick_preview_width` | `60%` | Layout picker preview panel width |
| `@tiling_revamped_key_pick_layout_alt` | (empty) | Bind `M-<key>` in the root table to the layout picker; inside vim or fzf the key passes through |
| `@tiling_revamped_jump_width` | `70%` | Pane jumper popup width |
| `@tiling_revamped_jump_height` | `60%` | Pane jumper popup height |
| `@tiling_revamped_jump_preview_width` | `60%` | Pane jumper preview panel width |
| `@tiling_revamped_smart_borders` | `0` | Hide pane borders while a window holds a single pane |
| `@tiling_revamped_border_status` | `top` | Border status restored when a second pane appears |
| `@tiling_revamped_help_width` | `50%` | Help overlay popup width |
| `@tiling_revamped_help_height` | `60%` | Help overlay popup height |
| `@tiling_revamped_enable_logging` | `0` | Write debug logs to `~/.tmux/tiling-revamped-logs/tiling-revamped.log` |

### Internal state

The plugin manages these options itself. Do not set them, except presets, which may also be written by hand in the same format.

| Option | Holds |
|:-------|:------|
| `@tiling_revamped_bindings` | One line per feature with the key it holds after conflict resolution, read by the help overlay |
| `@tiling_revamped_last_window` | The window most recently left, for the workspace back-and-forth key |
| `@tiling_revamped_layout_redo` | Window option: the redo stack of `layout:flags` entries that undo left behind |
| `@tiling_revamped_monocle_prev_layout` | Window option: the layout restored when monocle is toggled off |
| `@tiling_revamped_focus_stack` | Window option: focused pane ids, oldest to newest, for focus history |
| `@tiling_revamped_focus_pos` | Window option: the cursor into the focus stack |
| `@tiling_revamped_focus_nav` | Window option: `1` while a focus back or forward move is in flight, so that focus is not recorded |
| `@tiling_revamped_float` | Pane option: `1` on a pane an app rule tagged with `float` |
| `@tiling_revamped_scratchpad` | Pane option: `1` on a pane an app rule tagged with `scratchpad` |
| `@tiling_revamped_preset_<name>` | A preset saved by `preset save <name>` as `layout:flags:ratio`, for example `@tiling_revamped_preset_dev` holding `dwindle:brvc:60` |

### Custom Keybindings

```tmux
set -g @tiling_revamped_key_dwindle         "M-D"
set -g @tiling_revamped_key_spiral          "M-S"
set -g @tiling_revamped_key_main_vertical   "M-V"
set -g @tiling_revamped_key_main_horizontal "M-H"
set -g @tiling_revamped_key_balance         "M-B"
set -g @tiling_revamped_key_equalize        "M-E"
set -g @tiling_revamped_key_promote         "M-M"
set -g @tiling_revamped_key_rotate          "M-R"
set -g @tiling_revamped_key_flip            "M-F"
set -g @tiling_revamped_key_circulate       "M-C"
set -g @tiling_revamped_key_autotile        "M-A"
set -g @tiling_revamped_key_cycle           "M-O"
set -g @tiling_revamped_key_master_grow     "M-G"
set -g @tiling_revamped_key_master_shrink   "M-X"
set -g @tiling_revamped_key_sync            "M-Y"
set -g @tiling_revamped_key_mark            "M-K"
set -g @tiling_revamped_key_jump            "M-J"
set -g @tiling_revamped_key_scratchpad      "M-T"
set -g @tiling_revamped_key_pick_layout     "M-L"
set -g @tiling_revamped_key_undo            "M-U"
set -g @tiling_revamped_key_redo            "M-Z"
set -g @tiling_revamped_key_help            "M-I"
set -g @tiling_revamped_key_swap_biggest    "M-W"
set -g @tiling_revamped_key_back_and_forth  "Tab"
set -g @tiling_revamped_key_pane_jump       "M-Q"
set -g @tiling_revamped_key_focus_back      "M-P"
set -g @tiling_revamped_key_focus_forward   "M-N"
set -g @tiling_revamped_key_project         ""

# Report a key that two features both resolve to (1 = message on start)
set -g @tiling_revamped_warn_conflicts      "1"

# Directional swap (disabled by default, set keys to enable)
set -g @tiling_revamped_key_swap_up    ""
set -g @tiling_revamped_key_swap_down  ""
set -g @tiling_revamped_key_swap_left  ""
set -g @tiling_revamped_key_swap_right ""
```

Set any key to `""` (empty string) to disable that binding entirely.

### Avoiding Key Conflicts in Prefix Mode

No default replaces a stock tmux binding: stock tmux binds no `M-` plus
uppercase letter. Before 3.0.0 the defaults took `d`, `D`, `m`, `M`, `.`, `,`,
`-`, `o`, `p`, `r`, `=`, `?`, `[`, `]` and `g` from tmux. To get one back as the
old tiling key, set its option, for example
`set -g @tiling_revamped_key_dwindle "d"`, and the stock action on that key is
replaced again.

### Layout Picker

Interactive fzf-based layout picker with ASCII diagram previews.

```
┌──────────────────────────────────────────────────────────────┐
│ Select layout:                                               │
│                        │ Dwindle Layout (4 panes)            │
│   > dwindle            │ ┌──────────┬──────────┐             │
│     spiral             │ │          │    2     │             │
│     grid               │ │    1     ├─────┬────┤             │
│     main-vertical      │ │          │  3  │ 4  │             │
│     main-horizontal    │ └──────────┴─────┴────┘             │
│     main-center        │ BSP cascade toward corner           │
│     monocle            │                                     │
│     deck               │                                     │
│                        │                                     │
│  Current: dwindle                                            │
└──────────────────────────────────────────────────────────────┘
```

The picker shows ASCII diagrams in a preview panel on the right side. Each layout displays a representative configuration. The current layout is shown in the header.

Requirements: fzf. Release 0.53.0 or newer opens the picker with `fzf --tmux`; an older fzf runs inside a `display-popup`.

### Layout Cycling

```
dwindle --> spiral --> grid
  ^                     |
  |    main-vertical <--+
  |         |
  |    main-horizontal
  |         |
  |    main-center
  |         |
  |    monocle
  |         |
  +--- deck +
```

### BSP Orientation Flags

A 4-character string controlling how the BSP tree cascades. Each character is one binary choice.

| Position | Values | Meaning |
|:---------|:-------|:--------|
| 1 | `t` / `b` | Top or bottom corner |
| 2 | `l` / `r` | Left or right corner |
| 3 | `h` / `v` | Horizontal or vertical first split |
| 4 | `c` / `s` | Corner (dwindle) or spiral trajectory |

Default: `brvc` (bottom-right, vertical, corner).

### Status Line

The active layout name is stored in the `@tiling_revamped_layout` window option, so the raw name drops straight into the status line:

```tmux
set -g status-right "#{@tiling_revamped_layout} | %H:%M"
```

For an icon plus the name, call the `status` command, which maps each layout to a glyph:

```tmux
set -g status-right "#(~/.tmux/plugins/tmux-tiling-revamped/src/tiling.sh status) | %H:%M"
```

The glyph map covers all eight layouts. An unset layout prints nothing, and an unknown name falls back to the bare name.

### Help Overlay

Press `M-I` to open a popup listing the layout, pane, mark, scratchpad, undo, pane jumper and focus-history bindings, each with the key it holds after conflict resolution. The popup does not list the workspace, navigator, directional swap or project launcher keys. The overlay needs tmux 3.2 or newer for `display-popup`; on older tmux it prints a short message instead.

## CLI

The dispatcher at `src/tiling.sh` accepts direct commands for scripting and custom bindings.

```bash
# Layouts
./src/tiling.sh layout dwindle brvc
./src/tiling.sh layout spiral
./src/tiling.sh layout grid
./src/tiling.sh layout main-center
./src/tiling.sh layout main-vertical
./src/tiling.sh layout main-horizontal
./src/tiling.sh layout monocle
./src/tiling.sh layout deck

# Operations
./src/tiling.sh balance
./src/tiling.sh equalize
./src/tiling.sh rotate 180
./src/tiling.sh flip v
./src/tiling.sh promote
./src/tiling.sh circulate prev
./src/tiling.sh autosplit
./src/tiling.sh focus-resize
./src/tiling.sh resize-master grow
./src/tiling.sh sync
./src/tiling.sh swap R
./src/tiling.sh swap-pick
./src/tiling.sh pick
./src/tiling.sh cycle next
./src/tiling.sh undo
./src/tiling.sh redo
./src/tiling.sh swap-biggest
./src/tiling.sh smart-borders

# Features
./src/tiling.sh mark editor
./src/tiling.sh jump editor
./src/tiling.sh scratchpad htop
./src/tiling.sh preset save dev
./src/tiling.sh preset apply dev
./src/tiling.sh workspace 3
./src/tiling.sh move-to-workspace 5
./src/tiling.sh back-and-forth
./src/tiling.sh project

# Diagnostics
./src/tiling.sh info
./src/tiling.sh status
./src/tiling.sh help-overlay
./src/tiling.sh doctor
./src/tiling.sh validate fix
./src/tiling.sh restore-layouts
./src/tiling.sh help
```

## How It Works

The core BSP algorithm computes a tmux custom layout string mathematically, then applies it in a single `select-layout` call.

**Step 1: Build.** `_bsp_build()` recursively divides the window into a binary tree. At each depth, the orientation flags determine the split direction. At depth 0, the configurable `split_ratio` controls the first division. The output is a tmux layout string:

```
200x50,0,0{100x50,0,0,0,100x50,101,0[100x24,101,0,1,100x25,101,25{50x25,101,25,2,49x25,152,25,3}]}
```

**Step 2: Checksum.** `_layout_checksum()` computes the CRC-16 prefix that tmux requires.

**Step 3: Apply.** `select-layout <checksum>,<layout_body>` positions all panes in one call. For spiral layouts, `_bsp_fix_pane_order()` swaps panes to the correct BSP depth positions.

State is stored in tmux user options:

| Option | Scope | Purpose |
|:-------|:------|:--------|
| `@tiling_revamped_layout` | window | Current layout name |
| `@tiling_revamped_orientation` | window | BSP orientation flags |
| `@tiling_revamped_layout_history` | window | Undo stack (pipe-separated) |
| `@tiling_revamped_applying` | window | Recursion guard: the second a layout started applying, ignored after 10 seconds |
| `@tiling_revamped_mark` | pane | Mark name |
| `@tiling_revamped_marks` | global | Mark index |

<details>
<summary><strong>Project structure</strong></summary>

```
tmux-tiling-revamped.tmux     # TPM entry point: keybindings, hooks, version gates
src/
  tiling.sh                   # Command dispatcher with help text
  lib/
    layouts/
      dwindle.sh              # BSP dwindle + shared _apply_bsp_layout
      spiral.sh               # BSP spiral (delegates to dwindle)
      grid.sh                 # Even grid via tmux tiled
      main-center.sh          # Balanced center pane with side columns
      main-vertical.sh        # Master left, stack right
      main-horizontal.sh      # Master top, stack bottom
      monocle.sh              # Zoom toggle
      deck.sh                 # Full-height equal-width cards
    operations/
      balance.sh              # Equalize sizes within topology
      equalize.sh             # Force even distribution
      rotate.sh               # Rotate orientation 90/180/270
      flip.sh                 # Mirror horizontally or vertically
      promote.sh              # Swap focused pane with master
      circulate.sh            # Shift pane positions
      autosplit.sh            # Smart split along longest axis
      focus-resize.sh         # Golden ratio resize on focus
      resize-master.sh        # Grow or shrink master pane
      sync.sh                 # Toggle synchronize-panes
      swap-direction.sh       # Swap with directional neighbor
      swap-pick.sh            # Swap with fzf-selected pane
      pick-layout.sh          # fzf layout picker with previews
      undo-layout.sh          # Layout history and undo
      validate.sh             # Layout metadata validation
      info.sh                 # Current state display
      doctor.sh               # Environment health check
    features/
      marks.sh                # Named pane labels with fzf jump
      scratchpad.sh           # Persistent popup sessions
      presets.sh              # Save and restore layout configs
      cycle.sh                # Step through layout list
      workspaces.sh           # i3-style window switching
      project-launcher.sh     # fzf project directory opener
      resurrect.sh            # tmux-resurrect layout restore
    tmux/
      tmux-ops.sh             # Get/set tmux options
      tmux-config.sh          # Option helpers, reapply helper
    utils/
      constants.sh            # Option names and defaults
      error-logger.sh         # Rotating log file
      has-command.sh           # Command existence check
      picker.sh               # fzf --tmux version gate and popup fallback
test/
  helpers.bash                # Shared mock tmux for unit tests
  helpers_local.bash          # Tiling mocks and source guard resets
  tmux_helpers.bash           # Shared real tmux server for integration tests
  tmux_helpers_local.bash     # Pane and layout assertions
  integration.bats            # End-to-end scenarios
  balance.bats                # Balance invariant tests
  docs.bats                   # README options are read by the code
  lib/                        # Unit tests mirroring src/lib/
```

</details>

## Development

| Command | Description |
|:--------|:------------|
| `make test` | Run the full bats suite |
| `make test-unit` | Run unit tests only |
| `make lint` | ShellCheck all shell files |
| `make clean` | Remove temp test artifacts |
| `bats --recursive test/` | Run every test recursively |

## License

[MIT](LICENSE)

<!-- family:begin -->

## The tmux-revamped family

This plugin is one member of the tmux-revamped family. Every member carries the
same contract in [`FAMILY.md`](FAMILY.md), the same tooling under `family/`, and
the same shared library, all held byte-identical by a checksum manifest. They are
built to be installed together: no member claims a key or a tmux option that
another member claims.

A defect found in one member is hunted across all of them before the fix is
called done. That obligation is written into the contract rather than left to
memory, and `family/bin/sweep` is how it is discharged.

| Member | What it does |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | Edit your tmux config, save, and watch it reload itself, no key, no command |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | Battery status for your tmux status bar, without ever blocking the status render |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | Every connected Bluetooth device and its battery in your tmux status bar, without blocking the render |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPU load, temperature, and frequency in your tmux status bar, without ever blocking the render |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | Disk usage for your tmux status bar, without ever blocking the status render |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | Fuzzy-grab any URL, path, or word off the screen and paste it, pure shell, no Python |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | Jump to any session, window, or pane, or kill it, from one fzf popup |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | Git repository status in your tmux status bar, without ever blocking the render |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | GPU load, temperature, frequency, and memory for your tmux status bar |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | Current Kubernetes context and namespace in your tmux status bar, async, kubectl-free, never blocking |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | Launch any TUI app in a popup or a window, scoped to the current pane's directory, with one configurable bindi |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Standard pane and window management bindings for tmux, version aware, vim friendly, and fully configurable |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | Save, auto-save, and restore your whole tmux environment, one plugin, no status-line tricks |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | A template for building non-blocking tmux status plugins |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | A Pomodoro timer in your tmux status bar, with zero temp files: all state lives in tmux options |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM usage for your tmux status bar, without ever blocking the status render |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | Drag a window tab on the status bar with the mouse to move that window |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Mouse wheel that does the right thing: scroll the app directly, copy-mode everywhere else. No app names to con |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults that normalize behavior across every tmux version, OS, and terminal, without clobbering |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | **this plugin**, BSP tiling window management for tmux. Eight layouts, nineteen operations, zero dependencies |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local clock and world clocks in your tmux status bar, without ever blocking the render |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather in your tmux status bar, fetched in the background so the render never waits on the network |

### Checking an installation

With every member on disk, one command reports any conflict between them:

```sh
family/bin/doctor --live
```

It reads each member and the running tmux server, and reports duplicate keys,
duplicate status placeholders, options outside the naming grammar, and any
member whose contract version has fallen behind.

<!-- family:end -->
