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

## Why this is not yet applied

A conflict-free allocation is easy to generate and useless if it is generated.
Running the obvious greedy assignment over the measured data produces 32 moves
that resolve every clash and read like `M-i` for the battery popup and `M-a` for
grow-the-master-pane. That is worse for a daily driver than the conflicts it
fixes, because a key nobody can remember is a key nobody uses.

The allocation is therefore assigned by hand, one member at a time, with the
mnemonic recorded. Until that is done this file states the policy and the
measurement, and `family/bin/live-keys` keeps reporting the 26 clashes so the
gap stays visible instead of being quietly rounded off.

## Allocation

One row per action, filled in as each member is allocated.

| Member | Action | Key | Tier | Note |
|---|---|---|---|---|
| | | | | |
