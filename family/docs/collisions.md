# Family Collisions

Measured by `family/bin/live-keys` on 2026-09-23: a real tmux server, every member
loaded in declared order, each key attributed by diffing the binding table after
that member ran. This supersedes the earlier static scan, which under-counted
because it could not see a plugin replacing a binding that already existed.

## Summary

| Category | Keys |
|---|---|
| Bound by tmux before any plugin loads | 88 |
| Claimed by exactly one member | 47 |
| Claimed by more than one member | 26 |
| Claimed over a stock tmux binding | 42 |

## Clashes between members

| Key | Claimed by |
|---|---|
| `+` | tmux-pain-control-revamped,tmux-tiling-revamped |
| `-` | tmux-pain-control-revamped,tmux-tiling-revamped |
| `.` | tmux-pain-control-revamped,tmux-tiling-revamped |
| `=` | tmux-pain-control-revamped,tmux-tiling-revamped |
| `?` | tmux-pomodoro-revamped,tmux-tiling-revamped |
| `B` | tmux-battery-revamped,tmux-pain-control-revamped,tmux-tiling-revamped |
| `C` | tmux-cpu-revamped,tmux-fzf-revamped,tmux-pain-control-revamped |
| `C-r` | tmux-persist-revamped,tmux-tiling-revamped |
| `K` | tmux-fzf-revamped,tmux-pain-control-revamped |
| `L` | tmux-fzf-revamped,tmux-pain-control-revamped |
| `M` | tmux-fzf-revamped,tmux-ram-revamped,tmux-tiling-revamped |
| `M-n` | tmux-logging-revamped,tmux-music-revamped |
| `M-p` | tmux-logging-revamped,tmux-music-revamped |
| `P` | tmux-logging-revamped,tmux-pain-control-revamped,tmux-pomodoro-revamped,tmux-tiling-revamped |
| `R` | tmux-fzf-revamped,tmux-pain-control-revamped,tmux-pomodoro-revamped |
| `S` | tmux-pain-control-revamped,tmux-tiling-revamped |
| `T` | tmux-fzf-revamped,tmux-time-revamped |
| `V` | tmux-pain-control-revamped,tmux-tiling-revamped |
| `_` | tmux-pain-control-revamped,tmux-pomodoro-revamped |
| `b` | tmux-fzf-revamped,tmux-tiling-revamped |
| `g` | tmux-pain-control-revamped,tmux-tiling-revamped |
| `j` | tmux-pain-control-revamped,tmux-tiling-revamped |
| `k` | tmux-fzf-revamped,tmux-pain-control-revamped |
| `o` | tmux-pomodoro-revamped,tmux-tiling-revamped |
| `p` | tmux-pomodoro-revamped,tmux-tiling-revamped |
| `u` | tmux-fzf-revamped,tmux-tiling-revamped |

## Keys taken over a stock tmux binding

Some of these are deliberate. `tmux-pain-control-revamped` exists to replace the
default split and resize bindings, so its entries are the plugin doing its job.
The rest are a plugin silently removing a tmux default the user may still want.

| Key | Member |
|---|---|
| `*` | tmux-pain-control-revamped |
| `,` | tmux-tiling-revamped |
| `-` | tmux-pain-control-revamped |
| `-` | tmux-tiling-revamped |
| `.` | tmux-pain-control-revamped |
| `.` | tmux-tiling-revamped |
| `/` | tmux-fzf-revamped |
| `<` | tmux-pain-control-revamped |
| `=` | tmux-pain-control-revamped |
| `=` | tmux-tiling-revamped |
| `>` | tmux-pain-control-revamped |
| `?` | tmux-pomodoro-revamped |
| `?` | tmux-tiling-revamped |
| `C` | tmux-cpu-revamped |
| `C` | tmux-fzf-revamped |
| `C` | tmux-pain-control-revamped |
| `D` | tmux-tiling-revamped |
| `E` | tmux-pain-control-revamped |
| `L` | tmux-fzf-revamped |
| `L` | tmux-pain-control-revamped |
| `M` | tmux-fzf-revamped |
| `M` | tmux-ram-revamped |
| `M` | tmux-tiling-revamped |
| `M-n` | tmux-logging-revamped |
| `M-n` | tmux-music-revamped |
| `M-p` | tmux-logging-revamped |
| `M-p` | tmux-music-revamped |
| `[` | tmux-tiling-revamped |
| `\"` | tmux-pain-control-revamped |
| `\%` | tmux-pain-control-revamped |
| `]` | tmux-tiling-revamped |
| `c` | tmux-pain-control-revamped |
| `d` | tmux-tiling-revamped |
| `l` | tmux-pain-control-revamped |
| `m` | tmux-tiling-revamped |
| `o` | tmux-pomodoro-revamped |
| `o` | tmux-tiling-revamped |
| `p` | tmux-pomodoro-revamped |
| `p` | tmux-tiling-revamped |
| `r` | tmux-tiling-revamped |
| `s` | tmux-fzf-revamped |
| `w` | tmux-fzf-revamped |

## Reproducing

```sh
family/bin/live-keys --members-dir ..
```

It exits non-zero while any clash or undeclared steal remains, so it is the gate
the reallocation has to clear.
