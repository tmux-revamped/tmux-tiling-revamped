# tmux-revamped: the family standard

The repositories listed in [`family/MEMBERS`](family/MEMBERS) are one family of tmux plugins, called tmux-revamped. Each one does one job inside tmux, and they look, read and behave alike, so a person who knows one already knows how to drive the others, and every member installs beside every other with no clash.

Two files carry the family, and every member implements everything both say:

- [`FAMILY.md`](FAMILY.md), this file, holds everything the members share. It is the same, byte for byte, in every member.
- [`AGENTS.md`](AGENTS.md) holds only what is exclusive to its own repository: its layout, its names, its behaviour, the rules of its own domain, its release details and its open gaps. Every member's agent guide has the same headings, in this order: Layout, Names, Behaviour, Domain rules, Release, Gaps against FAMILY.md. A rule that would serve more than one member belongs here instead.

Nothing about the family lives anywhere else, so anyone with the repositories has all of it. A coding agent's own instruction file in a member only imports the agent guide.

There is no central repository. Every plugin is installed by cloning its own repository, so the distribution channel has no room for a shared dependency: a submodule does not survive that clone, and a source archive leaves it out. The contract is replicated in every member instead, and the tooling under [`family/`](family) removes the drift that replication brings.

This file states the standard every member is held to. Where a member does not meet a rule yet, the rule still applies, and the member lists the difference under Gaps against FAMILY.md in its agent guide. That list is the family's progress tracker: it shrinks until it reads `None`, and a feature a gap still affects is never described as finished in the docs.

## How a repository joins

Copy the owned files in unchanged, write an agent guide with the same headings as the other members', follow both, allocate every default key in [`family/KEYS.md`](family/KEYS.md) first, and add the repository to [`family/MEMBERS`](family/MEMBERS) in every member in the same task. The template's `make new-member NAME=<name>` scaffolds one with every name and prefix renamed. With the members checked out side by side, this shows any drift in this file:

```sh
grep -vE '^[[:space:]]*(#|$)' family/MEMBERS | while IFS= read -r member; do
  cmp FAMILY.md "../${member}/FAMILY.md"
done
```

`family/bin/sync --check` is the full check: it compares every owned file and the contract version.

A new member also needs, in the same task, a public repository, so Actions minutes and the scheduled runs cost nothing, with Dependabot alerts on and the Renovate GitHub App, which the owner keeps installed on every repository.

A rule the owner sets for any member is written here and applied to every member, so they keep one style and one standard of quality. A rule that needs changing is changed in every member in the same task.

## Platforms

Every feature of every member works in full on Linux, x86-64 and arm64, and on macOS, Intel and Apple Silicon: each command, option, key, placeholder, popup and output behaves the same on both systems, and the Linux and macOS test legs both drive it. A tool that one platform lacks is never a reason to drop the feature there; the member uses another tool that exists there, names the dependency in `doctor`, or implements the missing piece itself. A feature that works on one platform only is a gap: it is listed under Gaps against FAMILY.md in that member's agent guide.

Windows is not a supported platform, and Homebrew on Linux is not a supported route: no member documents either, and CI tests neither.

## Commands

Every member has a command-line tool, `bin/<tool>`, where `<tool>` is the entry point's name without `.tmux`, such as `cpu-revamped`. It answers the same three commands as every other member.

| Command | Prints | Exit |
|:--------|:-------|:-----|
| `help`, `-h`, `--help` | The help page on stdout | 0 |
| `version`, `-V`, `--version` | `<tool> X.Y.Z`, then one `key: value` context line | 0 |
| `doctor` | One row per dependency | 1 only when a required one is missing |

No other spelling of these commands exists. An action is always a command, such as `persist-revamped save`, never an option. Every action the plugin binds to a key or offers in a popup is also a command, so a key, a popup and a script reach the same code. The `.tmux` entry point stays at the repository root for TPM and calls the same library.

## Help page

One plain page, in this order:

1. `<tool> - <one line saying what it does>`
2. `usage:`, one line per form, each with a short description, ending with `doctor`, `version` and `help`
3. Option sections: `options:`, or named groups when there are many
4. `environment:`, only for settings that really come from the environment
5. `tmux options:`, every `@<prefix>_revamped_<setting>` the member reads, with its default
6. `notes:`
7. `examples:`

The plain page has no colour, no emoji and no bracketed level tags. On a terminal where gum draws, the same page is turned into Markdown, each section a heading over a code block, and printed with `gum format` in the theme's help style.

## Settings

