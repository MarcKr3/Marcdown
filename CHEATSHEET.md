# Marcdown Framework: User Cheatsheet

## Modes

Before the first change to code or files, Claude asks two questions: the mode and the agent automation. A chat that only answers questions or reads does not ask them. Claude does not ask a question that your messages already answer. The answers stay until you change them.

| Mode | Development | Checks after development |
|------|-------------|--------------------------|
| **No Test** | Agents can develop | Build or compile only. No test runs. Install on the device. |
| **Test After** | Agents can develop | Tests of the changed code and the shared behavior. Install on the device. |
| **Thorough Testing** | Test first. The process scales to the risk. | Tests of the changed code and the shared behavior. Install on the device. |

**Agent automation.** No: you get a device checklist. Yes: Claude does the device checklist itself with computer use or phone automation. Then you get the evidence and a checklist of only the items that Claude could not test.

When the work becomes risky, Claude recommends a different mode. The mode changes only when you agree.

## Slash Commands

| Command | What it does |
|---------|--------------|
| `/new-project [files]` | Project kickoff: discovery questions, requirements, roadmap and Phase 1 plan. The approved plan goes to the memory node `plan-<slug>`, the to-do items to `NEXT.md`. |
| `/new-feature [files]` | Feature kickoff: discovery questions, requirements, codebase map and plan. The approved plan goes to the memory node `plan-<slug>`, the to-do items to `NEXT.md`. |
| `/strategize <problem>` | Compares the approaches and recommends one, with the reasons and the tradeoffs |
| `/debug <symptom>` | Starts or continues a debug session. The notes are a memory node on the board until the bug is fixed. |
| `/review [files]` | Compares the recent changes with the goals, the done-criteria and the safety points of the plan node |
| `/cleanup [files]` | Updates the docs, the type hints and the comments, and removes dead code |
| `/handoff [name]` | Writes a short handoff to `handoffs/` on the board. `/handoff list` shows all handoffs. |
| `/marcdown-setup [folder]` | Installs or updates Marcdown. Shows each change and asks you about it before it installs. |

## Typical Workflows

**New project:**
`/new-project` → tell Claude to build Phase 1 → `/cleanup` → `/handoff`

**Feature in an existing codebase:**
`/new-feature auth` → tell Claude to build it → `/review` → `/cleanup`

**Feature with an unclear approach:**
`/strategize <problem>` → `/new-feature` → tell Claude to build it

**Bug fix:**
`/debug <symptom>` → tell Claude to make the fix

**Continue in a new session:**
Claude reads `NEXT.md` at the start. The to-do items point to the plan node `plan-<slug>` in the board memory. If you wrote a handoff, tell Claude to read it from `handoffs/` on the board.

## Agents

| Agent | Model | Job |
|-------|-------|-----|
| Explore (built-in) | set by Claude Code | Finds and reads the relevant code |
| Plan (built-in) | set by Claude Code | Writes the plan. The plan goes to the chat. |
| `theorycrafting` | Opus | Compares approaches and recommends one. Writes notes and pings, not code. |
| `impl-agent` | Opus | Makes the code change that the directive specifies |
| `debugger` | Opus | Finds the root cause with tests that can fail. Does not fix. |
| `test-validator` | Sonnet | Runs the tests in Test After and Thorough Testing, and reports. With no test for the new code, it reports a gap, not a pass. |
| `docs-and-cleanup` | Sonnet | Docs, type hints, comments and dead code after the checks pass |
| `worktree-merger` | Sonnet | Merges the branches of parallel worktree agents |

The chat that you open is the lead. The lead orchestrates the agents and makes the decisions with you. The lead makes trivial changes itself. It starts with few agents and adds agents only when the task proves larger. Agents align through pings and mailboxes on the board.

## The Board

Each project keeps the shared agent state on branches of its own remote. Run `~/.claude/bin/board setup` one time for each project on each computer.

| Command | What it does |
|---------|--------------|
| `board setup` | Checks out the board, links the memory folders, starts the 2-minute sync |
| `board status` | Shows the sync job, the memory links and anything stuck |
| `board path next\|memory\|computer\|agents` | Shows where a board folder is on this computer |
| `board mailbox <name>` | Opens or joins a mailbox branch |
| `board check` | Finds broken links in the shared memory |

| Place | Holds |
|-------|-------|
| The chat | The checkpoints and the approved deviations |
| `NEXT.md` | The to-do list, the lane status and the decisions for you |
| `memory/plan-<slug>.md` | The approved plan until the work is done: the requirements, the goals, how to know that each goal is reached, and the safe way to each goal (risks, what must not break, how to go back) |
| `memory/` | The shared project memory and the debug notes. `memory/computers/{name}/` holds notes for one computer. |
| `handoffs/` | The handoffs that you ask for |
| Pings (`agents` branch) and mailboxes (`mailbox/*` branches) | Agent communication across computers |
| `.claude/agent-memory/<agent>/` | The learning of each agent from session to session |

## Parallel Work

1. **Session worktrees.** Before `/new-feature`, `/new-project` or `/debug` starts, Claude looks for another session on the same repository. If one is active, Claude moves into a worktree. If not, Claude works in the main checkout. Say "no worktree" or "use a worktree" to override this.
2. **Agent worktrees.** Agents that change source code in parallel run in their own worktrees.
3. **Merge.** After parallel worktree agents finish, `worktree-merger` merges their branches. When two changes contradict each other, it stops and the decision comes to you.

## Rules You Should Know

- **You choose the mode and the automation.** Claude asks before the first change to code or files.
- **"Do X" is your approval.** Claude does not ask again. "What does X need?" gets a numbered list of steps.
- **You make the design choices.** If a design choice is not clearly stated, Claude asks. A design choice changes behavior, appearance, wording or scope. Surprises and deviations also come to you.
- **Your words win.** Then the global rules, then the project files. Claude shows each conflict to you.
- **Evidence before "done".** Claude marks nothing complete without a check that can fail.
- **Root cause before fix.** After two failed fixes, Claude reproduces the fault in a check first.
- **No commits unless you ask.** Exception: Claude commits and pushes the board branches itself. Claude never uses git to discard changes.
- **Reviews.** Claude examines its own diff. An independent review runs only when you ask. When you say that a branch is complete, Claude offers one final independent review on the most capable model available, at high or xhigh effort.
- **Tests.** In Test After and Thorough Testing, the tests of the changed code and the shared behavior. The full suite and mutation tests run only when you ask.
- **Writing.** Text outside the chat is in strict Simplified Technical English. The `ste-lint.py` lint runs only for user-facing STE text when it is truly necessary.
- **Context.** Use `/compact` to free context. When the work drifts, Claude recommends `/handoff` and a new session.

## Quick Decision Guide

| You want to... | Use |
|----------------|-----|
| Install or update Marcdown | `/marcdown-setup` |
| Start a new project | `/new-project` |
| Add a feature | `/new-feature` |
| Decide between approaches | `/strategize` |
| Build what is planned | Tell Claude to build it |
| Fix a bug | `/debug` |
| Check the changes against the plan | `/review` |
| Tidy the docs and dead code | `/cleanup` |
| Merge parallel agent branches | `worktree-merger` (the lead starts it) |
| See the open work | `NEXT.md` on the board |
| End your session cleanly | `/handoff` |
