# Marcdown Framework — User Cheatsheet

## Modes

At the start of each chat, Claude asks two questions: the mode, and the agent automation. Claude does not ask a question that your first message already answers. The answers stay until you change them.

| Mode | Development | Checks after development |
|------|-------------|--------------------------|
| **Fast** | Agents can develop | Build or compile only. No test runs. |
| **Medium** | Agents can develop | Tests of the changed code and the shared behavior. Install on the device. |
| **Thorough** | Test first. The process scales to the risk. | Tests of the changed code and the shared behavior. Install on the device. |

**Agent automation.** No: you get a device checklist. Yes: Claude does the device checklist itself with computer use or phone automation. Then you get the evidence and a checklist of only the items that Claude could not test.

When the work becomes risky, Claude recommends a different mode. The mode changes only when you agree.

## Slash Commands

| Command | What It Does |
|---------|-------------|
| `/new-project [files]` | Full project kickoff: discovery questions, requirements, roadmap, plan |
| `/new-feature [files]` | Feature addition pipeline: scoped to `.planning/features/<slug>/` for parallel safety |
| `/plan <task>` | Create a phased implementation plan (project or feature scope) |
| `/implement [slug]` | Execute the next plan phase; pass feature slug to target a specific feature |
| `/debug <symptom>` | Start/resume systematic debugging; each session namespaced to `.planning/debug/<slug>/` |
| `/investigate <query>` | Quick codebase search for files, functions, patterns |
| `/analyse <code>` | Deep logic & dependency analysis of specific code |
| `/strategize <problem>` | Evaluate multiple approaches before committing |
| `/review [slug]` | Compare implementation against plan intent (project or feature scope) |
| `/review-plan [slug]` | Critique plan quality before execution (project or feature scope) |
| `/plan-check [slug]` | Validate plan against codebase reality (project or feature scope) |
| `/cleanup [scope]` | Post-implementation docs, types, dead code removal |
| `/status` | Full project dashboard — scans all features, debug sessions, handoffs |
| `/debug-status [slug]` | Debug session progress; lists all sessions if no slug given |
| `/resume-h [name]` | Pick up where last session left off; scans all features and debug sessions |
| `/handoff [name]` | Save session state; optional name for parallel work contexts |
| `/checkpoint [slug] <task>` | Log task completion; prefix with feature slug for feature scope |
| `/deviation [slug] <desc>` | Record a plan divergence; prefix with feature slug for feature scope |
| `/archive-plan [slug]` | Archive a plan and start fresh (project or feature scope) |

## Typical Workflows

**New project from scratch:**
`/new-project` → `/implement` → `/status` → `/handoff`

**Add a feature to existing codebase:**
`/new-feature auth` → `/implement auth` → `/cleanup` → `/handoff`

**Parallel features (two agents, same project):**
Agent A: `/new-feature auth` → `/implement auth`
Agent B: `/new-feature payments` → `/implement payments`
Then: `worktree-merger` integrates both branches

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

Ad-hoc: `debugger` (on failures), `worktree-merger` (after parallel worktree agents).
Orchestration: `team-leader` (multi-team), `team-communicator` (cross-team).

Not every task uses all agents. The orchestrator selects the minimum set needed. The orchestrator makes trivial changes itself. Each agent has a model tier: see `team-framework.md`.

## The Board

Each project keeps the shared agent state on branches of its own remote. Run `~/.claude/bin/board setup` one time for each project on each computer.

| Command | What it does |
|---------|--------------|
| `board setup` | Checks out the board, links the memory folders, starts the 2-minute sync |
| `board status` | Shows the sync job, the memory links and anything stuck |
| `board path next\|memory\|computer\|agents` | Shows where a board folder is on this computer |
| `board mailbox <name>` | Opens or joins a mailbox branch |
| `board check` | Finds broken links in the shared memory |

- `NEXT.md`: the to-do list, the lane status and the decisions for you.
- `memory/`: the shared project memory. `memory/computers/{name}/` holds notes for one computer.
- `handoffs/`: the handoffs that you ask for.
- Pings (`agents` branch) and mailboxes (`mailbox/*` branches): agent communication across computers.

## Key State Files (`.planning/`, only when you ask for a `.planning/` command)

### Project-Level (singleton)

| Path | Purpose |
|------|---------|
| `PLAN.md` | Active project implementation plan |
| `CHECKPOINTS.md` | Project task completion log |
| `DEVIATIONS.md` | Project plan divergence records |
| `REQUIREMENTS.md` | Project requirements (from `/new-project`) |
| `ROADMAP.md` | Multi-phase roadmap (from `/new-project`) |
| `HANDOFF.md` | Default session handoff pointer |
| `handoffs/` | Named session handoffs |
| `archive/` | Archived plans |

### Per-Feature (parallel-safe)

| Path | Purpose |
|------|---------|
| `features/<slug>/REQUIREMENTS.md` | Feature requirements with FREQ-IDs |
| `features/<slug>/CODEBASE.md` | Feature codebase map |
| `features/<slug>/PLAN.md` | Feature implementation plan |
| `features/<slug>/CHECKPOINTS.md` | Feature task completion log |
| `features/<slug>/DEVIATIONS.md` | Feature plan divergence records |

### Per-Debug-Session (parallel-safe)

| Path | Purpose |
|------|---------|
| `debug/<slug>/DEBUG.md` | Debug session state and hypothesis tracking, when the session can outlive the context |

## Parallel Execution

Three layers protect parallel agent work:

1. **Session worktrees (default)** — every work command auto-enters a worktree via `EnterWorktree`. Opt out with "no worktree".
2. **Namespacing** — each feature/debug session gets its own `.planning/` subdirectory
3. **Sub-agent worktrees** — agents that modify source code run in isolated git worktrees (`isolation: "worktree"`)

After parallel worktree agents finish, the `worktree-merger` agent integrates their branches.

## Rules You Should Know

- **You choose the mode and the automation.** Asked at the start of each chat.
- **"Do X" is your approval.** Claude does not ask again. "What does X need?" gets a numbered list of steps.
- **You make the design choices.** If a design choice is not clearly stated, Claude asks. A design choice changes behavior, appearance, wording or scope. Surprises and deviations also come to you.
- **Your words win.** Then the global rules, then the project files. Claude shows each conflict to you.
- **Evidence before "done".** Nothing is marked complete without a check that can fail.
- **Root cause before fix.** After two failed fixes, Claude reproduces the fault in a check first.
- **No commits unless you ask.** Exception: Claude commits and pushes the board branches itself. Claude also never uses git to discard changes.
- **Reviews.** Claude examines its own diff. An independent review runs only when you ask. When you say that a branch is complete, Claude offers one final independent review.
- **Tests.** The tests of the changed code and the shared behavior. The full suite and mutation tests only when you ask.
- **Team limits.** Max 7 agents single-team, 14 multi-team. Exceeding requires your explicit approval.
- **Session management.** Claude writes a handoff only when you ask (`/handoff`). `/resume-h` reads it in the next session. Use `/compact` to free context.

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
| Merge parallel agent branches | `worktree-merger` (auto-deployed) |
| Check progress | `/status` |
| End your session cleanly | `/handoff` |
| Start a new session | `/resume-h` |
