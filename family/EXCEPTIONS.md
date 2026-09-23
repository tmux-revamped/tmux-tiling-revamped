# Family Exceptions

A member that genuinely cannot carry a shared file records it here. This file is itself an `owned` file, so every exception is readable from every member rather than only from the one that took it.

An undeclared difference is a build failure. An exception with no retirement condition is refused.

## Format

Every entry carries all five fields.

```
### <repository>: <path>

- **Class:** owned or shaped
- **Reason:** why this member cannot carry the shared version, in the concrete case
- **Alternative:** what was tried instead and why it lost
- **Risk:** what goes wrong if this exception turns out to be a mistake
- **Retire when:** the condition that closes this exception
```

`family/bin/audit` and `family/bin/sync` parse the heading line, so the repository name and the path must match exactly.

## Active exceptions

None.

## Retired exceptions

### tmux-tiling-revamped: test/lib/tmux/tmux-ops.bats

Taken and retired on 2026-09-23. The member's mock tmux had no option store, so
the shared test's round-trip cases could not pass against it. The exception's
own retirement condition was to give that harness a store, which was done the
same day: unknown options now read and write through a file-backed store while
every existing case keeps its current behaviour. The member runs the shared
test unmodified.

The exception also taught the rule now in FAMILY.md that an exception is
recorded before a file becomes owned, never after. Recording it afterwards did
not bring back the copy propagate had already replaced.
