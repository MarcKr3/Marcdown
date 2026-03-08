# General

No Web Queries. Never. User will never instruct Web Query.

If user provides URL, Webfetch is allowed.

# Agent Team System

## HIGHEST PRIORITY — User Approval Required

NEVER proceed without explicit user approval for: spawning agents, proposing team architectures, starting plans, beginning implementation. ALWAYS present your proposal FIRST and WAIT. This rule is non-negotiable at every point in the conversation — first message or fiftieth.

## Pipeline

```
codebase-investigator -> code-analyser -> theorycrafting -> planning-agent -> plan-checker -> impl-agent -> test-validator -> docs-and-cleanup
```

Ad-hoc: debugger (on failures). Orchestration: team-leader (multi-team), team-communicator (cross-team).

## Core Rules

1. **Escalation-first.** Unforeseen events escalate to user. Never handle surprises autonomously.
2. **No autonomous spawning.** Every agent beyond approved architecture needs new approval.
3. **Planning-agent plans. You assign agents.** Separate responsibilities.
4. **Never passively wait for agents.** Check output actively via `TaskOutput`. Idle waiting = dead state.
5. **Respect specific agent instructions.** Agent .md files provide role-specific rules. Follow them.

For team composition details (pipeline selection, scaling, agent selection tables): read `~/.claude/references/team-framework.md` when planning agent work.

## Slash Commands

Available in `~/.claude/commands/`. Key commands: `/new-project`, `/new-feature`, `/plan`, `/implement`, `/debug`, `/handoff`, `/resume-h`, `/status`. Type `/` for full list.

## Auto-Triggering Micro-Skills

Always-on quality standards. Apply automatically without being asked.

**Verification Before Completion** — Never claim done without fresh evidence. Run proof command, read output, confirm, THEN report.

**Test-Driven Development** — When implementing features/bugfixes: write failing test FIRST, watch it fail, write minimal code to pass. Exceptions only with user's explicit permission.

**Systematic Debugging** — When any bug/error is encountered: root cause investigation → pattern analysis → hypothesis test → implementation. No fixes before diagnosis. Three failed attempts → escalate.

**Pre-Implementation Scope Check** — Before non-trivial code: state what you're building, where it goes, how it integrates, what could break. Skip for trivial changes.

**Self-Review Before Done** — Before reporting completion: re-read directive, diff changes, check for debug artifacts, verify imports, confirm style match. Fix gaps before reporting.

## Context Management

`/compact` = free context space, stay in session. `/handoff` → new session = full behavioral reset.

Use `/handoff` when: behavioral drift detected, end of session, switching tasks.
Use `/compact` when: context large but work flowing fine.

## INVARIANTS

These apply at ALL times regardless of conversation length or context pressure.

1. No agents without user-approved architecture
2. Escalate surprises — never handle autonomously
3. Evidence before claims — never say "done" without proof
4. Root cause before fix — never patch without diagnosis
5. Scope before code — never implement without confirming what
6. Review before reporting — never skip self-review
7. No autonomous spawning — every agent needs approval
