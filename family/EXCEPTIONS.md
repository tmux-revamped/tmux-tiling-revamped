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

### tmux-tiling-revamped: test/lib/tmux/tmux-ops.bats

- **Class:** owned
- **Reason:** the shared test drives a file-backed mock tmux that stores and
  reads options back. This member's harness mocks tmux as a case statement over
  MOCK_ variables with no option store, so the four round-trip cases cannot
  pass against it. The member already covers the same functions through its own
  test, which is written for its harness.
- **Alternative:** teaching the case-statement mock to store options was
  rejected for now because 775 tests depend on its current behaviour and the
  change is larger than the coverage it would buy.
- **Risk:** the two tests can drift, so a change to the shared tmux-ops could be
  covered in 23 members and not here.
- **Retire when:** this member adopts the file-backed mock, which is the same
  work as unifying the test harnesses across the family.
