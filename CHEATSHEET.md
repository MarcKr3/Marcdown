# Marcdown Framework — User Cheatsheet

## Modes

At the start of each conversation, Claude asks which mode applies. The mode stays until you change it.

| Mode | When | What Claude does |
|------|------|------------------|
| **Fast** | You test the result on the device or by hand | Makes the change itself, with no agents unless you ask. Runs the build and the unit suite once, at the end. Ends with a checklist for you. |
| **Thorough** | The change needs more proof | Scales the process to the risk. A trivial change gets no agents. A logic change gets one impl-agent, test first. An unclear cause gets the debugger first. Larger work gets a team from `team-framework.md`. |

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

Not every task uses all agents. The orchestrator selects the minimum set needed. The orchestrator makes trivial changes itself. In Fast mode, no agents start unless you ask.

## Key State Files (`.planning/`)

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

- **You choose the mode.** Fast or Thorough, asked at the start of each conversation.
- **You approve everything.** Claude presents a proposal and waits before it starts a plan, writes code or spawns agents.
- **You make the design choices.** If a design choice is not clearly stated, Claude asks. A design choice changes behavior, appearance, wording or scope. Surprises and plan deviations also come to you.
- **Evidence before "done".** Nothing is marked complete without a check that can fail.
- **Root cause before fix.** After two failed fixes, Claude reproduces the fault in a check first.
- **No commits unless you ask.** Claude also never uses git to discard changes.
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
| Merge parallel agent branches | `worktree-merger` (auto-deployed) |
| Check progress | `/status` |
| End your session cleanly | `/handoff` |
| Start a new session | `/resume-h` |