- Every setting is a tmux option named `@<prefix>_revamped_<setting>`, where `<prefix>` is the member's own, such as `cpu` or `net`, because tmux users configure plugins in `.tmux.conf`. A member reads no option outside that pattern. A renamed option keeps its old name as an alias that applies only while the new one is unset, and the changelog names both.
- The tool takes the same setting as a long option, `--<setting>`, and from the environment as `<TOOL>_<SETTING>` in capitals, with the tool's dashes written as underscores, such as `CPU_REVAMPED_INTERVAL`. The command line wins over the environment, the environment over the tmux option, and the tmux option over the default.
- `--name value` and `--name=value` both work, and `--` ends the options.
- A yes or no setting that is asked about interactively has both forms, such as `--verify` and `--no-verify`. As a tmux option it reads `1` for yes and `0` for no.
- The family's one shared setting is its look, under Terminal interface.
- No member reads a bare name such as `INTERVAL`, and none takes its internal variables from the environment: a member either assigns each one outright, or its entry point clears every inherited variable with its internal prefix before anything runs. Test-only switches follow the same rule, such as `CPU_REVAMPED_TEST_GUM`. `scripts/check-names.sh` fails lint on any other name.
- Anything required and not given is asked for when stdin is a terminal: `Label [default]: ` on stderr, up to three tries for a required value.
- Without a terminal the tool never waits on a prompt. It stops with the usage hint under Diagnostics.
- A destructive step, such as deleting a saved session, asks the person to type its name: `Type work to delete, or anything else to stop: `.
- With no arguments on a terminal, a tool with several jobs offers a menu headed `What would you like to do?`, numbered on the plain interface and a `gum choose` list where gum draws; a tool with one job asks for its inputs directly.

## Output

- Results and progress lines go to stdout. Prompts, diagnostics, and a progress line redrawn in place on a terminal go to stderr.
- A status placeholder, `#{<prefix>_<name>}`, prints its value and nothing else. A value the host has no source for renders empty, and `doctor` says which source is missing.
- Text that comes from outside the plugin, such as a process, window or song name, has every `#` doubled before tmux reads it as a format.
- Numbers are computed and printed under the C locale, so a locale with a decimal comma still prints `1.5G`.
- Before a long or destructive run, a summary block states what is about to happen. Each label carries a colon and is padded to 8 columns; continuation lines are indented 8 spaces, and the block has a blank line above and below.
- A long step shows one progress line: `<Verb> NNN%  <rate>  XmYYs left`. On a terminal it redraws in place; otherwise it prints once per 10 percent.
- The last line states the result in a full sentence, such as `Saved. 4 sessions are in work.json.`
- A message is printed as one line, and the terminal wraps it at its own width. No member breaks a message into lines itself, so a narrow window, a wide one and a pipe all get the same text, and a script reads one message per line.
- Text written ahead of time, such as the help page and the fixed lines of a summary block, keeps its lines within 80 columns. `test/width.bats` checks that `help` and `version` stay within them.
- A command whose result a script would read offers `--json`, which prints that result as one JSON object on stdout in place of the text form.

## Terminal interface

