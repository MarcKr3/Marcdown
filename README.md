# **Humor**

## Marcdown

An agent team framework for Claude Code. Adds structured multi-agent orchestration, slash commands, and quality guardrails to your `~/.claude/` setup.

## What's Included

- **12 specialized agents** — from `codebase-investigator` to `worktree-merger`, each with defined roles and handoff rules
- **19 slash commands** — `/plan`, `/implement`, `/debug`, `/handoff`, `/status`, and more
- **Parallel-safe architecture** — feature namespacing + git worktree isolation for concurrent agent work
- **CLAUDE.md** — core rules: Fast, Medium or Thorough mode, agent automation, "Do X" is the approval, questions on design choices, evidence before claims, root cause before fix
- **`bin/board`** — keeps the shared agent state of each project on branches of its own remote. This state is `NEXT.md`, a shared memory, pings and mailboxes. A sync job runs every 2 minutes on macOS, Windows and Linux.
- **`ste-writing` skill** — writes docs, comments and messages in Simplified Technical English, with a linter (`ste-lint.py`)
- **References & templates** — team framework docs, plan/debug/handoff templates

## Install

**Back up your existing `~/.claude/` setup first if you have custom configurations.**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/MarcKr3/marcdown/main/install.sh)
```

To install from an unpacked zip, run the installer in the unpacked folder. It then copies from that folder and does not download anything:

```bash
bash marcdown/install.sh
```

This copies framework files directly into `~/.claude/`. Files with identical names are overwritten. The installer will warn you and prompt for confirmation before proceeding.

**What gets installed:** `agents/`, `bin/`, `commands/`, `references/`, `templates/`, `skills/ste-writing/`, `CLAUDE.md`

**What is NOT installed:** `README.md`, `CHEATSHEET.md`, `CHEATSHEET.pdf`, `.gitignore`, `.gitattributes`, `tests/`

## Set up the board (one time for each project on each computer)

Run this command in a checkout of the project. On Windows, use `bin\board.cmd` from PowerShell or cmd (it needs Git for Windows).

```bash
~/.claude/bin/board setup
```

The command checks out the board branches beside the project. It links the Claude memory folder of each checkout and each worktree to the shared memory. Then it starts the sync job. If this computer has memory notes that the board does not have, the command lists them and stops. Run it again with `--share-notes` to share them, or with `--keep-local` to keep them on this computer only. `board status` shows the sync. To test the tool, run `bash tests/board.sh` in this repository.

## Update

Re-run the install script. It will download the latest version and overwrite existing framework files.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/MarcKr3/marcdown/main/install.sh)
```

## Uninstall

Removes all Marcdown-installed files, leaving a vanilla `~/.claude/` directory. Your own files (settings, projects, memory) are untouched.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/MarcKr3/marcdown/main/install.sh) --uninstall
```
