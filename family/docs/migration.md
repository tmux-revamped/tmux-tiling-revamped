# Migrating to the reallocated keys

Every default key moved so that installing the whole family produces no
conflict. Two things changed.

Each plugin now binds **one** key by default, its primary action or its menu.
Every other action it can perform is still there and still configurable, but it
ships unbound. Nothing decides for you which twelve keys a picker deserves.

`tmux-tiling-revamped` is the exception, because a window manager needs a range.
It owns every `M-` plus an uppercase letter and takes nothing else.

## The new defaults

| Plugin | Key | Action |
|---|---|---|
| `tmux-launcher-revamped` | `M-a` | app launcher menu |
| `tmux-battery-revamped` | `M-b` | detail popup |
| `tmux-cpu-revamped` | `M-c` | detail popup |
| `tmux-disk-revamped` | `M-d` | detail popup |
| `tmux-network-revamped` | `M-e` | detail popup, reserved until the plugin has one |
| `tmux-fzf-revamped` | `M-f` | picker menu |
| `tmux-gpu-revamped` | `M-g` | detail popup |
| `tmux-bluetooth-revamped` | `M-h` | detail popup, reserved until the plugin has one |
| `tmux-kube-revamped` | `M-k` | context menu |
| `tmux-logging-revamped` | `M-l` | logging menu |
| `tmux-music-revamped` | `M-m` | music menu |
| `tmux-ram-revamped` | `M-r` | detail popup |
| `tmux-pomodoro-revamped` | `M-s` | start or stop |
| `tmux-time-revamped` | `M-t` | world clock menu |
| `tmux-weather-revamped` | `M-w` | forecast popup |
| `tmux-git-revamped` | `M-v` | git menu |
| `tmux-extract-revamped` | `M-x` | extract from the screen |
| `tmux-persist-revamped` | `C-s`, `C-r` | save, restore |

## Every old default and where it went

Each row is a prefix-table key unless it says otherwise. "Unbound" means the
action still exists and binds as soon as its option is set, so setting the
option to the old key restores exactly what you had.

