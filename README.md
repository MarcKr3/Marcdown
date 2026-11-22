## Marcdown

An agent team framework for Claude Code. Adds structured multi-agent orchestration, slash commands, and quality guardrails to your `~/.claude/` setup.

## What's Included

- **6 specialized agents**: `debugger`, `docs-and-cleanup`, `impl-agent`, `test-validator`, `theorycrafting` and `worktree-merger`, each with defined roles and handoff rules. For code search and plans, use the built-in Explore and Plan agents.
- **9 slash commands**: `/cleanup`, `/debug`, `/handoff`, `/loop-setup`, `/marcdown-setup`, `/new-feature`, `/new-project`, `/review` and `/strategize`
- **Parallel-safe architecture**: git worktree isolation for concurrent agent work
- **CLAUDE.md**: core rules: one start question for larger work (small requests skip it), Live (you are at the computer) or Loop (you are away, `/loop-setup` first), "Do X" is the approval, questions on design choices, parked questions in a Loop, review depth by risk, evidence before claims, root cause before fix, record only what the code cannot tell
- **Safety and checks**: `/marcdown-setup` adds a verify hook that blocks the end of a Loop run while a done-check fails. The first time that Claude works in a project, it asks one time: apply the defaults (deny rules for acts that cannot be undone, the board, the folder as a trusted place) or customize them. The OS sandbox is an option in each Loop
- **`bin/board`**: keeps the shared agent state of each project on branches of its own remote. This state is `NEXT.md`, a shared memory, pings and mailboxes. A sync job runs every 2 minutes on macOS, Windows and Linux.
- **`ste-writing` skill**: writes docs, comments and messages in Simplified Technical English, with a linter (`ste-lint.py`)
- **References & templates**: team framework docs and the handoff template

## Install

The recommended way is `/marcdown-setup`. It shows each change and asks you about it with questions before it installs anything. It also asks what to do with the files that you changed yourself.

**First install** (the command is not on this computer yet):

1. Clone the repository:

   ```bash
   git clone --depth 1 https://github.com/MarcKr3/Marcdown.git marcdown
   ```

2. Open Claude Code and give it this request: "Run the steps in `marcdown/commands/marcdown-setup.md` with the folder `marcdown`."

**Alternative: the plain installer.** Back up your `~/.claude/` setup first if you have your own configuration. The installer asks for a confirmation, but it does not show the changes:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/MarcKr3/Marcdown/main/install.sh)
```

To install from an unpacked zip, run the installer in the unpacked folder. It then copies from that folder and does not download anything:

```bash
bash marcdown/install.sh
```

The installer copies the framework files into `~/.claude/` and writes over files with the same names. It also deletes the files that an earlier Marcdown version installed and that the new version does not ship. Your own files stay.

**What gets installed:** `agents/`, `bin/`, `commands/`, `references/`, `templates/`, `skills/ste-writing/`, `CLAUDE.md`

**What is NOT installed:** `README.md`, `CHEATSHEET.md`, `CHEATSHEET.pdf`, `.gitignore`, `.gitattributes`, `tests/`

## Set up the board (one time for each project on each computer)

Run this command in a checkout of the project. On Windows, use `bin\board.cmd` from PowerShell or cmd (it needs Git for Windows).

```bash
~/.claude/bin/board setup
```

The command checks out the board branches beside the project. It links the Claude memory folder of each checkout and each worktree to the shared memory. Then it starts the sync job. If this computer has memory notes that the board does not have, the command lists them and stops. Run it again with `--share-notes` to share them, or with `--keep-local` to keep them on this computer only. `board status` shows the sync. To test the tool, run `bash tests/board.sh` in this repository.

## Update

In Claude Code, run `/marcdown-setup`. It gets the latest version, shows the new, changed and removed files, and asks you about each change before it installs.

Alternative: run the install script again. It writes the latest version over the framework files without a review:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/MarcKr3/Marcdown/main/install.sh)
```

## Uninstall

Removes all Marcdown-installed files, leaving a vanilla `~/.claude/` directory. Your own files (settings, projects, memory) are untouched.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/MarcKr3/Marcdown/main/install.sh) --uninstall
```
