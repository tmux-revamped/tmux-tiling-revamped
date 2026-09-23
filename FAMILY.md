# The tmux-revamped Family

This repository is one member of the tmux-revamped family. Every member carries an identical copy of this document and of the `family/` directory beside it. There is no central repository: the contract lives in all of them at once, and tooling in every member keeps the copies identical.

This document is the contract. It states what a member must have, which files are shared, how a shared change reaches every member, and how a member proves it is current.

## Why there is no central repository

Every plugin is installed by cloning its own repository, so the distribution channel has no room for a shared dependency. A submodule does not survive that clone and is absent entirely from a source archive. A package manager cannot be assumed present. A central repository holding the contract would be one more thing that can be unreachable, out of date, or forgotten.

So the contract is replicated. The cost of replication is drift, and drift is what the tooling in `family/` exists to remove.

## Ownership classes

Every file in a member belongs to exactly one class. The machine-readable assignment is [`family/OWNERSHIP`](family/OWNERSHIP); this table is the explanation.

| Class | Rule | Enforced by |
|---|---|---|
| `owned` | Byte-identical in every member. A local edit is a build failure | `family/bin/audit` against `family/CHECKSUMS`, and `family/bin/sync` against the other members |
| `shaped` | Same structure and section order in every member, content specific to the plugin | Structural checks in `family/bin/audit` |
| `free` | The plugin itself. No family constraint | Nothing. This is the default for any path not listed |

A path not named in [`family/OWNERSHIP`](family/OWNERSHIP) is `free`. Ownership is opt-in, so a file becomes shared by a deliberate act.

## What every member must have

| Requirement | Detail |
|---|---|
| This contract | `FAMILY.md` at the repository root, `owned` |
| The family tooling | `family/`, `owned` |
| The shared library | `src/lib/core/`, `owned` |
| A manifest | `manifest.json` at the root, `shaped`, declaring every option, key, status placeholder and external command |
| The pipeline | The workflow set under `.github/workflows/`, `owned` |
| Release automation | semantic-release driven by conventional commits. No hand-edited version |
| Tests | bats suite reaching 100% line coverage on Linux and macOS, with every exclusion carrying a reason |
| Platforms | Ubuntu x86-64, Ubuntu arm64, macOS Intel, macOS Apple Silicon, each on the newest generally available image |
| Documentation | `README.md`, `shaped`, with the option, key, placeholder and dependency tables generated from the manifest |
| A changelog | `CHANGELOG.md`, `shaped`, in the format semantic-release generates |
| A licence | `LICENSE` |

Some of these are reached over the course of the program rather than on the day this document lands. [`family/OWNERSHIP`](family/OWNERSHIP) names what is enforced today, and grows as each requirement becomes true in every member. A requirement listed here and absent from `OWNERSHIP` is a target, not yet a gate.

## The contract version

[`family/VERSION`](family/VERSION) holds a single integer. It increases whenever an `owned` file changes. A member whose version is behind another member's is out of date by definition, which is what makes falling behind detectable without comparing every file first.

## Keeping members in step

Three checks, at three different moments, because a check that only runs during review cannot catch a divergence that was committed before it existed.

| When | Command | What it catches |
|---|---|---|
| Every pull request, offline | `family/bin/audit` | A local edit to an `owned` file, or a `shaped` file that broke its structure |
| Weekly, in every member | `family/bin/sync --check` | A member whose `owned` files or contract version differ from the others |
| When something shared improves | `family/bin/propagate` | Nothing. This is how a change reaches all members at once |

The weekly check runs in every member rather than in one place. A divergence is therefore reported from both sides, and no single vantage point has to stay healthy for the family to notice.

## How to change a shared file

Never edit an `owned` file in more than one repository.

1. Make the change in one member.
2. Run `family/bin/propagate`. It applies the change to every member, increments `family/VERSION`, regenerates `family/CHECKSUMS`, and opens one pull request per repository under a shared branch name.
3. Review and merge the 24 pull requests.

Running `propagate` twice against the same change does nothing the second time.

## When a member must differ

Record it in [`family/EXCEPTIONS.md`](family/EXCEPTIONS.md), naming the repository, the file, the reason, and the condition that would retire the exception. That file is itself `owned`, so an exception taken by one member is readable from every member.

An undeclared difference is a build failure. An exception with no retirement condition is a permanent change to the contract made by one person in one afternoon, so it is refused.

## Improving one member improves the family

When work on one plugin produces something the others would benefit from, the work is not finished when that plugin is better. Decide whether the improvement is family-wide. If it is, move it into an `owned` file and propagate it in the same session. If it is not, say why in the pull request.

This is the point of the whole arrangement. A member that gets better alone leaves the others behind, and the family is only worth having if that cannot happen quietly.

## Key bindings

**No two members may ship colliding default keys.** Every default is allocated once, by hand, across the whole family, so that a user who installs all 24 gets no conflict without configuring anything. A user who wants a different layout sets the per-action option themselves.