| Plugin | Action | Old default | New default | Option |
|---|---|---|---|---|
| `tmux-disk-revamped` | detail popup | unbound | `M-d` | `@disk_revamped_popup_key` |
| `tmux-gpu-revamped` | detail popup | unbound | `M-g` | `@gpu_revamped_popup_key` |
| `tmux-weather-revamped` | forecast popup | unbound | `M-w` | `@tmux-weather-popup-key` |
| `tmux-ram-revamped` | detail popup | `M` | `M-r` | `@ram_revamped_popup_key` |
| `tmux-time-revamped` | world clock menu | `T` | `M-t` | `@time_revamped_menu_key` |
| `tmux-kube-revamped` | context menu | unbound | `M-k` | `@kube_revamped_menu_context_key` |
| `tmux-launcher-revamped` | app launcher menu | unbound | `M-a` | `@launcher_menu_key` |
| `tmux-launcher-revamped` | lazygit | `C-g` | unbound | `@launcher_lazygit_key` |
| `tmux-launcher-revamped` | yazi | `C-y` | unbound | `@launcher_yazi_key` |
| `tmux-logging-revamped` | logging menu | `M-m` | `M-l` | `@logging_revamped_menu_key` |
| `tmux-logging-revamped` | toggle logging | `P` | unbound | `@logging_revamped_toggle_key` |
| `tmux-logging-revamped` | save history | `M-p` | unbound | `@logging_revamped_save_key` |
| `tmux-logging-revamped` | screenshot | `M-P` | unbound | `@logging_revamped_screenshot_key` |
| `tmux-logging-revamped` | label | `M-n` | unbound | `@logging_revamped_label_key` |
| `tmux-logging-revamped` | window log | `M-w` | unbound | `@logging_revamped_window_key` |
| `tmux-logging-revamped` | clear | `M-c` | unbound | `@logging_revamped_clear_key` |
| `tmux-logging-revamped` | tail | `M-t` | unbound | `@logging_revamped_tail_key` |
| `tmux-logging-revamped` | search | `M-f` | unbound | `@logging_revamped_search_key` |
| `tmux-pomodoro-revamped` | start or stop | `p` | `M-s` | `@pomodoro_revamped_toggle_key` |
| `tmux-pomodoro-revamped` | cancel | `P` | unbound | `@pomodoro_revamped_cancel_key` |
| `tmux-pomodoro-revamped` | skip | `_` | unbound | `@pomodoro_revamped_skip_key` |
| `tmux-pomodoro-revamped` | restart | `R` | unbound | `@pomodoro_revamped_restart_key` |
| `tmux-pomodoro-revamped` | menu | `o` | unbound | `@pomodoro_revamped_menu_key` |
| `tmux-pomodoro-revamped` | help | `?` | unbound | `@pomodoro_revamped_help_key` |
| `tmux-music-revamped` | music menu | none | `M-m` | `@music_revamped_menu_key` |
| `tmux-music-revamped` | play or pause | `M-p` | unbound | `@music_revamped_playpause_key` |
| `tmux-music-revamped` | next track | `M-n` | unbound | `@music_revamped_next_key` |
| `tmux-music-revamped` | previous track | `M-b` | unbound | `@music_revamped_prev_key` |
| `tmux-sensible-revamped` | reload the config | `R` | unbound | `@sensible_revamped_reload_key` |
| `tmux-sensible-revamped` | last window | the prefix letter | unbound | `@sensible_revamped_last_window_key` |
| `tmux-scroll-revamped` | wheel routing, root `WheelUpPane` and `WheelDownPane` | on | off | `@scroll_revamped_wheel on` |
| `tmux-pain-control-revamped` | synchronize panes | `S` | unbound | `@pane_control_sync_key` |
| `tmux-pain-control-revamped` | move the window left | `<` | unbound | `@pane_control_swap_window_left_key` |
| `tmux-pain-control-revamped` | move the window right | `>` | unbound | `@pane_control_swap_window_right_key` |
| `tmux-pain-control-revamped` | move the window to a session | `.` | unbound | `@pane_control_move_window_key` |
| `tmux-pain-control-revamped` | kill the window | `&` | unbound | `@pane_control_kill_window_key` |
| `tmux-pain-control-revamped` | even-horizontal layout | `E` | unbound | `@pane_control_layout_even_h_key` |
| `tmux-pain-control-revamped` | even-vertical layout | `V` | unbound | `@pane_control_layout_even_v_key` |
| `tmux-pain-control-revamped` | main-vertical layout | `B` | unbound | `@pane_control_layout_main_v_key` |
| `tmux-pain-control-revamped` | respawn the pane | `R` | unbound | `@pane_control_respawn_key` |
| `tmux-pain-control-revamped` | capture the scrollback | `C` | unbound | `@pane_control_capture_key` |
| `tmux-pain-control-revamped` | name the pane | `P` | unbound | `@pane_control_pane_name_key` |
| `tmux-pain-control-revamped` | scratch popup | `g` | unbound | `@pane_control_scratch_key` |
| `tmux-extract-revamped` | picker | `Tab` | `M-x` | `@extract_revamped_key` |
| `tmux-tiling-revamped` | autotile | `C-d` | `M-A` | `@tiling_revamped_key_autotile` |
| `tmux-tiling-revamped` | balance | `b` | `M-B` | `@tiling_revamped_key_balance` |
| `tmux-tiling-revamped` | circulate | `C-r` | `M-C` | `@tiling_revamped_key_circulate` |
| `tmux-tiling-revamped` | dwindle | `d` | `M-D` | `@tiling_revamped_key_dwindle` |
| `tmux-tiling-revamped` | equalize | `B` | `M-E` | `@tiling_revamped_key_equalize` |
| `tmux-tiling-revamped` | flip | `,` | `M-F` | `@tiling_revamped_key_flip` |
| `tmux-tiling-revamped` | grow the master pane | `+` | `M-G` | `@tiling_revamped_key_master_grow` |
| `tmux-tiling-revamped` | main-horizontal | `V` | `M-H` | `@tiling_revamped_key_main_horizontal` |
| `tmux-tiling-revamped` | help overlay | `?` | `M-I` | `@tiling_revamped_key_help` |
| `tmux-tiling-revamped` | jump to a marked pane | `j` | `M-J` | `@tiling_revamped_key_jump` |
| `tmux-tiling-revamped` | mark the pane | `M` | `M-K` | `@tiling_revamped_key_mark` |
| `tmux-tiling-revamped` | layout picker | `p` | `M-L` | `@tiling_revamped_key_pick_layout` |
| `tmux-tiling-revamped` | promote to master | `m` | `M-M` | `@tiling_revamped_key_promote` |
| `tmux-tiling-revamped` | focus forward | `]` | `M-N` | `@tiling_revamped_key_focus_forward` |
| `tmux-tiling-revamped` | cycle layouts | `o` | `M-O` | `@tiling_revamped_key_cycle` |
| `tmux-tiling-revamped` | focus back | `[` | `M-P` | `@tiling_revamped_key_focus_back` |
| `tmux-tiling-revamped` | jump to any pane | `P` | `M-Q` | `@tiling_revamped_key_pane_jump` |
| `tmux-tiling-revamped` | rotate | `.` | `M-R` | `@tiling_revamped_key_rotate` |
| `tmux-tiling-revamped` | spiral | `D` | `M-S` | `@tiling_revamped_key_spiral` |
| `tmux-tiling-revamped` | scratchpad | `g` | `M-T` | `@tiling_revamped_key_scratchpad` |
| `tmux-tiling-revamped` | undo | `u` | `M-U` | `@tiling_revamped_key_undo` |
| `tmux-tiling-revamped` | main-vertical | `v` | `M-V` | `@tiling_revamped_key_main_vertical` |
| `tmux-tiling-revamped` | swap with the biggest pane | `=` | `M-W` | `@tiling_revamped_key_swap_biggest` |
| `tmux-tiling-revamped` | shrink the master pane | `-` | `M-X` | `@tiling_revamped_key_master_shrink` |
| `tmux-tiling-revamped` | synchronize panes | `S` | `M-Y` | `@tiling_revamped_key_sync` |
| `tmux-tiling-revamped` | redo | `r` | `M-Z` | `@tiling_revamped_key_redo` |

Plugins with no row kept their defaults: battery `M-b`, cpu `M-c`, fzf `M-f`, git `M-v`, persist `C-s` and `C-r`, reorder's status-line
mouse gestures, and pain-control's navigation, resize, split, `c`, `@`, `!`,
`{`, `}`, `+`, `m` and `=` keys. Sensible keeps `C-n` and `C-p`. Autoreload,
bluetooth, network and the template bind nothing.

## Keeping what you had

Set the option and the old key comes back:

```tmux
set -g @time_revamped_menu_key        T
set -g @launcher_lazygit_key          C-g
set -g @pane_control_sync_key         S
set -g @tiling_revamped_key_dwindle   d
set -g @scroll_revamped_wheel         on
```

An opt-in action stays unbound while its option is empty. A primary key falls
back to its default when its option is empty, so set it to `off` to unbind it.
A tiling key option set to the empty string disables that binding.

## Checking your own config

```sh
family/bin/live-keys --members-dir ..
```

It loads every member into a throwaway tmux server and reports any key claimed
twice, and any key taken from tmux by a plugin that has not declared it. It
exits non-zero while either is true.
