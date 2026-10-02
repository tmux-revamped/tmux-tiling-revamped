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
| `tmux-network-revamped` | `M-e` | detail popup |
| `tmux-fzf-revamped` | `M-f` | picker menu |
| `tmux-gpu-revamped` | `M-g` | detail popup |
| `tmux-bluetooth-revamped` | `M-h` | detail popup |
| `tmux-kube-revamped` | `M-k` | context menu |
| `tmux-logging-revamped` | `M-l` | logging menu |
| `tmux-music-revamped` | `M-m` | music menu |
| `tmux-ram-revamped` | `M-r` | detail popup |
| `tmux-pomodoro-revamped` | `M-s` | start or stop |
| `tmux-time-revamped` | `M-t` | world clock menu |
| `tmux-weather-revamped` | `M-w` | forecast popup |
| `tmux-git-revamped` | `M-v` | git menu |
| `tmux-extract-revamped` | `Tab` | extract from the screen |
| `tmux-persist-revamped` | `C-s`, `C-r` | save, restore |

## Keeping what you had

Every old key is still available. Set the option and it comes back:

```tmux
# the fzf pickers, which used to bind fifteen keys
set -g @fzf_revamped_session_key   s
set -g @fzf_revamped_window_key    w
set -g @fzf_revamped_pane_key      e

# the logging actions, which used to bind eight
set -g @logging_revamped_toggle_key M-P
set -g @logging_revamped_save_key   M-p

# any tiling action, on any key you like
set -g @tiling_revamped_key_balance b
```

Setting a key to the empty string disables that binding, which is how a plugin
gets out of your way entirely.

## Checking your own config

```sh
family/bin/live-keys --members-dir ..
```

It loads every member into a throwaway tmux server and reports any key claimed
twice, and any key taken from tmux by a plugin that has not declared it. It
exits non-zero while either is true.