Every member draws its terminal interface with [gum](https://github.com/charmbracelet/gum), and every member looks the same. A popup is the same tool run inside `tmux display-popup`.

- gum draws only where it can: prompts when stdin and stderr are terminals, diagnostics when stderr is one, and results when stdout is one, each only when `gum` is on `PATH`. Anywhere else the plain interface runs, byte for byte, so pipes, files, scripts, `--json`, the status line and the golden transcripts never change. A terminal without gum gets the plain interface too, and `doctor` reports gum missing.
- One look for the family: a rounded header box with the tool's name, version and tagline opens the menu; `gum choose` for a menu or a choice, `--no-limit` for several, whose header names `x`, the key gum 2.0.2 marks with, and `--label-delimiter "|"` for a label that carries a value; `gum filter` for a long list or a file; `gum input` for a value, with a default shown as its placeholder and taken when the answer is empty, never prefilled with `--value`, which makes typing append to it, and `--password` for a secret; `gum write` for text, where Enter submits and Ctrl+J adds a line; `gum confirm` for yes or no; `gum spin --spinner dot` while a short step runs; a rounded summary box before a long or destructive run; a thick red danger box above the typed confirmation; a rounded table with a state cell coloured ok, warn or error; the progress line with a bar in the accent; `gum pager` for long output; log lines `INFO`, `WARN` and `ERROR` in the theme's colours, where a message whose first word is capitalized, not an acronym, continues in lowercase after the prefix; badges for a short state; and a bold closing sentence in the ok colour.
- gum's own `gum file` redraws from the top of the screen and hides its header, `gum table --print` styles the first data row as the header and cannot colour a cell, and `gum log` joins lines and breaks words at the screen's edge. No member uses them: files are picked with `gum filter`, tables come from `lib/table.awk` inside a `gum style` box, and log lines are drawn by `<prefix>_ui_log`, one line per message.
- `gum style` drops colour it reads from stdin, so coloured text is passed to it as arguments. `gum spin` draws on stdout, so a member sends it to stderr and lets it wait on the step's process, which runs in the background with its diagnostics held in a file until the spinner stops.
- The palette comes from a theme: `--theme NAME`, else `<TOOL>_THEME`, else `KODOUGU_THEME`, else the tmux option `@revamped_theme`, else `kodougu`. The themes are `kodougu`, `catppuccin-mocha`, `catppuccin-latte`, `dracula`, `nord`, `gruvbox`, `tokyo-night` and `mono`, each with an accent, ok, warning, error, muted, text and surface colour and a `gum format` style. `<TOOL>_ACCENT`, else `KODOUGU_ACCENT`, replaces only the accent with a colour such as `#CBA6F7`. An unknown theme or a malformed colour stops the tool with the bad value error. `NO_COLOR` switches every theme to `mono`.
- `lib/ui.sh` holds the themes and every drawing helper, and `lib/table.awk` the table. A member calls them and never calls gum directly from its own modules.
- `test/ui-kit.bats` calls every helper in `lib/ui.sh` directly, so each member covers the whole module whatever it draws. Tests drive the gum path with `<TOOL>_TEST_GUM=1` and `test/bin/gum`, a shim first on `PATH` in every test that records each call in `<TOOL>_TEST_GUM_LOG` and answers from `<TOOL>_TEST_GUM_ANSWERS`, one line per prompt, `<cancel>` for Escape. gum needs a terminal, so CI cannot run the real one; the screens run the real one.

## Screens

Every README shows the plugin running for real: an animated `screens/hero.gif` under the introduction, recorded inside a real tmux, and a collapsed gallery of PNG stills, one per screen, from the status line and each popup to `doctor`, help and the themes.

- [VHS](https://github.com/charmbracelet/vhs) records them from the real plugin, the real tmux and the real gum, never from mockups. `make screens` runs `screens/record.sh`, which builds fresh fixtures with `screens/prepare.sh` before each tape, starts tmux on its own socket with its own config, records the tape, cleans up with `screens/cleanup.sh`, and crops each still with `screens/finish.sh`.
- `screens/common.tape` sets one look: the Catppuccin Mocha terminal theme, JetBrainsMono Nerd Font at 24 px, 1600 px wide, with the default `kodougu` theme for the tool.
- The screens are recorded on macOS; `record.sh` names the missing tool when `vhs`, `tmux` or `magick` is absent.
- A change that alters what a screen shows records the screens again in the same commit.

## Diagnostics

| Kind | Form |
|:-----|:-----|
| Error | `<tool>: <message>` |
| Warning | `<tool>: warning: <message>` |
| Refusal before any harm | `<tool>: stopped: <reason>.` |
| Usage error | `<tool>: <problem>. run '<tool> help' for usage.` |
| Unknown command | `<tool>: unknown command 'x'. run '<tool> help' for usage.` |
| Unknown option | `<tool>: unknown option '--x'. run '<tool> help' for usage.` |
| Option without its value | `<tool>: option '--x' needs a value. run '<tool> help' for usage.` |
| Bad value | `<tool>: --x must be <rule>, got: <value>` |
| Missing input without a terminal | `<tool>: no <thing> given. run '<tool> help' for usage.` |

- A message starts in lowercase, unless it starts with a name such as `APFS` or `--interval`, and every sentence after the first does too.
- A sentence ends with a period. A `label: value` line ends with its value.
- Exit status is 0 on success and 1 on failure. An interrupt removes temporary files before the tool exits.
- A status placeholder never prints a diagnostic into the status line. It renders empty, and the error goes to the member's log and to `doctor`.

## doctor

```text
tmux               ok       /usr/bin/tmux, 3.6
gum                missing  brew install gum, or the gum release for Linux
```

Each row is `printf '%-18s %-8s %s\n'`, and where gum draws the rows form a table followed by the closing sentence: the dependency; `ok`, `missing` or `warn`; then the path when found, followed by a short note when one matters, or the remedy when not.

A row for a core tool, such as `awk`, `sed`, `od`, `tr`, `date` or `ps`, names its flavor and version after the path, so a bug report says which tools ran:

```text
awk                ok       /usr/bin/awk, bsd 20200816
sed                ok       /opt/homebrew/opt/gnu-sed/libexec/gnubin/sed, gnu 4.10
```

The flavor is `gnu`, `uutils`, `bsd`, `mawk`, `busybox` or `unknown`. It comes from the tool's own `--version` answer, then from where it is installed, then from the system it runs on. A BusyBox applet prints its usage error before the line that names BusyBox, and BusyBox `sed` answers `This is not GNU sed version 4.0`, so the answer is read from the first line that names BusyBox or says it is not GNU, and that `sed` answer reads as `busybox` with no version.

`doctor` also reports the tmux version, every source a placeholder reads and whether the host has it, the notifier under Notifications, and every default key the plugin skipped because the person had already bound it. A new dependency gets its `doctor` row, with its flavor when it is a core tool, in the same change.

## Toolsets

Every tool that can be installed in more than one version on a supported system is tested in every one of them. Every member runs on the six toolsets below, and CI runs the whole suite on each:

| Toolset | What it is |
|:--------|:-----------|
| Linux, uutils | Ubuntu's default since 25.10: uutils coreutils, with GNU sed and mawk |
| Linux, GNU | GNU coreutils and gawk |
| Linux, BusyBox | BusyBox's applets first on `PATH`: coreutils, awk, sed, grep, find and the rest |
| macOS, native | Everything macOS ships, first on `PATH`: its BSD tools, bash 3.2, zsh and the rest |
| macOS, Homebrew | Homebrew's current build of every tool macOS also ships, first on `PATH`: coreutils, findutils, gnu-sed, gawk, grep, diffutils, bash, zsh, and each member's own |
| macOS, uutils | Homebrew's uutils-coreutils, uutils-diffutils and uutils-findutils, first on `PATH` |

- tmux itself is tested at the version the current Ubuntu LTS packages and at the one Homebrew ships. A member's own dependencies are tested in every build those routes offer. A dependency that gains a new route or build gets its leg in the same change.
- A script uses only options all six accept. Where they differ, the code handles each one and a test covers it. A change that passes on one toolset only is not done.
- Any tool macOS ships that Homebrew also builds in a newer version is tested in both: the macOS native toolset runs the system's copy, and the macOS Homebrew toolset runs Homebrew's. A member that starts calling such a tool adds its formula to the Homebrew leg in CI.
- `.github/scripts/toolset.sh native`, `homebrew`, `gnu`, `uutils` or `busybox` prints the directories that put a toolset first on `PATH`; on Linux, `busybox` links BusyBox's applets other than its shells. CI uses it, and a report is reproduced by putting the reporter's toolset first: `export PATH="$(sh .github/scripts/toolset.sh gnu | paste -sd: -):$PATH"`.

## Safety

- A file is written to a temporary file beside it, then renamed over it with `mv -f`, so an interrupted run never leaves half a file. A file the person did not name is never overwritten, and a step that fails leaves the original exactly as it was.
- A command that changes or replaces a file that existed before the run first keeps the original beside it as `NAME.bak`, or the first free `NAME.bak.N` up to 99, where `NAME` is the whole file name with its extension, and never overwrites an earlier backup. A step that fails puts the copy back. A file the run itself created needs none. This is the default, and only an option the person types, such as `--no-backup`, skips it.
- Two runs that can rewrite the same file, such as two status refreshes writing one cache, take a lock first: a lock file created under `set -C`, which the shell opens exclusively, holding the run's process ID and removed when the run ends. A lock is never a `mkdir`: the uutils `mkdir` 0.10.0 that Ubuntu 26.04 ships let two processes create the same directory 82 to 98 times in 400 contended takes, where GNU `mkdir` and `set -C` gave none. A test runs ten such writers at once and checks that every write landed.
- Files are found with shell globs, never by parsing `ls` or `find` output, so any name, with spaces, brackets or a newline, passes through intact.
- An external command runs once per batch of items, never once per item.
- A plugin never touches a tmux server other than the one that loaded it, and a test never touches the person's server.
- Every external dependency works with the version the current Ubuntu LTS packages and with the current one Homebrew ships. An optional flag is detected once per run, from the tool's own `--help` or `--version`, and used only when it is there.
- A tuned default, such as a refresh interval or a cache lifetime, is chosen by measurement. A change to one records, in its commit body, a measurement that beats the current value.
- A status refresh costs no more than the release before it, measured with its child processes included, since a status plugin's cost lives in the commands it starts. A change that adds a child process to a refresh records the measurement in its commit body.

## Documentation

- A README in English, Japanese, Simplified Chinese and Hong Kong Traditional Chinese, with the same sections in the same order: Quick start, with Prerequisites, Install and Verify; Usage; the plugin's own topic sections; Portability; Development; License.
- The Hong Kong README is written Standard Chinese in Traditional characters with Hong Kong vocabulary, never colloquial Cantonese.
- The console sample at the top of every README is output copied from a real run.
- `manifest.json` declares every option, key, placeholder and command the member has. The README tables, the help page, the man page, the completions and the member's rows in the key allocation are generated from it, and a test fails when any of them disagrees with the manifest or with the code.
- A man page, `man/<tool>.1`.
- Completions for bash, zsh and fish under `completions/`.
- A new option goes into the help page, the man page and all three completions in the same commit, and a test fails when they disagree.

## Install

- TPM installs the plugin from `set -g @plugin 'tmux-revamped/<repository>'`, and every member also works when its entry point is run by hand with `run-shell`.
- `make install` puts `bin/<tool>`, its man page and its completions under `PREFIX`, `~/.local` by default.
- No member is published to Homebrew or any other package registry: a formula installs into the Homebrew prefix, which TPM never loads, so the plugin would exist twice at two versions.

## Layout and tooling

- `<name>.tmux` at the repository root is the entry point TPM runs. It is executable, and git tracks it as mode `100755`: TPM executes the file directly and discards everything it prints, so without the bit the plugin never loads and nothing reports it. TPM runs it through `run-shell`, so `return` at file scope is an error that stops nothing.
- `bin/<tool>` is the command-line entry point and sources `lib/*.sh`. There is no build step; `share/` holds data files only. `lib/state.sh` declares every global, and `lib/core.sh` holds `<TOOL>_VERSION`.
- POSIX `sh` without `local`: every global carries the member's internal prefix, and every function-scoped variable carries its function's prefix. Variables are written `${name}`.
- `shfmt -i 2` formats every script, and `make lint` fails on unformatted code.
- Release tooling is pnpm, pinned through `packageManager` in `package.json`, running semantic-release. The release job installs it with `pnpm install --frozen-lockfile` and stops on `pnpm audit --audit-level high`.
- Dependabot updates the GitHub Actions and the release tooling, and Renovate updates the runner labels, `.ruby-version` and the Gemfile, so each update arrives once. Both look for updates three times a day, at 05:00, 13:00 and 21:00 UTC. Every bot pull request merges itself once CI passes: when `ci` finishes on a pull request from a bot, `bot-merge.yml` checks that every check on that commit passed, squash-merges it at that commit with a fixed commit body, then starts `ci` on `main` with `gh workflow run`, since a merge made with `GITHUB_TOKEN` starts no workflow by itself. A bot pull request that changes an owned file updates [`family/CHECKSUMS`](family/CHECKSUMS) in the same merge, and since the bot opens the same pull request in every member, the owned file stays identical everywhere. None is merged by hand.
- Every action, `actions/*` and `github/*` included, is pinned to a full commit SHA with its version in a trailing comment, and every container image to a digest, because zizmor's default policy requires it and a tag can move. The pin check in `make lint` fails on any other reference.
- A workflow that runs on `workflow_run`, which zizmor flags, carries `# zizmor: ignore[dangerous-triggers]` only when it never runs code from a pull request with a write token: `release.yml` checks out `main`, and `bot-merge.yml` runs only `main`'s tooling, after checking that the bot changed nothing under [`family/`](family).
- These files are owned, identical in every member: [`FAMILY.md`](FAMILY.md), everything under [`family/`](family), the coding agent's instruction file, `.editorconfig`, `.yamllint.yml`, [`.shellcheckrc`](.shellcheckrc), [`.github/actionlint.yaml`](.github/actionlint.yaml), [`.github/dependabot.yml`](.github/dependabot.yml), `renovate.json`, `.github/workflows/release.yml`, `.github/workflows/bot-merge.yml`, [`.github/workflows/security.yml`](.github/workflows/security.yml), `Gemfile`, `Gemfile.lock`, `.ruby-version`, `.simplecov`, `.github/scripts/toolset.sh`, `.github/scripts/set-version.sh`, `.github/scripts/ci-state.sh`, `.github/scripts/recover.sh`, `test/ci-state.bats`, `test/recover.bats`, `lib/ui.sh`, `lib/table.awk`, the shared tmux library, `test/bin/gum`, `test/ui-kit.bats`, [`test/helpers.bash`](test/helpers.bash), [`test/tmux_helpers.bash`](test/tmux_helpers.bash), `screens/common.tape`, `screens/record.sh`, `screens/finish.sh`, `scripts/coverage-gate.py`, `scripts/bashcov-run.rb`, `scripts/bashcov-lexer.rb`, `scripts/bashcov-lexer.test.rb`, `scripts/linux-coverage.sh`, `LICENSE`, [`.github/FUNDING.yml`](.github/FUNDING.yml), [`.github/CODEOWNERS`](.github/CODEOWNERS) and the issue templates. [`family/OWNERSHIP`](family/OWNERSHIP) names the ones enforced today.
- A script that only CI or the release runs lives in `.github/scripts/`. A script that a `make` target runs lives in `scripts/`, so everything a contributor can run locally sits in one place. `make lint` checks both folders.
- No member has a pull request template, a labeler or a stale-issue workflow, because only bots open pull requests. The issue templates stay, because people who use the plugins file issues.

## Tests

- Tests live in [`test/`](test): `helpers.bash` for the shared helpers, `tmux_helpers.bash` for the private tmux server, `call.sh` to call one function, `run-matrix.sh`, which runs the suites under each shell named in `<TOOL>_TEST_SHELLS`, and `linux-container.sh`, which runs a command in an Ubuntu container. A member's own mocks and guard resets go in `test/helpers_local.bash` and `test/tmux_helpers_local.bash`, which the shared files source when present, with guard resets inside a `setup_test_environment_local` function. `<TOOL>_TEST_JOBS` runs the files of a suite in parallel through GNU parallel, while the tests inside one file run in order; `<TOOL>_TEST_IMAGE` picks the container image.
- A test that needs tmux starts its own server on its own socket, with its own config and `HOME` in a temporary directory, and kills it on teardown. A second tmux server started any other way reads the person's config and writes the person's state.
- The entry point is loaded in tests as TPM loads it, through `/bin/sh` and `run-shell`, never sourced into the test's shell.
- A file that a test file writes when it loads into a folder the whole run shares is written to a temporary file beside it and renamed into place. Test files run in parallel, and a file rewritten in place can be read empty by a test in another file.
- A test that hides a tool runs the program with `<prefix>_test_farm`, a folder of links to every program on PATH except the hidden ones. It links one PATH folder per `ln -s` call: one call per program forks thousands of times on a Homebrew Mac.
- `bats` tests drive the real tools and the real tmux, and inject faults only through small wrappers on `PATH`. A member's test harness never defines a shell function with the name of a command another test stubs on `PATH`, or a test that stubs it unsets the function first.
- Golden transcripts guard the terminal output. A test runs a whole flow, replaces the values that change between runs, such as paths, sizes and rates, and compares the result with `test/golden/<flow>.<OS>.txt`. `<TOOL>_TEST_RECORD=1` rewrites them from a fresh run, on macOS and in the container; the diff is read before it is committed.
- 100 percent bashcov line coverage, gated locally and in CI, with no exclusion. `make coverage` runs bashcov on the Mac and in the Ubuntu container and merges both before the gate, so a Linux-only branch counts locally as it does in CI, and each platform also reaches 100 percent of the lines it runs on its own. Every `case` branch runs a command, because bashcov never counts a branch that holds only `;;`. The condition of an `if`, `elif`, `while` or `until` stays on one line, because bashcov 4.0.1 never marks a backslash-continued line of a condition as run; a long command whose output is assigned with `$(...)` moves into its own function for the same reason. `scripts/bashcov-run.rb` reads the trace one record at a time and skips a damaged record, because two traced processes writing at once on macOS can splice a record, and bashcov's own reader stops at the first damaged one and leaves every traced process blocked on a full pipe. `scripts/coverage.sh` feeds bashcov a damaged record before the suite and fails if it stops reading. Before that probe it loads the gems `Gemfile.lock` names and, when one is missing, stops with a message that says to run `bundle install`. `scripts/bashcov-lexer.rb` corrects bashcov's multiline string patterns, which read a closing quote after a space, as in `'%s: '`, as the start of a string running to the next quote lines later; the corrected pattern opens a string only where the same quote character is paired before it on its line, and when bashcov rechecks the line a string closed on, the search starts after the closing quote. `scripts/coverage.sh` runs `scripts/bashcov-lexer.test.rb` before the probe and stops when bashcov still miscounts. A `} | {` line joining two brace groups never gets a trace hit, so the second group becomes a named function: `} | <function>`. A `} >file` line closing a brace group can go without a hit too, so each command redirects itself instead. No loop redirects a fixed descriptor number, as in `done 9<file`: bashcov's trace descriptor can take that number and every line of the loop drops out of coverage, so the loop reads its file by line number.
- Tests never write the member's version as a literal; they read it from `lib/core.sh`, so a release does not break them.
- A wait loop polls from milliseconds upward, never with a fixed `sleep 1`.
- Every test is three blocks, opened by the bare markers `# Arrange`, `# Act` and `# Assert`.
- A test that starts background work waits on the process IDs it collected from `$!`, never with a bare `wait`: CI sets `BATS_TEST_TIMEOUT`, and bats runs that timeout as a background watchdog in the test's own shell, so a bare `wait` blocks until the timeout ends the test. `scripts/check-names.sh` fails on a bare `wait` in [`test/`](test).

## Quality

- 100% shell script in POSIX `sh`, working under `sh`, `dash`, `bash` and `zsh` on both Linux and macOS, each combination tested in CI. A finding or a failure in any one of them blocks the change.
- On macOS, `bash` and `zsh` each mean two shells, and all four are tested: the system's `/bin/bash`, which is bash 3.2, and `/bin/zsh`, next to Homebrew's current builds. Code that runs under bash uses nothing bash 3.2 lacks.
- ShellCheck at zero errors and zero warnings.
- Bytes read into a variable pass through `tr -d '\000'` first: bash 5 prints `ignored null byte in input` into the output when a command substitution meets a NUL.
- Bytes are written with `printf '%b'` and octal escapes in the `\0ddd` form, never with a format string built at run time: BusyBox's `%b` reads only that form.
- An awk program defines no function named like a gawk built-in, such as `xor`, `and`, `or`, `compl`, `lshift`, `rshift`, `strftime` or `systime`: gawk then refuses the whole program.
- A pattern substitution never takes an unquoted expansion as its replacement: bash 5.2 rewrites it at every `&` and bash 3.2 at every backslash. [`family/bin/audit`](family/bin/audit) rejects one.
- A file's size comes from `stat -c %s -- FILE`, or `stat -f %z -- FILE` where `stat` is BSD's, never `wc -c <file`: Ubuntu's BusyBox `wc` counts in 32 bits.
- `scripts/check-names.sh` fails `make lint` on a `$(dd ...)` read without `tr -d`, a `} >file` line, a fixed descriptor redirect after `done`, an awk function named like a gawk built-in, a `mkdir` lock, a `wc -c <file` size and a bare `wait` in a test, so these rules hold without anyone remembering them.
- No comments in source, apart from tool directives and the test markers.
- Make targets, with the same meaning in every member:

  | Target | Does |
  |:-------|:-----|
  | `make help` | Lists the targets |
  | `make fmt` | Formats every script with `shfmt -i 2` |
  | `make lint` | `shfmt -i 2 -d`, ShellCheck `-o all`, the name check, `mandoc -T lint`, yamllint and actionlint at zero findings, so the local gate catches what CI's lint job does |
  | `make test` | The suites under the system `sh` |
  | `make test-all` | The suites under every installed shell, both builds of bash and zsh on macOS |
  | `make test-linux` | The suites in the Ubuntu container |
  | `make coverage` | bashcov on the Mac and in the container, merged, gated at 100% |
  | `make screens` | The README screens, recorded from the real plugin with VHS, on macOS |
  | `make check` | `lint` and `test` |
  | `make install` | The tool, man page and completions under `PREFIX` |

  The template also has `make new-member NAME=<name>`. CI installs shfmt v3.14.1 from its release binary, checked against its SHA-256.
- Conventional commits pushed straight to `main`; there are no pull requests from people. semantic-release cuts the version: a `feat` or `fix` commit publishes a release, stamps `<TOOL>_VERSION` in `lib/core.sh` through `.github/scripts/set-version.sh` and updates [`CHANGELOG.md`](CHANGELOG.md).
- Before every push: [`family/bin/audit`](family/bin/audit), `make lint`, `make test-all` on macOS, `make test-linux` and `make coverage`. CI repeats them; it does not replace them.
- Any push to `main` is safe at any moment. Push as soon as the local gates pass, never waiting for a CI or release run. The newest green push releases every commit since the last tag.
- `ci.yml` runs on every push to `main` and every pull request that changes anything other than Markdown, and on demand, with the jobs `plan`, `lint`, `test-linux`, `test-macos`, `coverage gate`, `family`, which runs [`family/bin/audit`](family/bin/audit) and `family/bin/sync --check`, and `security`. GitHub's free plan runs at most five macOS jobs at a time, so the macOS jobs start only after lint and every Linux job passed, a failing macOS job cancels the others, and a pull request from a bot runs only the macOS coverage job, which the `plan` job decides. It has one top-level concurrency group per event and ref with `cancel-in-progress: true`. The release lives in `release.yml`, started by `workflow_run` when `ci` succeeds on `main`, in a job group that never cancels. Its `recover` job runs every hour, on demand, and whenever `ci` fails on `main`: `.github/scripts/ci-state.sh` reads the state of `main`'s newest commit, and `.github/scripts/recover.sh` starts a new `ci` run when every failed job of the newest run never got a runner, up to five per commit and then fails visibly, and releases a green commit that still holds unreleased `feat`, `fix`, `perf`, `revert` or breaking commits. `step-security/harden-runner` is the first step of every job.
- CI runs on the newest Ubuntu LTS runner label and on a pinned macOS label, never a `-latest` label. macOS runners are an approved exception to the Ubuntu-only default: the macOS toolsets and every macOS reader can only be tested there.

## Ownership

Every file in a member belongs to exactly one class. [`family/OWNERSHIP`](family/OWNERSHIP) is the machine-readable assignment, and a path it does not name is `free`, so a file becomes shared only by a deliberate act.

| Class | Rule | Enforced by |
|:------|:-----|:------------|
| `owned` | Byte-identical in every member. A local edit is a build failure | [`family/bin/audit`](family/bin/audit) against [`family/CHECKSUMS`](family/CHECKSUMS), and [`family/bin/sync`](family/bin/sync) against the other members |
| `shaped` | Same structure in every member, content specific to the plugin | The structural checks in [`family/bin/audit`](family/bin/audit), such as the headings of the agent guide |
| `free` | The plugin itself. No family constraint | Nothing |

An owned file is added to the ownership list only once it is identical in every member, because an entry added early fails the audit everywhere on the first run.

[`family/VERSION`](family/VERSION) holds a single integer, the contract version. It increases whenever an owned file changes, so a member whose version is behind another's is out of date by definition, which makes falling behind detectable without comparing every file first.

## Keeping members in step

| When | Command | What it catches |
|:-----|:--------|:----------------|
| Every push, offline | [`family/bin/audit`](family/bin/audit) | A local edit to an owned file, or a shaped file that broke its structure |
| Weekly, and on every push that touches the contract | `family/bin/sync --check` | A member whose owned files or contract version differ from the others |
| When something shared improves | [`family/bin/propagate`](family/bin/propagate) | Nothing. This is how a change reaches all members at once |

The weekly check runs in every member rather than in one place, so a divergence is reported from both sides, and no single vantage point has to stay healthy for the family to notice.

## How to change a shared file

Never edit an owned file in more than one repository.

1. Make the change in one member.
2. With every member checked out side by side, run `family/bin/propagate --members-dir .. --branch main --no-push --message '<subject>'`. It copies the change into every other member, increments the contract version, regenerates [`family/CHECKSUMS`](family/CHECKSUMS) and commits in each one. The member the change started in keeps it uncommitted, for its own commit.
3. Run the gates in every member, then push each `main` on its own.

Running `propagate` twice against the same change does nothing the second time. A member's Family run that started before its siblings were pushed compares against their old copies and fails; once every member is pushed, rerun that member's newest run.

## When a member must differ

Record it in [`family/EXCEPTIONS.md`](family/EXCEPTIONS.md), naming the repository, the file, the reason, and the condition that would retire the exception. That file is itself owned, so an exception taken by one member is readable from every member.

An undeclared difference is a build failure. An exception with no retirement condition is a permanent change to the contract made by one member, so it is refused.

**Record the exception before the file becomes owned, never after.** An exception stops `propagate` from overwriting a member's copy from that point on. It cannot bring back a copy already replaced, because propagate writes files rather than merging them, and the member's own version is then only in its history.

**Prefer retiring the exception to keeping it.** Every exception is a member drifting on purpose, and a shared file that a member cannot use is usually a sign that the shared thing needs to be more general rather than that the member needs to be excused.

## Improving one member improves the family

When work on one plugin produces something the others would benefit from, the work is not finished when that plugin is better. Decide whether the improvement is family-wide. If it is, move it into an owned file and propagate it in the same session. If it is not, say why in the commit body.

A member that gets better alone leaves the others behind, and the family is only worth having if that cannot happen quietly.

## Key bindings

**No two members may ship colliding default keys.** Every default is allocated once, by hand, across the whole family in [`family/KEYS.md`](family/KEYS.md), so a person who installs every member gets no conflict without configuring anything. A person who wants a different layout sets the per-action option.

That rule decides defaults. It does not decide what happens when a person's own remap lands on a key another action already holds, and the two mechanisms must not be confused:

| Question | Answered by |
|:---------|:------------|
| Do two shipped defaults collide? | The key allocation. They must not, and [`family/bin/live-keys`](family/bin/live-keys) loads every member into a private tmux server and exits non-zero when two of them bind the same key |
| A person remapped one action onto another's key. Now what? | The binding registry: collect every binding, write them in one pass, let the key the person set outrank the one the plugin defaulted, leave the loser unbound, and report the clash |
| A person already bound the key outside the family | The plugin leaves that binding alone, skips its own, and `doctor` reports the skip |

## Notifications

A member whose state can need attention, such as a battery at critical charge or a disk crossing its high threshold, may send a desktop notification. Every one follows the same rules:

- It goes through [`src/lib/utils/notify.sh`](src/lib/utils/notify.sh), which picks `osascript` on macOS and `notify-send` on Linux and passes the title and message as arguments, never inside AppleScript source.
- It sits behind `@<prefix>_revamped_notify`, and the default is `0`. A fresh install never shows a notification.
- The same state always shows in the status line or the member's popup, so turning notifications off loses nothing.
- A missing notifier is not an error. `doctor` reports which one would be used.

## A bug found in one member is a bug hunted in all of them

Fixing a defect in one member and stopping there is an incomplete fix. Every defect is classified before it is closed:

| Class | Test | Obligation |
|:------|:-----|:-----------|
| Shared | The defect is in an owned file | Fix once, propagate. Every member gets the fix by construction |
| Systemic | The defect is in a pattern, an idiom, a platform assumption, or a convention that other members could repeat | Sweep every member, fix every affected one, in the same session |
| Local | The defect is in this plugin's own feature code and no other member could express it | Fix here. Say why in the commit body |

Only the third class stops at one repository, and claiming it requires saying why the others cannot be affected. "It looks specific to this plugin" is not that reason. A defect arising from shell behavior, tmux behavior, an operating-system difference, a tmux entry point convention, an option or key convention, or anything copied between members is systemic by default.

### Discharging the obligation

```sh
family/bin/sweep --pattern '<regex>' --label '<what the defect is>'
family/bin/sweep --script <probe> --label '<what the defect is>'
```

A pattern sweep suits a defect recognizable by reading. A probe sweep suits one that only shows up when the code runs, which is the stronger evidence and the right choice whenever the defect was found by running something.

The sweep distinguishes three outcomes per member, and the third matters as much as the first: a member the sweep could not check is reported as not checked and fails the run. A member that was not examined is never a member that is clean.

### What the commit must carry

- The class, named.
- For a systemic defect, the sweep command and its result.
- For a local defect, the reason no other member can express it.
- A regression test that fails without the fix. Where the defect is systemic, the test is itself systemic, so it belongs in an owned test file rather than in one member's.

### A green pipeline is not a clean sweep

Some defects cannot reach CI at all, so a sweep that only consults the pipeline reports them as absent.

| Class | Why CI misses it | Where to look |
|:------|:-----------------|:--------------|
| A path containing a space | Runner checkout paths have no spaces. `run-shell` hands its argument to `/bin/sh`, which word-splits it, so the wrong command runs and reports 127 | A checkout under a directory with a space |
| bash 3.2 | Ubuntu runners carry bash 5, and a macOS job resolves whatever is first on `PATH` | `/bin/bash` on macOS, run directly |
| A blocking entry point | Nothing in CI reads the entry point's stdout and waits on it | Run the entry point under a command substitution and time it |
| A leaked test fixture | The run ends and the runner is destroyed | A long-lived developer machine, hours later |
| A substitution replacement holding `&` or a backslash | Runner checkout paths and test fixtures rarely contain either | [`family/bin/audit`](family/bin/audit) rejects an unquoted expansion as a replacement |
| An entry point without the executable bit | The suite and [`family/bin/live-keys`](family/bin/live-keys) load the entry point through a shell, which needs no executable bit, while TPM executes the file and discards the permission error | The mode git records, which [`family/bin/audit`](family/bin/audit) reads |

When a defect belongs to one of these, run the probe locally and say so in the commit body. Reporting a member as clean on the strength of a green pipeline it could never have failed is the same error as not checking it.

## Tooling

| Command | Purpose |
|:--------|:--------|
| [`family/bin/audit`](family/bin/audit) | Verify this member against [`family/CHECKSUMS`](family/CHECKSUMS) and the structural rules. Offline |
| [`family/bin/checksums`](family/bin/checksums) | Regenerate [`family/CHECKSUMS`](family/CHECKSUMS) from the ownership list |
| [`family/bin/sync`](family/bin/sync) | Compare this member against every other. `--check` exits non-zero on divergence |
| [`family/bin/propagate`](family/bin/propagate) | Apply a shared change to every member and commit it in each |
| [`family/bin/inventory`](family/bin/inventory) | Emit this member's options, keys, placeholders, commands and versions |
| [`family/bin/doctor`](family/bin/doctor) | Report collisions and exceptions across every installed member, against a live tmux server |
| [`family/bin/live-keys`](family/bin/live-keys) | Load every member into a private tmux server and fail when two bind the same key |
| [`family/bin/sweep`](family/bin/sweep) | Hunt a defect found in one member across every other member |
| [`family/bin/gen-readme`](family/bin/gen-readme) | Generate the README's family section, and check it with `--check` |

Every one of them exits non-zero on failure. Gate on the exit code, never on the output text.
