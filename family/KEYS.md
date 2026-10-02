# Family Key Allocation

Every key a member binds by default is allocated here. The rule is that no two
members ship the same default, so installing all 24 produces no conflict without
the user configuring anything. A user who wants a different layout sets the
per-action option.

`family/bin/live-keys` is the gate. It loads every member into a real tmux
server and attributes each key by diffing the binding table, so it reports what
tmux ended up with rather than what the source appears to say. It exits non-zero
while any clash remains.

## Status as of 2026-09-23

The allocation is **not yet applied**. What exists today, measured rather than
read:

| Category | Keys |
|---|---|
| Bound by tmux before any plugin loads | 88 |
| Claimed by exactly one member | 47 |
| Claimed by more than one member | 26 |
| Claimed over a stock tmux binding | 42 |

The 26 clashes are listed in [`family/docs/collisions.md`](docs/collisions.md)
with their claimants. They are the work this document exists to finish.

## Tiers

| Tier | Free after stock tmux | Use |
|---|---|---|
| Unmodified printable | about 35 | One key per member, for its single most-used action |
| `M-` printable | about 84 | Everything else |
| `C-` letter, terminal-safe | about 14 | Only bindings that must work without releasing the modifier, which today means pane navigation |

Roughly 133 safe slots against 73 distinct keys currently claimed. The
allocation fits with room, so nothing has to be dropped.

## Rules

1. **Stock tmux keys are reserved**, except for the members named below whose
   purpose is to replace them. Every other member moves off any key tmux binds.
2. **One unmodified key per member at most**, for its most-used action.
3. **Everything else goes to the `M-` tier.** `C-` stays reserved.
4. **Mnemonic beats adjacency.** Where the mnemonic key is free, take it. Where
   it is not, record the second choice and the reason in the table, so the next
   person does not re-litigate it.
5. **The root table is opt-in.** No member binds a root-table key unless the
   user asks for it.
6. **This table is the source of truth.** A member's default and this table
   disagreeing is a build failure.

## Declared overrides

These members exist to replace tmux's own bindings, so their claims over stock
keys are the plugin doing its job rather than a collision.

| Member | Why |
|---|---|
| `tmux-pain-control-revamped` | Its entire purpose is better split, resize and pane-movement bindings than the defaults |
| `tmux-sensible-revamped` | It normalises defaults across tmux versions, which means rebinding some of them |

Any other member appearing in the steals list in
[`family/docs/collisions.md`](docs/collisions.md) is taking a tmux default the
user may still want, and moves.

## The shape

Three namespaces, chosen so a member can never reach into another's.

| Namespace | Owner | Why |
|---|---|---|
| Stock tmux keys | tmux, except the declared overriders above | A plugin that takes one removes something the user may still want |
| `M-` plus a lowercase letter | One key per member, its primary action or its menu | Stock tmux uses only `M-n`, `M-o`, `M-p` and the digits and arrows here, so the letters are free and the initial of the plugin name is almost always available |
| `M-` plus an uppercase letter | `tmux-tiling-revamped`, exclusively | It is a window manager with 22 actions and genuinely needs a range. Stock tmux binds no uppercase Meta key at all, so it gets one to itself |

Everything a member binds beyond its one key defaults to unbound and is
documented in its README as opt-in. That is the rule you get for free from the
decision that a user who wants a different layout configures it: the family
ships the smallest set that is useful, not every action it can perform.

## Allocation

### One key per member

| Member | Key | Action | Mnemonic |
|---|---|---|---|
| `tmux-launcher-revamped` | `M-a` | app launcher menu | apps |
| `tmux-battery-revamped` | `M-b` | detail popup | battery |
| `tmux-cpu-revamped` | `M-c` | detail popup | cpu |
| `tmux-disk-revamped` | `M-d` | detail popup | disk |
| `tmux-network-revamped` | `M-e` | detail popup | network, `n` is a stock tmux key |
| `tmux-fzf-revamped` | `M-f` | picker menu | fzf |
| `tmux-gpu-revamped` | `M-g` | detail popup | gpu |
| `tmux-bluetooth-revamped` | `M-h` | detail popup | bluetooth, its own initial is taken |
| `tmux-kube-revamped` | `M-k` | context menu | kube |
| `tmux-logging-revamped` | `M-l` | logging menu | logging |
| `tmux-music-revamped` | `M-m` | music menu | music |
| `tmux-ram-revamped` | `M-r` | detail popup | ram |
| `tmux-pomodoro-revamped` | `M-s` | start or stop | the timer's verb, `p` is a stock tmux key |
| `tmux-time-revamped` | `M-t` | world clock menu | time |
| `tmux-weather-revamped` | `M-w` | forecast popup | weather |
| `tmux-git-revamped` | `M-v` | git menu | version control, `g` is taken |
| `tmux-extract-revamped` | `Tab` | extract from the screen | completion, and unclaimed by tmux |
| `tmux-persist-revamped` | `C-s`, `C-r` | save, restore | save and restore, and they must work without releasing the modifier |

`tmux-autoreload-revamped`, `tmux-plugin-template`, `tmux-scroll-revamped` and
`tmux-sensible-revamped` bind no prefix key. Scroll binds the mouse wheel in the
root table, which is opt-in under rule 5.

### Reserved for tiling

`tmux-tiling-revamped` owns every `M-` plus uppercase letter. No other member
may take one, and tiling takes nothing outside it apart from the keys it is
allowed to keep because tmux does not bind them.

### Declared overriders

`tmux-pain-control-revamped` keeps its split, resize and pane-movement keys,
which replace tmux's own by design. `tmux-sensible-revamped` keeps `C-n` and
`C-p`.

## Why the table is filled in but not yet applied



A conflict-free allocation is easy to generate and useless if it is generated.
Running the obvious greedy assignment over the measured data produces 32 moves
that resolve every clash and read like `M-i` for the battery popup and `M-a` for
grow-the-master-pane. That is worse for a daily driver than the conflicts it
fixes, because a key nobody can remember is a key nobody uses.

The table above is therefore assigned by hand with the mnemonic recorded. It is
a breaking change for anyone already using these plugins, so it lands as one
coordinated major release with a migration table mapping every old key to its
new one. `family/bin/live-keys` keeps reporting the 26 clashes until then, so
the gap stays visible instead of being quietly rounded off.

