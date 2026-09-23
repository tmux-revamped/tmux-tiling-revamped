# Working in this repository

This repository is one member of the tmux-revamped family. Read [`FAMILY.md`](FAMILY.md) before changing anything. It is the contract, it is identical in all 24 members, and it overrides any habit that contradicts it.

## Before you finish a bug fix

A bug found in one member is a bug hunted in all of them. This is the rule this family exists to enforce, and the one most easily skipped, because the fix in front of you looks complete once the local test passes.

Classify the defect before closing it:

- **Shared**, meaning it lives in an `owned` file. Fix once, then `family/bin/propagate`.
- **Systemic**, meaning it lives in a pattern other members could repeat: a bash assumption, a tmux behavior, a shell idiom, an operating-system difference, an entrypoint convention, an option or key convention, or anything that was copied between members. Run `family/bin/sweep`, fix every affected member, in this session.
- **Local**, meaning it lives in this plugin's own feature code and no other member can express it. Say in the pull request why that is true.

Systemic is the default. Claiming local requires a reason, and "it looks specific to this plugin" is not one.

```
family/bin/sweep --pattern '<regex>' --label '<defect>'
family/bin/sweep --script <probe> --label '<defect>'
```

Use a probe rather than a pattern whenever the defect was found by running something, because a pattern finds the spelling and a probe finds the behavior. A member the sweep could not check is reported as not checked and fails the run. Not checked is never clean.

## Before you finish anything

```
family/bin/audit          # this member against the contract, offline
make lint                 # shellcheck, zero warnings
make test                 # full bats suite
make coverage             # the coverage floor
```

All four gate on their exit code. Read the output rather than the exit code alone when a test runner is involved, because failures print before the summary.

## Never

- Edit an `owned` file in more than one repository. Change it here, then propagate.
- Add a difference between members without recording it in `family/EXCEPTIONS.md` with a retirement condition.
- Use bash 4 syntax outside a version guard that actually stops execution. TPM runs the entrypoint through `run-shell`, so `return` at file scope is an error and does not stop anything. macOS still ships bash 3.2 as `/bin/bash`.
- Write a tmux option outside the `@<plugin>_revamped_<name>` grammar.
- Claim a key another member already claims. `family/bin/doctor` reports the collisions.

## Where things are

| Path | What it is |
|---|---|
| [`FAMILY.md`](FAMILY.md) | The contract. Ownership classes, the sweep obligation, the exception process |
| `family/OWNERSHIP` | Which files are shared and how strictly |
| `family/KEYS.md` | The key allocation policy and the tiers. The table itself is still being filled in, member by member |
| `family/docs/collisions.md` | The conflicts that exist today |
| `family/bin/` | The tooling the contract is enforced with |
