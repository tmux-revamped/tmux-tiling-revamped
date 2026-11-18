# tmux-revamped: the family standard

The repositories in the table below are one family of tmux plugins, called tmux-revamped. Each one does one job inside tmux, and they look, read and behave alike, so a person who knows one already knows how to drive the others, and every member installs beside every other with no clash.

Two files carry the family, and every member implements everything both say:

- [`FAMILY.md`](FAMILY.md), this file, holds everything the members share. It is the same, byte for byte, in every member.
- [`AGENTS.md`](AGENTS.md) holds only what is exclusive to its own repository: its layout, its names, its behaviour, the rules of its own domain, its release details and its open gaps. Every member's agent guide has the same headings, in this order: Layout, Names, Behaviour, Domain rules, Release, Gaps against FAMILY.md. A rule that would serve more than one member belongs here instead.

Nothing about the family lives anywhere else, so anyone with the repositories has all of it.

There is no central repository. Every plugin is installed by cloning its own repository, so the distribution channel has no room for a shared dependency: a submodule does not survive that clone, and a source archive leaves it out. The contract and the identical files are replicated in every member instead, and every change to them is made in every member in the same task. No member carries family tooling or a family folder: this file is the whole contract.

This file states the standard every member is held to. Where a member does not meet a rule yet, the rule still applies, and the member lists the difference under Gaps against FAMILY.md in its agent guide. That list is the family's progress tracker: it shrinks until it reads `None`, and a feature a gap still affects is never described as finished in the docs.

## Hard rules

Every member holds these without exception. This file is what enforces them: a rule is written here, never handed to a script that checks it.

- **Lean.** A file, a section or a step stays only while something needs it. Nothing restates this file, and nothing exists only to police it.
- **No aliases.** A renamed option, command, key or file keeps no alias, and no compatibility shim exists: the old name stops working in the release that renames it.
- **Nothing beyond the plugin.** A repository holds the plugin, its tests, CI, its docs, [`AGENTS.md`](AGENTS.md), this file, and the coding agent's instruction file, which only imports those two. No family folder, no family tooling, no AI tooling such as agent definitions, prompts or editor assistant settings.
- **A rewrite keeps every value.** A rewrite or a rename keeps every value the old version read for a setting, with its unit: each spelling of on and off, each word such as `off` or `none`, a number in the unit it had. Dropping a value or changing a unit is a breaking change the owner decides; it never follows from the alias rule, which is about names.
- **Both platforms.** Every feature works in full on Linux and on macOS, as Platforms describes.
- **doctor in every member.** Every member has `bin/<tool>`, which answers `help`, `version` and `doctor` as Commands describes, and `doctor` names every dependency with its path and version.
- **gum interface.** Every member draws its terminal interface with gum, and where gum cannot draw it falls back byte for byte to the plain interface, as Terminal interface describes.
- **Recorded features, shown in the README.** Every feature has a VHS recording, every key a recording presses is captioned on screen while it acts, and every README shows the recordings: the hero GIF under the introduction and a gallery with a still of every screen, as Screens describes.
- **Bug reports carry doctor.** The bug report form requires the output of `<tool> doctor` and `<tool> version`, so every report says which tools ran, as Issues describes.
- **Quiet by default.** Desktop notifications are off until the person turns them on.
- **One key, one owner.** No two members ship the same default key; the allocation is under Key bindings.
- **Real addresses only.** No example, test, fixture, recording or document holds a made-up URL or host, on a reserved example domain or any other. Where a URL is needed it is the repository's own, `https://github.com/tmux-revamped/<repository>`, or the real service the feature talks to.
- **No contact channel.** No file holds a mail address, a chat or social handle, or any other way to reach a person: a question, a bug and a change go through the repository's issues and pull requests. A git identity in a test has a name and an empty mail address. Mail-shaped text appears only where a feature reads that shape, and then it is the hosting service's own, never a person's.
- **Straight to `main`.** People open no pull requests; every change is a conventional commit pushed to `main`, and only bots open pull requests.
- **Released from `.releaserc.json`.** Every member is released by semantic-release, configured in [`.releaserc.json`](.releaserc.json) and nowhere else. No version is written by hand, and no workflow cuts a release another way.
- **In step.** A change to this file or to an identical file lands in every member in the same task.

