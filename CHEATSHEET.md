# Marcdown Framework — User Cheatsheet

## Slash Commands

| Command | What It Does |
|---------|-------------|
| `/new-project [files]` | Full project kickoff: discovery questions, requirements, roadmap, plan |
| `/new-feature [files]` | Feature addition pipeline: scoped discovery, requirements, codebase map, plan |
| `/plan <task>` | Create a phased implementation plan |
| `/implement [phase]` | Execute the next plan phase with agents |
| `/debug <symptom>` | Start/resume systematic debugging session |
| `/investigate <query>` | Quick codebase search for files, functions, patterns |
| `/analyse <code>` | Deep logic & dependency analysis of specific code |
| `/strategize <problem>` | Evaluate multiple approaches before committing |
| `/review` | Compare implementation against plan intent |
| `/review-plan` | Critique plan quality before execution |
| `/plan-check` | Validate plan against codebase reality |
| `/cleanup [scope]` | Post-implementation docs, types, dead code removal |
| `/status` | Full project dashboard (git + plan + debug state) |
| `/plan-status` | Planning-specific progress overview |
| `/debug-status` | Current debug session progress |
| `/resume-h [name]` | Pick up where last session left off; optional name for named handoffs |
| `/handoff [name]` | Save session state; optional name for parallel work contexts |
| `/checkpoint <task>` | Log task completion milestone |
| `/deviation <desc>` | Record a plan divergence |
| `/archive-plan` | Archive current plan and start fresh |

## Typical Workflows

**New project from scratch:**
`/new-project` → `/implement` → `/status` → `/handoff`

**Add a feature to existing codebase:**
`/new-feature` → `/implement` → `/cleanup` → `/handoff`

**Feature with clear requirements:**
`/plan <feature>` → `/plan-check` → `/implement` → `/cleanup` → `/handoff`

**Feature with unclear approach:**
`/strategize <problem>` → `/plan <feature>` → `/implement`

**Bug fix:**
`/debug <symptom>` → `/implement` → `/status`

**Resume previous session:**
`/resume-h` → `/status` → `/implement`

## Agent Pipeline (auto-selected by commands)

```
investigate → analyse → strategize → plan → plan-check → implement → test → cleanup
```

Not every task uses all agents. The orchestrator selects the minimum set needed.

## Key State Files (`.planning/`)

| File | Purpose |
|------|---------|
| `PLAN.md` | Active implementation plan |
| `CHECKPOINTS.md` | Completed task log |
| `DEVIATIONS.md` | Plan divergence records |
| `DEBUG.md` | Active debug session state |
| `HANDOFF.md` | Session continuity pointer (default) |
| `handoffs/` | Named session handoffs |
| `archive/` | Previous plans |

## Rules You Should Know

- **You approve everything.** No agents spawn without your OK. Every proposal is presented first.
- **Escalation-first.** Surprises are surfaced to you, never handled silently.
- **Evidence before "done".** Nothing is marked complete without proof (test run, output check).
- **Root cause before fix.** Debugging diagnoses first, patches second.
- **Team limits.** Max 7 agents single-team, 14 multi-team. Exceeding requires your explicit approval.
- **Session management.** Use `/handoff` at end of session, `/resume-h` at start of next. Use `/compact` to free context mid-session without losing state.

## Quick Decision Guide

| You want to... | Use |
|----------------|-----|
| Start a whole new project | `/new-project` |
| Add a feature to existing codebase | `/new-feature` |
| Plan a specific feature/task | `/plan` |
| Understand unfamiliar code | `/investigate` then `/analyse` |
| Decide between approaches | `/strategize` |
| Build what's planned | `/implement` |
| Fix a bug | `/debug` |
| Check progress | `/status` |
| End your session cleanly | `/handoff` |
| Start a new session | `/resume-h` |