That rule decides defaults. It does not decide what happens when a user's own remap lands on a key another action already holds, and the two mechanisms must not be confused:

| Question | Answered by |
|---|---|
| Do two shipped defaults collide? | The allocation in `family/KEYS.md`. They must not, and `family/bin/lint-keys` fails the build if they do |
| A user remapped one action onto another's key. Now what? | The binding registry: collect every binding, write them in one pass, let the key the user set outrank the one the plugin defaulted, leave the loser unbound, and report the clash |
| A user already bound the key outside the family | The plugin leaves the user binding alone, skips its own, and records the skip |

An earlier design used the registry's precedence as the answer to the first row. It is not: precedence resolves a collision after the fact, and the rule is that the collision must not exist. The registry stays, because the second and third rows are real and nothing else answers them, but it is a safety net rather than the allocation policy.

## A bug found in one member is a bug hunted in all of them

This is a requirement, not a habit. Fixing a defect in one member and stopping there is an incomplete fix, and the pull request is not ready.

Every defect gets classified before it is closed:

| Class | Test | Obligation |
|---|---|---|
| Shared | The defect is in an `owned` file | Fix once, propagate. Every member gets the fix by construction |
| Systemic | The defect is in a pattern, an idiom, a platform assumption, or a convention that other members could plausibly repeat | Sweep every member, fix every affected one, in the same session |
| Local | The defect is in this plugin's own feature code and no other member could express it | Fix here. Record the reasoning in the pull request |

Only the third class stops at one repository, and claiming it requires saying why the others cannot be affected. "It looks specific to this plugin" is not that reason. A defect arising from bash behavior, tmux behavior, a shell idiom, an operating-system difference, a tmux entrypoint convention, an option or key convention, or anything copied between members is systemic by default.

### Discharging the obligation

```
family/bin/sweep --pattern '<regex>' --label '<what the defect is>'
family/bin/sweep --script <probe> --label '<what the defect is>'
```

A pattern sweep suits a defect recognizable by reading. A probe sweep suits one that only shows up when the code runs, which is the stronger evidence and the right choice whenever the defect was found by running something.

The sweep distinguishes three outcomes per member, and the third matters as much as the first: a member the sweep could not check is reported as not checked and fails the run. A member that was not examined is never a member that is clean.

### What the pull request must carry

- The class, named.
- For a systemic defect, the sweep command and its result.
- For a local defect, the reason no other member can express it.
- A regression test that fails without the fix. Where the defect is systemic, the test is itself systemic, so it belongs in the shared suite rather than in one member's.

### A green pipeline is not a clean sweep

Some defects cannot reach CI at all, so a sweep that only consults the pipeline
reports them as absent.

| Class | Why CI misses it | Where to look |
|---|---|---|
| A path containing a space | Runner checkout paths have no spaces. `run-shell` hands its argument to `/bin/sh`, which word-splits it, so the wrong command runs and reports 127 | A developer checkout under a directory with a space |
| bash 3.2 | Ubuntu runners carry bash 5, and the macOS jobs resolve whatever is first on `PATH` | `/bin/bash` on macOS, run directly |
| A blocking entry point | Nothing in CI reads the entry point's stdout and waits on it | Run the entry point under a command substitution and time it |
| A leaked test fixture | The run ends and the runner is destroyed | A long-lived developer machine, hours later |

When a defect belongs to one of these, run the probe locally and say so in the
pull request. Reporting a member as clean on the strength of a green pipeline
it could never have failed is the same error as not checking it.

### Worked example

The tiling entrypoint declared an associative array at file scope, above its own bash version guard. On the bash 3.2 that macOS still ships as `/bin/bash` that printed a raw usage error at load. The guard that should have caught it used `return` at file scope, which is invalid when TPM runs the file through `run-shell` instead of sourcing it, so the guard never stopped anything and the plugin bound no keys at all while appearing to load.

Neither half is tiling's feature code. One is a bash version assumption, the other is a tmux entrypoint convention, so both are systemic, and the fix was not finished until every member had been probed under `/bin/bash` and reported clean.

## Members

The authoritative list is [`family/MEMBERS`](family/MEMBERS). It is `owned`, so adding a member is a propagated change like any other.

## Tooling

| Command | Purpose |
|---|---|
| `family/bin/audit` | Verify this member against `family/CHECKSUMS` and the structural rules. Offline |
| `family/bin/checksums` | Regenerate `family/CHECKSUMS` from `family/OWNERSHIP` |
| `family/bin/sync` | Compare this member against every other. `--check` exits non-zero on divergence |
| `family/bin/propagate` | Apply a shared change to every member and open the pull requests |
| `family/bin/inventory` | Emit this member's options, keys, placeholders, commands and versions |
| `family/bin/doctor` | Report collisions and exceptions across every installed member, against a live tmux server |
| `family/bin/sweep` | Hunt a defect found in one member across every other member |

Every one of them exits non-zero on failure. Gate on the exit code, never on the output text.
