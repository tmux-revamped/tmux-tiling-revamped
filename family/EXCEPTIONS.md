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