| Member | What it does | Repository |
|:-------|:-------------|:-----------|
| tmux-autoreload-revamped | Edit your tmux config, save, and watch it reload itself, no key, no command | [tmux-revamped/tmux-autoreload-revamped](https://github.com/tmux-revamped/tmux-autoreload-revamped) |
| tmux-battery-revamped | Battery status for your tmux status bar, without ever blocking the status render | [tmux-revamped/tmux-battery-revamped](https://github.com/tmux-revamped/tmux-battery-revamped) |
| tmux-bluetooth-revamped | Every connected Bluetooth device and its battery in your tmux status bar, without blocking the render | [tmux-revamped/tmux-bluetooth-revamped](https://github.com/tmux-revamped/tmux-bluetooth-revamped) |
| tmux-cpu-revamped | CPU load, temperature, and frequency in your tmux status bar, without ever blocking the render | [tmux-revamped/tmux-cpu-revamped](https://github.com/tmux-revamped/tmux-cpu-revamped) |
| tmux-disk-revamped | Disk usage for your tmux status bar, without ever blocking the status render | [tmux-revamped/tmux-disk-revamped](https://github.com/tmux-revamped/tmux-disk-revamped) |
| tmux-extract-revamped | Pick a URL, path, hash or any other token off the screen with fzf and type it at the cursor, in pure shell | [tmux-revamped/tmux-extract-revamped](https://github.com/tmux-revamped/tmux-extract-revamped) |
| tmux-fzf-revamped | Switch to, kill, rename or create tmux sessions, windows and panes from fzf pickers in a popup | [tmux-revamped/tmux-fzf-revamped](https://github.com/tmux-revamped/tmux-fzf-revamped) |
| tmux-git-revamped | Show the active pane's git branch, changes and provider counts in the tmux status bar without blocking it | [tmux-revamped/tmux-git-revamped](https://github.com/tmux-revamped/tmux-git-revamped) |
| tmux-gpu-revamped | GPU load, temperature, clock, power and memory in the tmux status bar, from NVIDIA, AMD, Intel and Apple GPUs | [tmux-revamped/tmux-gpu-revamped](https://github.com/tmux-revamped/tmux-gpu-revamped) |
| tmux-kube-revamped | Current Kubernetes context and namespace in the tmux status bar, parsed from kubeconfig without kubectl | [tmux-revamped/tmux-kube-revamped](https://github.com/tmux-revamped/tmux-kube-revamped) |
| tmux-launcher-revamped | Open any terminal app in a tmux popup, window or split from one menu, starting at the project root | [tmux-revamped/tmux-launcher-revamped](https://github.com/tmux-revamped/tmux-launcher-revamped) |
| tmux-logging-revamped | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot | [tmux-revamped/tmux-logging-revamped](https://github.com/tmux-revamped/tmux-logging-revamped) |
| tmux-music-revamped | Now playing in your tmux status bar, without ever blocking the status render | [tmux-revamped/tmux-music-revamped](https://github.com/tmux-revamped/tmux-music-revamped) |
| tmux-network-revamped | Network throughput in your tmux status bar, without ever blocking the render | [tmux-revamped/tmux-network-revamped](https://github.com/tmux-revamped/tmux-network-revamped) |
| tmux-pain-control-revamped | Pane and window management bindings for tmux, version aware, vim friendly, every prefix key can be disabled | [tmux-revamped/tmux-pain-control-revamped](https://github.com/tmux-revamped/tmux-pain-control-revamped) |
| tmux-persist-revamped | Save every tmux session, window and pane, auto-save on a timer, and restore it all after a reboot | [tmux-revamped/tmux-persist-revamped](https://github.com/tmux-revamped/tmux-persist-revamped) |
| tmux-plugin-template | The starting point for a tmux-revamped plugin: shared library, bats harness and CI | [tmux-revamped/tmux-plugin-template](https://github.com/tmux-revamped/tmux-plugin-template) |
| tmux-pomodoro-revamped | A Pomodoro timer in the tmux status bar that keeps all of its state in tmux options, with no temp files | [tmux-revamped/tmux-pomodoro-revamped](https://github.com/tmux-revamped/tmux-pomodoro-revamped) |
| tmux-ram-revamped | RAM, swap and memory pressure in the tmux status bar, sampled in the background so the render never waits | [tmux-revamped/tmux-ram-revamped](https://github.com/tmux-revamped/tmux-ram-revamped) |
| tmux-reorder-revamped | Drag a window tab along the tmux status bar with the mouse to move that window | [tmux-revamped/tmux-reorder-revamped](https://github.com/tmux-revamped/tmux-reorder-revamped) |
| tmux-scroll-revamped | Send the mouse wheel to apps that scroll themselves and into tmux copy-mode everywhere else | [tmux-revamped/tmux-scroll-revamped](https://github.com/tmux-revamped/tmux-scroll-revamped) |
| tmux-sensible-revamped | Sensible tmux defaults, gated by tmux version and terminal, that leave the options you set alone | [tmux-revamped/tmux-sensible-revamped](https://github.com/tmux-revamped/tmux-sensible-revamped) |
| tmux-tiling-revamped | Tiling window management for tmux: eight layouts including BSP dwindle and spiral, with layout undo | [tmux-revamped/tmux-tiling-revamped](https://github.com/tmux-revamped/tmux-tiling-revamped) |
| tmux-time-revamped | Local and world clocks for the tmux status bar, colored by time of day, with countdowns and a DST warning | [tmux-revamped/tmux-time-revamped](https://github.com/tmux-revamped/tmux-time-revamped) |
| tmux-weather-revamped | Weather for the tmux status bar from wttr.in, fetched in the background so the status line never waits | [tmux-revamped/tmux-weather-revamped](https://github.com/tmux-revamped/tmux-weather-revamped) |

## How a repository joins

Copy this file and the identical files listed under Layout and tooling in unchanged, write an agent guide with the same headings as the other members', follow both, allocate every default key under Key bindings first, and add the repository to the table above and to the loop below in every member in the same task. The template's `make new-member NAME=<name>` scaffolds one with every name and prefix renamed. With the members checked out side by side, this shows any drift in this file:

```sh
for member in tmux-autoreload-revamped tmux-battery-revamped tmux-bluetooth-revamped tmux-cpu-revamped tmux-disk-revamped tmux-extract-revamped tmux-fzf-revamped tmux-git-revamped tmux-gpu-revamped tmux-kube-revamped tmux-launcher-revamped tmux-logging-revamped tmux-music-revamped tmux-network-revamped tmux-pain-control-revamped tmux-persist-revamped tmux-plugin-template tmux-pomodoro-revamped tmux-ram-revamped tmux-reorder-revamped tmux-scroll-revamped tmux-sensible-revamped tmux-tiling-revamped tmux-time-revamped tmux-weather-revamped; do
  cmp FAMILY.md "../${member}/FAMILY.md"
done
```

The same loop with any identical file in place of `FAMILY.md` checks that file.

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

- Every setting is a tmux option named `@<prefix>_revamped_<setting>`, where `<prefix>` is the member's own, such as `cpu` or `net`, because tmux users configure plugins in `.tmux.conf`. A member reads no option outside that pattern. A renamed setting, option, command or file keeps no alias: the old name stops working in the same release, which is a breaking change whose notes name the old and the new.
- The tool takes the same setting as a long option, `--<setting>`, and from the environment as `<TOOL>_<SETTING>` in capitals, with the tool's dashes written as underscores, such as `CPU_REVAMPED_INTERVAL`. The command line wins over the environment, the environment over the tmux option, and the tmux option over the default.
- A tmux option set to nothing counts as not set, so its default applies: one `tmux display-message` read cannot tell an option set to nothing from one never set, and the option reader most tmux plugins carry treats the two alike. A value given as nothing on the command line or in the environment is used as given.
- A key runs later, where neither the command line nor the environment of `apply` exists. A setting `apply` got from either one therefore rides, as an option, on every command its bindings run that reads that setting; a setting from a tmux option is left off and read when the key runs, so changing it needs no reload.
- `--name value` and `--name=value` both work, and `--` ends the options.
- A yes or no setting that is asked about interactively has both forms, such as `--verify` and `--no-verify`. As a tmux option it reads `1` for yes and `0` for no.
- The family's one shared setting is its look, under Terminal interface.
- No member reads a bare name such as `INTERVAL`, and none takes its internal variables from the environment: a member either assigns each one outright, or its entry point clears every inherited `REVAMPED_` variable before anything runs. Only the test switches, which all start with `REVAMPED_TEST_`, such as `REVAMPED_TEST_GUM`, survive the clearing.
- No internal variable has the name of a setting's environment variable: `<TOOL>_<SETTING>` belongs to the setting alone. A global of that name, assigned when the library loads, replaces what the person exported before the settings are read, so the setting is ignored with no error.
- Anything required and not given is asked for when stdin is a terminal: `Label [default]: ` on stderr, up to three tries for a required value.
- Without a terminal the tool never waits on a prompt. It stops with the usage hint under Diagnostics.
- A destructive step, such as deleting a saved session, asks the person to type its name: `Type work to delete, or anything else to stop: `.
- With no arguments on a terminal, a tool with several jobs offers a menu headed `What would you like to do?`, numbered on the plain interface and a `gum choose` list where gum draws; a tool with one job asks for its inputs directly.

## Output

- Results and progress lines go to stdout. Prompts, diagnostics, and a progress line redrawn in place on a terminal go to stderr.
- A status placeholder, `#{<prefix>_<name>}`, prints its value and nothing else. A value the host has no source for renders empty, and `doctor` says which source is missing.
- Text that comes from outside the plugin, such as a process, window or song name, has every `#` doubled before tmux reads it as a format.
- A folder handed to tmux as a start directory, the `-c` of `new-window`, `split-window` and `new-session` and the `-d` of `display-popup`, has every `#` doubled first: tmux expands formats there, so a folder whose path holds `#S` would open somewhere else.
- A format inside a command that tmux parses when a key runs, such as a branch of `if-shell`, is written in double quotes: tmux reads an unquoted `#{` at the start of a word there as a comment and drops the rest of the command.
- Numbers are computed and printed under the C locale, so a locale with a decimal comma still prints `1.5G`.
- A tick of the shared ticker writes options from its own shell, never from inside a `$(...)`: once the publisher is loaded, every write joins the one batch the tick commits, and a write made in a subshell is lost.
- Before a long or destructive run, a summary block states what is about to happen. Each label carries a colon and is padded to 8 columns; continuation lines are indented 8 spaces, and the block has a blank line above and below.
- A long step shows one progress line: `<Verb> NNN%  <rate>  XmYYs left`. On a terminal it redraws in place; otherwise it prints once per 10 percent.
- The last line states the result in a full sentence, such as `Saved. 4 sessions are in work.json.`
- A message is printed as one line, and the terminal wraps it at its own width. No member breaks a message into lines itself, so a narrow window, a wide one and a pipe all get the same text, and a script reads one message per line.
- Text written ahead of time, such as the help page and the fixed lines of a summary block, keeps its lines within 80 columns.
- A command whose result a script would read offers `--json`, which prints that result as one JSON object on stdout in place of the text form.

## Terminal interface

Every member draws its terminal interface with [gum](https://github.com/charmbracelet/gum), and every member looks the same. A popup is the same tool run inside `tmux display-popup`.

- gum draws only where it can: prompts when stdin and stderr are terminals, diagnostics when stderr is one, and results when stdout is one, each only when `gum` is on `PATH`. Anywhere else the plain interface runs, byte for byte, so pipes, files, scripts, `--json`, the status line and the golden transcripts never change. A terminal without gum gets the plain interface too, and `doctor` reports gum missing.
- One look for the family: a rounded header box with the tool's name, version and tagline opens the menu; `gum choose` for a menu or a choice, `--no-limit` for several, whose header names `x`, the key gum 2.0.2 marks with, and `--label-delimiter "|"` for a label that carries a value; `gum filter` for a long list or a file; `gum input` for a value, with a default shown as its placeholder and taken when the answer is empty, never prefilled with `--value`, which makes typing append to it, and `--password` for a secret; `gum write` for text, where Enter submits and Ctrl+J adds a line; `gum confirm` for yes or no; `gum spin --spinner dot` while a short step runs; a rounded summary box before a long or destructive run; a thick red danger box above the typed confirmation; a rounded table with a state cell coloured ok, warn or error; the progress line with a bar in the accent; `gum pager` for long output; log lines `INFO`, `WARN` and `ERROR` in the theme's colours, where a message whose first word is capitalized, not an acronym, continues in lowercase after the prefix; badges for a short state; and a bold closing sentence in the ok colour.
- gum's own `gum file` redraws from the top of the screen and hides its header, `gum table --print` styles the first data row as the header and cannot colour a cell, and `gum log` joins lines and breaks words at the screen's edge. No member uses them: files are picked with `gum filter`, tables come from `lib/table.awk` inside a `gum style` box, and log lines are drawn by `revamped_ui_log`, one line per message.
- `gum style` drops colour it reads from stdin, so coloured text is passed to it as arguments. `gum spin` draws on stdout, so a member sends it to stderr and lets it wait on the step's process, which runs in the background with its diagnostics held in a file until the spinner stops.
- The palette comes from a theme: `--theme NAME`, else `<TOOL>_THEME`, else `KODOUGU_THEME`, else the tmux option `@revamped_theme`, else `kodougu`. The themes are `kodougu`, `catppuccin-mocha`, `catppuccin-latte`, `dracula`, `nord`, `gruvbox`, `tokyo-night` and `mono`, each with an accent, ok, warning, error, muted, text and surface colour and a `gum format` style. `<TOOL>_ACCENT`, else `KODOUGU_ACCENT`, replaces only the accent with a colour such as `#CBA6F7`. An unknown theme or a malformed colour stops the tool with the bad value error. `NO_COLOR` switches every theme to `mono`.
- A popup's command carries no `#`: tmux 3.6 and 3.8 expand no format there, not even in `-e` values, and an older tmux may, so only a command with no `#` reads the same on every version. A command running in a popup reads the pane under it with `tmux display-message -p '#{pane_id}'`, and prints a literal `#` as `\0043` through `printf '%b'`. Whatever a member places in a popup's command, such as its own path or a setting's value, is single-quoted with each `#` written as `"$(printf '%b' '\0043')"`; doubling the `#` is right only where tmux expands formats, as in `run-shell`, `if-shell` and a status line, and the hash-free form is right in both. A popup asks for input on its own terminal and runs the tmux command itself, because a `command-prompt` started inside a popup never receives the keys typed. A format a binding needs goes through `run-shell`, which expands it.
- `lib/ui.sh` holds the themes and every drawing helper, and `lib/table.awk` the table. A member calls them and never calls gum directly from its own modules.
- `test/ui-kit.bats` calls every helper in `lib/ui.sh` directly, so each member covers the whole module whatever it draws. Tests drive the gum path with `REVAMPED_TEST_GUM=1` and `test/bin/gum`, a shim first on `PATH` in every test that records each call in `REVAMPED_TEST_GUM_LOG` and answers from `REVAMPED_TEST_GUM_ANSWERS`, one line per prompt, `<cancel>` for Escape. gum needs a terminal, so CI cannot run the real one; the screens run the real one.

## Screens

Every README shows the plugin running for real: an animated `screens/hero.gif` under the introduction, recorded inside a real tmux, and a collapsed gallery of PNG stills, one per screen, from the status line and each popup to `doctor`, help and the themes.

- [VHS](https://github.com/charmbracelet/vhs) records them from the real plugin, the real tmux and the real gum, never from mockups. `make screens` runs `screens/record.sh`, which builds fresh fixtures with `screens/prepare.sh` before each tape, starts tmux on its own socket with its own config, records the tape, cleans up with `screens/cleanup.sh`, and crops each still with `screens/finish.sh`.
- `screens/common.tape` sets one look: the Catppuccin Mocha terminal theme, JetBrainsMono Nerd Font at 24 px, 1600 px wide, with the default `kodougu` theme for the tool.
- The screens are recorded on macOS; `record.sh` names the missing tool when `vhs`, `tmux` or `magick` is absent.
- A change that alters what a screen shows records the screens again in the same commit.
- Every feature has a recording: every placeholder, every option that changes what is shown, every key binding, popup, menu and command appears in at least one tape. The README gallery names the tape that shows each feature. A feature without a recording is a gap, never finished.
- Every key a tape presses is captioned on screen while it acts, in the form a person types it, such as `prefix C-s`, `Enter` or `q`, so a viewer sees which keys produce each action. The recording's tmux config draws the caption on a second status line, and the tape sets it before each keystroke; a sentence in the README never replaces it. While a menu, a prompt or a popup is open, the keys that would set a caption go to it instead, so the caption for the whole sequence is set before the chord that opens it, such as `prefix M-p, Down, Enter`.
- A tape presses a chord such as `prefix M-x` as `Ctrl+B`, `Escape`, `Type@1ms "x"`, because VHS's `Alt+x` reaches tmux as a plain `x`. The recording's tmux config sets an `escape-time` long enough for the letter to arrive, 1000 in the scaffold, and a tape that presses Escape for anything else sleeps past it before typing again, or the next key becomes an Alt chord.

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

The flavor is `gnu`, `uutils`, `bsd`, `mawk`, `busybox` or `unknown`. It comes from the tool's own `--version` answer, then from where it is installed, then from the system it runs on. BusyBox is read from the first line that names it or says it is not GNU.

`doctor` also reports the tmux version, every source a placeholder reads and whether the host has it, the notifier under Notifications, and every default key the plugin skipped because the person had already bound it. A new dependency gets its `doctor` row, with its flavor when it is a core tool, in the same change.

`doctor` prints a `settings` row. Each member lists in `<PREFIX>_KINDS`, in `lib/state.sh`, what every switch, number and choice among its settings accepts, read from how the member compares that setting, and `revamped_doctor_settings` checks the value in force, whether a tmux option, the environment or the command line gave it. A value outside the list is named as `name=value` with the state `warn`, because a status line cannot say that an option was ignored. A setting that takes free text, a key or a colour has no kind, and an empty value means the default and is never named. A setting that is added or changed gets its kind in the same change.

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

- tmux itself is tested at the version the current Ubuntu LTS packages and at the one Homebrew ships. The macOS Intel runner's Homebrew can hold an older tmux than the Apple Silicon runner's, so CI runs three tmux versions, and a test relies on nothing only the newest has: it reads a binding out of the whole `list-keys` table, never by asking `list-keys` for one key. A member's own dependencies are tested in every build those routes offer. A dependency that gains a new route or build gets its leg in the same change.
- A script uses only options all six accept. Where they differ, the code handles each one and a test covers it. A change that passes on one toolset only is not done.
- Any tool macOS ships that Homebrew also builds in a newer version is tested in both: the macOS native toolset runs the system's copy, and the macOS Homebrew toolset runs Homebrew's. A member that starts calling such a tool adds its formula to the Homebrew group of its [`Brewfile`](Brewfile).
- `.github/scripts/toolset.sh native`, `homebrew`, `gnu`, `uutils` or `busybox` prints the directories that put a toolset first on `PATH`; on Linux, `busybox` links BusyBox's applets other than its shells. CI uses it, and a report is reproduced by putting the reporter's toolset first: `export PATH="$(sh .github/scripts/toolset.sh gnu | paste -sd: -):$PATH"`.

## Safety

- A file is written to a temporary file beside it, then renamed over it with `mv -f`, so an interrupted run never leaves half a file. A file the person did not name is never overwritten, and a step that fails leaves the original exactly as it was.
- A command that changes or replaces a file that existed before the run first keeps the original beside it as `NAME.bak`, or the first free `NAME.bak.N` up to 99, where `NAME` is the whole file name with its extension, and never overwrites an earlier backup. A step that fails puts the copy back. A file the run itself created needs none. This is the default, and only an option the person types, such as `--no-backup`, skips it.
- Two runs that can rewrite the same file, such as two status refreshes writing one cache, take a lock first: a lock file created under `set -C`, which the shell opens exclusively, holding the run's process ID and removed when the run ends. A lock is never a `mkdir`, which the uutils `mkdir` that Ubuntu 26.04 ships does not create exclusively.
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
- The README tables, the help page, the man page, the completions and the member's rows in the key allocation list the same options, keys, placeholders and commands. They are written by hand, and a change to one is made in all of them in the same commit.
- A man page, `man/<tool>.1`.
- Completions for bash, zsh and fish under `completions/`.
- A new option goes into the help page, the man page, all three completions and the README, in the same commit.

## Issues

The issue forms under `.github/ISSUE_TEMPLATE/` are identical in every member: a bug report, a feature request, a documentation issue and a question, with blank issues off.

- The bug report requires the whole output of `<tool> doctor` and `<tool> version`, run in the shell where the bug happens, then the system, the terminal, the steps, the expected and the actual behaviour, and the plugin's lines from `.tmux.conf`. It asks for nothing `doctor` or `version` already prints, such as the tmux version.
- A question asks for the same `doctor` output.
- No form invites a pull request, because people open none.

## Install

- TPM installs the plugin from `set -g @plugin 'tmux-revamped/<repository>'`, and every member also works when its entry point is run by hand with `run-shell`.
- `make install` puts `bin/<tool>`, its man page and its completions under `PREFIX`, `~/.local` by default.
- No member is published to Homebrew or any other package registry: a formula installs into the Homebrew prefix, which TPM never loads, so the plugin would exist twice at two versions.

## Layout and tooling

- `<name>.tmux` at the repository root is the entry point TPM runs. It is executable, and git tracks it as mode `100755`: TPM executes the file directly and discards everything it prints, so without the bit the plugin never loads and nothing reports it. TPM runs it through `run-shell`, so `return` at file scope is an error that stops nothing.
- `bin/<tool>` is the command-line entry point and sources `lib/*.sh`. There is no build step; `share/` holds data files only. `lib/state.sh` declares every global, and `lib/core.sh` holds `<TOOL>_VERSION`.
- `bin/<tool>` defines no function its library defines: the command is sourced after the library, so a function of the same name silently replaces the library's.
- POSIX `sh` without `local`: every global carries the member's internal prefix, and every function-scoped variable carries its function's prefix. Variables are written `${name}`.
- `shfmt -i 2` formats every script, and `make lint` fails on unformatted code.
- [`Brewfile`](Brewfile) lists every Homebrew formula the member's macOS gate calls: bats, tmux, the shells, both extra toolsets, the lint and recording tools, and the member's own, such as `fswatch`. `brew bundle` installs them on a Mac, and the macOS jobs of `ci.yml` install from the same file, where `HOMEBREW_REVAMPED_TOOLSET` picks one toolset and `CI` leaves out the lint and recording tools; Homebrew hands a Brewfile only the variables that start with `HOMEBREW_`, and `CI`. A tool a test calls is added there in the same change.
- Release tooling is pnpm, pinned through `packageManager` in `package.json`, running semantic-release from [`.releaserc.json`](.releaserc.json). The release job installs it with `pnpm install --frozen-lockfile` and stops on `pnpm audit --audit-level high`.
- Dependabot updates the GitHub Actions and the release tooling, and Renovate updates the runner labels, `.ruby-version` and the Gemfile, so each update arrives once. Both look for updates three times a day, at 05:00, 13:00 and 21:00 UTC. Every bot pull request merges itself once CI passes: when `ci` finishes on a pull request from a bot, `bot-merge.yml` checks that every check on that commit passed, squash-merges it at that commit with a fixed commit body, then starts `ci` on `main` with `gh workflow run`, since a merge made with `GITHUB_TOKEN` starts no workflow by itself. The bot opens the same pull request in every member, so an identical file stays identical everywhere. None is merged by hand.
- Every action, `actions/*` and `github/*` included, is pinned to a full commit SHA with its version in a trailing comment, and every container image to a digest, because zizmor's default policy requires it and a tag can move.
- A workflow that runs on `workflow_run`, which zizmor flags, carries `# zizmor: ignore[dangerous-triggers]` only when it never runs code from a pull request with a write token: `release.yml` checks out `main` or the commit a push `ci` run tested, and `bot-merge.yml` checks out nothing and only calls the GitHub API.
- These files are identical in every member: [`FAMILY.md`](FAMILY.md), the coding agent's instruction file, `.editorconfig`, `.yamllint.yml`, [`.shellcheckrc`](.shellcheckrc), [`.github/actionlint.yaml`](.github/actionlint.yaml), [`.github/dependabot.yml`](.github/dependabot.yml), `renovate.json`, `.releaserc.json`, `.github/workflows/release.yml`, `.github/workflows/bot-merge.yml`, `Gemfile`, `Gemfile.lock`, `.ruby-version`, `.simplecov`, `.github/scripts/toolset.sh`, `.github/scripts/set-version.sh`, `.github/scripts/ci-state.sh`, `.github/scripts/recover.sh`, `test/ci-state.bats`, `test/recover.bats`, the shared library modules `lib/cache.sh`, `lib/cli.sh`, `lib/command.sh`, `lib/doctor.sh`, `lib/log.sh`, `lib/notify.sh`, `lib/platform.sh`, `lib/publish.sh`, `lib/ticker.sh`, `lib/tmux.sh`, `lib/ui.sh` and `lib/table.awk`, their suites, `test/bin/gum`, `test/on_tty.py`, [`test/helpers.bash`](test/helpers.bash), [`test/tmux_helpers.bash`](test/tmux_helpers.bash), `screens/common.tape`, `screens/record.sh`, `screens/finish.sh`, `.github/scripts/coverage-gate.py`, `.github/scripts/bashcov-run.rb`, `.github/scripts/bashcov-lexer.rb`, `.github/scripts/bashcov-lexer.test.rb`, `.github/scripts/linux-coverage.sh`, `LICENSE`, [`.github/FUNDING.yml`](.github/FUNDING.yml), [`.github/CODEOWNERS`](.github/CODEOWNERS) and the issue templates. A member that does not carry one yet lists it under Gaps against FAMILY.md.
- Every script that serves the pipeline lives in `.github/scripts/`, whether CI, the release or a `make` target runs it, and the repository has no other scripts folder. `make lint` checks it.
- No member has a pull request template, a labeler or a stale-issue workflow, because only bots open pull requests. The issue templates stay, because people who use the plugins file issues.

## Tests

- Tests live in [`test/`](test): `helpers.bash` for the shared helpers, `tmux_helpers.bash` for the private tmux server, `call.sh` to call one function, `run-matrix.sh`, which runs the suites under each shell named in `REVAMPED_TEST_SHELLS`, and `linux-container.sh`, which runs a command in an Ubuntu container. A member's own mocks and guard resets go in `test/helpers_local.bash` and `test/tmux_helpers_local.bash`, which the shared files source when present, with guard resets inside a `setup_test_environment_local` function. `REVAMPED_TEST_JOBS` runs the files of a suite in parallel through GNU parallel, while the tests inside one file run in order; `REVAMPED_TEST_IMAGE` picks the container image.
- A test that needs tmux starts its own server on its own socket, with its own config and `HOME` in a temporary directory, and kills it on teardown. A second tmux server started any other way reads the person's config and writes the person's state.
- The entry point is loaded in tests as TPM loads it, through `/bin/sh` and `run-shell`, never sourced into the test's shell.
- Every key binding has a test that presses it through a real client, a second tmux attached to the test server, and checks its effect. A test that calls the command directly never sees what tmux does to the binding's own command, such as a format left unexpanded in a popup.
- Such a test sends each chord, such as `prefix h`, in its own `send-keys` call: chords that arrive in one burst are taken as pasted text on some tmux versions and skip the bindings. It also waits until a popup has closed before typing into the pane under it, since keys sent while the popup is open go to the popup.
- The private server of such a test sets `assume-paste-time` to 0, which the shared `setup_tmux_server` does: tmux 3.6 takes keys that arrive less than a millisecond apart for pasted text and runs no binding for them, and on a loaded runner separate `send-keys` calls still arrive in one burst.
- A file that a test file writes when it loads into a folder the whole run shares is written to a temporary file beside it and renamed into place. Test files run in parallel, and a file rewritten in place can be read empty by a test in another file.
- A test that hides a tool runs the program through `harness_hide`, a folder of links to every program on PATH except the hidden ones. It links one PATH folder per `ln -s` call: one call per program forks thousands of times on a Homebrew Mac.
- `bats` tests drive the real tools and the real tmux, and inject faults only through small wrappers on `PATH`. A member's test harness never defines a shell function with the name of a command another test stubs on `PATH`, or a test that stubs it unsets the function first.
- Golden transcripts guard the terminal output. A test runs a whole flow, replaces the values that change between runs, such as paths, sizes and rates, and compares the result with `test/golden/<flow>.<OS>.txt`. `REVAMPED_TEST_RECORD=1` rewrites them from a fresh run, on macOS and in the container; the diff is read before it is committed.
- 100 percent bashcov line coverage, gated locally and in CI, with no exclusion. `make coverage` merges the Mac and Ubuntu container runs before the gate, and each platform also reaches 100 percent of the lines it runs on its own. Code is written so bashcov can count it: every `case` branch runs a command, the condition of an `if`, `elif`, `while` or `until` stays on one line, a long `$(...)` assignment moves into its own function, a `} | {` join becomes `} | <function>`, no brace group closes on a redirect, and no loop redirects a fixed descriptor number. `.github/scripts/bashcov-run.rb`, `.github/scripts/bashcov-lexer.rb` and `.github/scripts/coverage.sh` correct bashcov's spliced trace records and its multiline string patterns.
- Tests never write the member's version as a literal; they read it from `lib/core.sh`, so a release does not break them.
- A wait loop polls from milliseconds upward, never with a fixed `sleep 1`.
- A stand-in script a test puts on `PATH` starts with `{ set +x; } 2>/dev/null`: under bashcov on macOS it inherits the tracer's settings, the system `sh` is bash 3.2, which cannot send its trace elsewhere, and the trace would land in the stderr the test reads.
- A test that removes a stand-in program and asks for it again runs `hash -r` first: dash answers `command -v` from its cache.
- A multiline awk program is never opened on a line that holds a quoted quote, and never uses the `'"'"'` trick inside: bashcov then counts the program's lines as code, and no test can cover them.
- A test never skips because a tool is missing on a system where CI installs it: it fails and names the tool, so a local gate cannot pass with that path untested. A skip is only for a tool that does not exist on that system, such as `inotifywait` on macOS. CI installs every tool a member's tests call.
- Every test is three blocks, opened by the bare markers `# Arrange`, `# Act` and `# Assert`.
- A test that starts background work waits on the process IDs it collected from `$!`, never with a bare `wait`: CI sets `BATS_TEST_TIMEOUT`, and bats runs that timeout as a background watchdog in the test's own shell, so a bare `wait` blocks until the timeout ends the test.
- A test that starts a daemon arranges for it to end by itself, as by handing its claim to another owner on its first sleep, and never stops it only after the command under test returns: under bashcov a process left running keeps the trace pipe open, so that command never returns and the coverage run hangs.

## Quality

- 100% shell script in POSIX `sh`, working under `sh`, `dash`, `bash` and `zsh` on both Linux and macOS, each combination tested in CI. A finding or a failure in any one of them blocks the change.
- On macOS, `bash` and `zsh` each mean two shells, and all four are tested: the system's `/bin/bash`, which is bash 3.2, and `/bin/zsh`, next to Homebrew's current builds. Code that runs under bash uses nothing bash 3.2 lacks.
- ShellCheck at zero errors and zero warnings.
- Bytes read into a variable pass through `tr -d '\000'` first: bash 5 prints `ignored null byte in input` into the output when a command substitution meets a NUL.
- Bytes are written with `printf '%b'` and octal escapes in the `\0ddd` form, never with a format string built at run time: BusyBox's `%b` reads only that form.
- An awk program defines no function named like a gawk built-in, such as `xor`, `and`, `or`, `compl`, `lshift`, `rshift`, `strftime` or `systime`: gawk then refuses the whole program.
- A pattern substitution never takes an unquoted expansion as its replacement: bash 5.2 rewrites it at every `&` and bash 3.2 at every backslash. It never takes a quoted one inside a double-quoted string either: bash 3.2 keeps those quotes, so `"${x//"#"/"##"}"` turns `a#b` into `a"##"b` there. A character is doubled with `sed` or a loop.
- A file's size comes from `stat -c %s -- FILE`, or `stat -f %z -- FILE` where `stat` is BSD's, never `wc -c <file`: Ubuntu's BusyBox `wc` counts in 32 bits.
- A byte above 0x7F is never matched with a bracket expression of raw bytes: zsh on Linux misses 0x80 to 0x9F there, so `ß` and most CJK characters count twice. It is searched for in a string of those bytes, as `case "${bytes}" in *"${byte}"*`.
- A shell pattern never matches outside text against a letter range such as `A-Z`: bash 3.2 in a UTF-8 locale takes an accented letter such as `ü` for part of the range, so a check for plain characters lets it through. The letters are written out one by one, or the comparison runs under `LC_ALL=C`. A digit range is safe.
- A helper is never signalled right after it is started and then waited for: a signal that arrives before a background helper has become its program is recorded by the shell and dropped when the program starts, so the helper lives on and the `wait` never returns. The check that would stop the helper runs before it is started.
- No comments in source, apart from tool directives and the test markers.
- Make targets, with the same meaning in every member:

  | Target | Does |
  |:-------|:-----|
  | `make help` | Lists the targets |
  | `make fmt` | Formats every script with `shfmt -i 2` |
  | `make lint` | `shfmt -i 2 -d`, ShellCheck `-o all`, `mandoc -T lint`, yamllint and actionlint at zero findings, so the local gate catches what CI's lint job does |
  | `make test` | The suites under the system `sh` |
  | `make test-all` | The suites under every installed shell, both builds of bash and zsh on macOS |
  | `make test-linux` | The suites in the Ubuntu container |
  | `make coverage` | bashcov on the Mac and in the container, merged, gated at 100% |
  | `make screens` | The README screens, recorded from the real plugin with VHS, on macOS |
  | `make check` | `lint` and `test` |
  | `make install` | The tool, man page and completions under `PREFIX` |

  The template also has `make new-member NAME=<name>`. CI installs shfmt v3.14.1 from its release binary, checked against its SHA-256.
- Conventional commits pushed straight to `main`; there are no pull requests from people. semantic-release cuts the version: a `feat` or `fix` commit publishes a release, stamps `<TOOL>_VERSION` in `lib/core.sh` through `.github/scripts/set-version.sh` and updates [`CHANGELOG.md`](CHANGELOG.md).
- Before every push: `make lint`, `make test-all` on macOS, `make test-linux` and `make coverage`. CI repeats them; it does not replace them.
- Any push to `main` is safe at any moment. Push as soon as the local gates pass, never waiting for a CI or release run. The newest green push releases every commit since the last tag.
- `ci.yml` runs on every push to `main` and every pull request that changes anything other than Markdown, and on demand, with the jobs `plan`, `lint`, `test-linux`, `test-macos`, `coverage gate`, `security` and `scorecard`. GitHub's free plan runs at most five macOS jobs at a time, so the macOS jobs start only after lint and every Linux job passed, a failing macOS job cancels the others, and a pull request from a bot runs only the macOS coverage job, which the `plan` job decides. It has one top-level concurrency group per event and ref with `cancel-in-progress: true`. The release lives in `release.yml`, started by `workflow_run` when `ci` succeeds on `main`, in a job group that never cancels. Its `recover` job runs every hour, on demand, and whenever `ci` fails on `main`: `.github/scripts/ci-state.sh` reads the state of `main`'s newest commit, and `.github/scripts/recover.sh` starts a new `ci` run when every failed job of the newest run never got a runner, up to five per commit and then fails visibly, and releases a green commit that still holds unreleased `feat`, `fix`, `perf`, `revert` or breaking commits. `step-security/harden-runner` is the first step of every job.
- CI runs on the newest Ubuntu LTS runner label and on a pinned macOS label, never a `-latest` label. macOS runners are an approved exception to the Ubuntu-only default: the macOS toolsets and every macOS reader can only be tested there.

## Keeping members in step

A change to this file or to an identical file is made in one member, copied into every other member, and committed in each, in the same task. Run the gates in every member, then push each `main` on its own. The `cmp` loop under How a repository joins, run over every identical file, is the check that the copies agree.

A member's CI run that compares it with its siblings before they are pushed sees their old copies; once every member is pushed, rerun that member's newest run.

## When a member must differ

A member that cannot carry an identical file as it is lists the file under Gaps against FAMILY.md in its agent guide, with the reason and the condition that ends the difference. A difference with no ending condition changes the contract for one member, so it is refused: the shared file becomes more general instead.

## Improving one member improves the family

When work on one plugin produces something the others would benefit from, the work is not finished when that plugin is better. Decide whether the improvement is family-wide. If it is, move it into an identical file or into this file and apply it to every member in the same task. If it is not, say why in the commit body.

A member that gets better alone leaves the others behind, and the family is only worth having if that cannot happen quietly.

## Key bindings

**No two members ship colliding default keys.** Every default is allocated once, by hand, in the tables below, so a person who installs every member gets no conflict without configuring anything. A person who wants a different layout sets the per-action option. A member's default and these tables disagreeing is a defect.

- **Stock tmux keys are reserved**, except for the declared overriders below, whose purpose is to replace them.
- **One unmodified key per member at most**, for its most-used action. Everything else goes to the `M-` tier; `C-` stays reserved for bindings that must work without releasing the modifier.
- **Mnemonic beats adjacency.** Where the mnemonic key is free, take it. Where it is not, the table records the second choice and the reason.
- **The root table is opt-in.** No member binds a root-table key unless installing it is the request, as for the declared root-table members below.
- Everything a member binds beyond its one key defaults to unbound and is documented in its README as opt-in.

| Member | Key | Action | Mnemonic |
|:-------|:----|:-------|:---------|
| tmux-launcher-revamped | `M-a` | app launcher menu | apps |
| tmux-battery-revamped | `M-b` | detail popup | battery |
| tmux-cpu-revamped | `M-c` | detail popup | cpu |
| tmux-disk-revamped | `M-d` | detail popup | disk |
| tmux-network-revamped | `M-e` | detail popup | network, `n` is a stock tmux key |
| tmux-fzf-revamped | `M-f` | picker menu | fzf |
| tmux-gpu-revamped | `M-g` | detail popup | gpu |
| tmux-bluetooth-revamped | `M-h` | detail popup | bluetooth, its own initial is taken |
| tmux-kube-revamped | `M-k` | context menu | kube |
| tmux-logging-revamped | `M-l` | logging menu | logging |
| tmux-music-revamped | `M-m` | music menu | music |
| tmux-ram-revamped | `M-r` | detail popup | ram |
| tmux-pomodoro-revamped | `M-s` | start or stop | the timer's verb, `p` is a stock tmux key |
| tmux-time-revamped | `M-t` | world clock menu | time |
| tmux-git-revamped | `M-v` | git menu | version control, `g` is taken |
| tmux-weather-revamped | `M-w` | forecast popup | weather |
| tmux-extract-revamped | `M-x` | extract from the screen | extract, `Tab` is a stock key on tmux 3.8 |
| tmux-persist-revamped | `C-s`, `C-r` | save, restore | they must work without releasing the modifier |

tmux-autoreload-revamped, tmux-plugin-template, tmux-scroll-revamped and tmux-sensible-revamped bind no prefix key.

tmux-tiling-revamped owns every `M-` plus uppercase letter, a range stock tmux leaves empty, because a window manager with 22 actions needs one:

| Key | Action | Key | Action |
|:----|:-------|:----|:-------|
| `M-A` | autotile | `M-N` | focus forward |
| `M-B` | balance | `M-O` | cycle layouts |
| `M-C` | circulate | `M-P` | focus back |
| `M-D` | dwindle | `M-Q` | jump to any pane |
| `M-E` | equalize | `M-R` | rotate |
| `M-F` | flip | `M-S` | spiral |
| `M-G` | grow the master pane | `M-T` | scratchpad |
| `M-H` | main-horizontal | `M-U` | undo |
| `M-I` | help overlay | `M-V` | main-vertical |
| `M-J` | jump to a marked pane | `M-W` | swap with the biggest pane |
| `M-K` | mark the pane | `M-X` | shrink the master pane |
| `M-L` | layout picker | `M-Y` | synchronize panes |
| `M-M` | promote to master | `M-Z` | redo |

| Declared | Member | Keys and reason |
|:---------|:-------|:----------------|
| Overrider | tmux-pain-control-revamped | Its split, resize and pane-movement keys replace tmux's own by design |
| Overrider | tmux-sensible-revamped | `C-n` and `C-p`, since it normalises defaults across tmux versions |
| Root table | tmux-reorder-revamped | The status-line mouse keys, from `MouseDown1Status` to `MouseDragEnd1StatusDefault`, because dragging a window tab is its main action, and, only with its swipe option on, the right-button pane keys `MouseDown3Pane`, `MouseUp3Pane`, `MouseDrag3Pane` and `MouseDragEnd3Pane`. It wraps the stock `MouseDown1Status` and `MouseDown3Pane` and keeps their commands running |
| Root table | tmux-scroll-revamped | The mouse wheel, and, only with its click copy option on, `DoubleClick1Pane` and `TripleClick1Pane` |

The table is assigned by hand, with the mnemonic recorded, because a generated conflict-free allocation reads like `M-i` for a battery popup, and a key nobody can remember is a key nobody uses.

A member that sends its bindings to tmux in one call sends each binding alone when that call fails, so one invalid key name leaves every other key bound, and exits 1 with tmux's error.

A person's own remap is a different question from the defaults. When a remap lands on a key another action holds, the member collects every binding, writes them in one pass, lets the key the person set outrank the one the plugin defaulted, leaves the loser unbound, and reports the clash. A key the person bound outside the family is left alone: the member skips its own binding and `doctor` reports the skip.

## Notifications

A member whose state can need attention, such as a battery at critical charge or a disk crossing its high threshold, may send a desktop notification. Every one follows the same rules:

- It goes through `lib/notify.sh`, which picks `osascript` on macOS and `notify-send` on Linux and passes the title and message as arguments, never inside AppleScript source.
- It sits behind `@<prefix>_revamped_notify`, and the default is `0`. A fresh install never shows a notification.
- The same state always shows in the status line or the member's popup, so turning notifications off loses nothing.
- A missing notifier is not an error. `doctor` reports which one would be used.

## A bug found in one member is a bug hunted in all of them

Fixing a defect in one member and stopping there is an incomplete fix. Every defect is classified before it is closed:

| Class | Test | Obligation |
|:------|:-----|:-----------|
| Shared | The defect is in an identical file | Fix once and copy the fix into every member in the same task |
| Systemic | The defect is in a pattern, an idiom, a platform assumption, or a convention that other members could repeat | Sweep every member, fix every affected one, in the same session |
| Local | The defect is in this plugin's own feature code and no other member could express it | Fix here. Say why in the commit body |

Only the third class stops at one repository, and claiming it requires saying why the others cannot be affected. "It looks specific to this plugin" is not that reason. A defect arising from shell behavior, tmux behavior, an operating-system difference, a tmux entry point convention, an option or key convention, or anything copied between members is systemic by default.

### Discharging the obligation

With the members checked out side by side, a pattern sweep reads every member's code for the defect, and a probe sweep runs a script that reproduces it against every member:

```sh
for member in ../tmux-*; do grep -rnE '<regex>' "${member}/src" "${member}"/*.tmux; done
for member in ../tmux-*; do sh <probe> "${member}"; done
```

A pattern sweep suits a defect recognizable by reading. A probe sweep suits one that only shows up when the code runs, which is the stronger evidence and the right choice whenever the defect was found by running something.

Every member ends in one of three outcomes, and the third matters as much as the first: affected, clean, or not checked. A member the sweep could not check is reported as not checked, never as clean.

### What the commit must carry

- The class, named.
- For a systemic defect, the sweep command and its result.
- For a local defect, the reason no other member can express it.
- A regression test that fails without the fix. Where the defect is systemic, the test is itself systemic, so it belongs in an identical test file rather than in one member's.

### A green pipeline is not a clean sweep

Some defects cannot reach CI at all, so a sweep that only consults the pipeline reports them as absent.

| Class | Why CI misses it | Where to look |
|:------|:-----------------|:--------------|
| A path containing a space | Runner checkout paths have no spaces. `run-shell` hands its argument to `/bin/sh`, which word-splits it, so the wrong command runs and reports 127 | A checkout under a directory with a space |
| bash 3.2 | Ubuntu runners carry bash 5, and a macOS job resolves whatever is first on `PATH` | `/bin/bash` on macOS, run directly |
| A blocking entry point | Nothing in CI reads the entry point's stdout and waits on it | Run the entry point under a command substitution and time it |
| A leaked test fixture | The run ends and the runner is destroyed | A long-lived developer machine, hours later |
| A substitution replacement holding `&` or a backslash | Runner checkout paths and test fixtures rarely contain either | Read every pattern substitution the change adds or touches |
| An entry point without the executable bit | The suite loads the entry point through a shell, which needs no executable bit, while TPM executes the file and discards the permission error | The mode git records, from `git ls-files --stage` |

When a defect belongs to one of these, run the probe locally and say so in the commit body. Reporting a member as clean on the strength of a green pipeline it could never have failed is the same error as not checking it.
