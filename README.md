# **Humor**

Brought to You by Marc.

## Marcdown

An agent team framework for Claude Code. Adds structured multi-agent orchestration, slash commands, and quality guardrails to your `~/.claude/` setup.

## What's Included

- **11 specialized agents** — from `codebase-investigator` to `team-leader`, each with defined roles and handoff rules
- **20 slash commands** — `/plan`, `/implement`, `/debug`, `/handoff`, `/status`, and more
- **CLAUDE.md** — core behavioral rules: escalation-first, TDD, systematic debugging, mandatory user approval
- **References & templates** — team framework docs, plan/debug/handoff templates

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/marcdown/main/install.sh)
```

This clones the repo into `~/.claude/Marcdown/` and symlinks the framework files into `~/.claude/`. Existing files are not overwritten.

## Update

```bash
cd ~/.claude/Marcdown && git pull
```

Symlinks mean updates take effect immediately.

## Uninstall

Remove the symlinks and the cloned repo:

```bash
cd ~/.claude && rm -f CLAUDE.md CHEATSHEET.md CHEATSHEET.pdf agents commands references templates && rm -rf Marcdown
```
