# Family Collisions

Measured by `family/bin/live-keys` on 2026-10-17, against tmux 3.8, after the
allocation in [`family/KEYS.md`](../KEYS.md) was applied: a real tmux server,
every member loaded in declared order, each key attributed by diffing the
binding table after that member ran.

## Summary

| Category | Keys |
|---|---|
| Bound by tmux before any plugin loads | 289 |
| Claimed by exactly one member | 83 |
| Claimed by more than one member | 0 |
| Claimed over a stock binding by a declared overrider or root-table member | 15 |
| Claimed over a stock binding by any other member | 0 |

## Clashes between members

None.

## Keys taken over a stock tmux binding

| Key | Member | Why it is allowed |
|---|---|---|
| `prefix:*` | tmux-pain-control-revamped | declared overrider, smart split |
| `prefix:-` | tmux-pain-control-revamped | declared overrider, split |
| `prefix:"` | tmux-pain-control-revamped | declared overrider, split |
| `prefix:%` | tmux-pain-control-revamped | declared overrider, split |
| `prefix:c` | tmux-pain-control-revamped | declared overrider, new window in the current path |
| `prefix:l` | tmux-pain-control-revamped | declared overrider, pane navigation |
| `prefix:L` | tmux-pain-control-revamped | declared overrider, resize |
| `prefix:@` | tmux-pain-control-revamped | declared overrider, join pane |
| `prefix:=` | tmux-pain-control-revamped | declared overrider, swap with the marked pane |
| `copy-mode-vi:v` | tmux-sensible-revamped | declared overrider |
| `copy-mode-vi:Enter` | tmux-sensible-revamped | declared overrider, clipboard copy |
| `copy-mode-vi:MouseDragEnd1Pane` | tmux-sensible-revamped | declared overrider, clipboard copy |
| `copy-mode:M-w` | tmux-sensible-revamped | declared overrider, clipboard copy |
| `copy-mode:MouseDragEnd1Pane` | tmux-sensible-revamped | declared overrider, clipboard copy |
| `root:MouseDown1Status` | tmux-reorder-revamped | declared root-table member, wraps the stock command |

## Reproducing

```sh
family/bin/live-keys --members-dir ..
```

It exits non-zero while any clash or undeclared steal remains, and exits 0 on
tmux 3.8.
