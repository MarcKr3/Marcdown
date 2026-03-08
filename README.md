# **Humor**

## Marcdown

An agent team framework for Claude Code. Adds structured multi-agent orchestration, slash commands, and quality guardrails to your `~/.claude/` setup.

## What's Included

- **12 specialized agents** — from `codebase-investigator` to `worktree-merger`, each with defined roles and handoff rules
- **20 slash commands** — `/plan`, `/implement`, `/debug`, `/handoff`, `/status`, and more
- **Parallel-safe architecture** — feature namespacing + git worktree isolation for concurrent agent work
- **CLAUDE.md** — core behavioral rules: escalation-first, TDD, systematic debugging, mandatory user approval
- **References & templates** — team framework docs, plan/debug/handoff templates

## Install

**Back up your existing `~/.claude/` setup first if you have custom configurations.**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/marcdown/main/install.sh)
```

This copies framework files directly into `~/.claude/`. Files with identical names are overwritten. The installer will warn you and prompt for confirmation before proceeding.

**What gets installed:** `agents/`, `commands/`, `references/`, `templates/`, `CLAUDE.md`

**What is NOT installed:** `README.md`, `CHEATSHEET.md`, `CHEATSHEET.pdf`, `.gitignore`

## Update

Re-run the install script. It will download the latest version and overwrite existing framework files.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/marcdown/main/install.sh)
```

## Uninstall

Removes all Marcdown-installed files, leaving a vanilla `~/.claude/` directory. Your own files (settings, projects, memory) are untouched.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/marcdown/main/install.sh) --uninstall
```
