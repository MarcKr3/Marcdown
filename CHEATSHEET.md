# Marcdown Framework: User Cheatsheet

## Modes

For work that is large enough for a Loop (a feature, a long series of fixes), Claude asks one question before the first change: are you at the computer for this work? Small requests (a question, a simple bug fix, a small edit) use Live and do not ask. The answer stays until you change it.

| Mode | When | How Claude works |
|------|------|------------------|
| **Live** | You are at the computer | Fast work. Claude runs the build and the tests of the changed code and the shared behavior, asks before it installs on the device, and gives you the device checklist. Test first only when you ask, or for shared behavior or stored data. |
| **Loop** | You are away | `/loop-setup` first. Then a self-running loop toward exact goals. Each goal has a done-check that Claude writes first and sees fail. The loop works on its own branch, can commit, merge main into its branch, push and open a draft PR. It builds and runs the app on the device only when you allowed computer use in `/loop-setup`. Without computer use, it asks at the end if you want to check on the device. It merges into main only when all goals pass and you said yes to that in `/loop-setup`. After the merge, the setup chat cleans up the branch and the worktree. |

A Loop stops when all goals pass, the budget is reached, or it is stuck. Then you get a report. You also get a push notification on your phone if the setup chat stays open and Remote Control is on for it. Otherwise the stop is in `NEXT.md` and the mailbox `group-loops`.

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
| `/loop-setup [task]` | Interviews you before a Loop: goals with done-checks, off-limits areas, safety points, the engine (local `/loop`, cloud sessions or a workflow), budget and stop conditions, the merge into main, parked questions, hidden context. Writes the loop node `loop-<slug>`. |
| `/marcdown-setup [folder]` | Installs or updates Marcdown. Shows each change and asks you about it before it installs. It also adds the verify hook. |

## Typical Workflows

**New project:**
`/new-project` → tell Claude to build Phase 1 → `/cleanup` → `/handoff`

**Feature in an existing codebase:**
`/new-feature auth` → tell Claude to build it → `/review` → `/cleanup`

**Feature with an unclear approach:**
`/strategize <problem>` → `/new-feature` → tell Claude to build it

**Bug fix:**
`/debug <symptom>` → tell Claude to make the fix

**Work while you are away:**
`/loop-setup <task>` → answer the interview → keep the setup chat open with Remote Control → go away → push notification at the stop → read the report

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
| `test-validator` | Sonnet | Runs the tests in Live and Loop, and reports. With no test for the new code, it reports a gap, not a pass. |
| `docs-and-cleanup` | Sonnet | Docs, type hints, comments and dead code after the checks pass |
| `worktree-merger` | Sonnet | Merges the branches of parallel worktree agents |

The chat that you open is the lead. The lead orchestrates the agents and makes the decisions with you. The lead makes trivial changes itself. It starts with few agents and adds agents only when the task proves larger. Agents align through pings and mailboxes on the board. Board news comes to each agent automatically: a message to its name, to `all` in its mailbox or to `everyone`, a ping change, and new commits on main. A message wakes a chat that waits, on any computer.

## The Board

Each project keeps the shared agent state on branches of its own remote. Run `~/.claude/bin/board setup` one time for each project on each computer.

| Command | What it does |
|---------|--------------|
| `board setup` | Checks out the board, links the memory folders, starts the 2-minute sync and the notification listener |
| `board status` | Shows the sync job, the memory links, the notifications and anything stuck |
| `board whoami <name>` | Tells the board which agent this chat is, so that messages to that name wake it |
| `board inbox` | Shows what is new on the board for this chat (the hooks do this automatically) |
| `board path next\|memory\|computer\|agents` | Shows where a board folder is on this computer |
| `board mailbox <name>` | Opens or joins a mailbox branch |
| `board check` | Finds broken links in the shared memory |

| Place | Holds |
|-------|-------|
| The chat | The checkpoints and the approved deviations |
| `NEXT.md` | The to-do list, the lane status and the decisions for you |
| `memory/loop-<slug>.md` | The setup of a Loop run: goals and done-checks, off-limits areas, safety points, engine, budget, merge answer, parked-question rule, verify command |
| `.claude/loop.json` (in the loop worktree, not in git) | Switches on the verify hook for the running Loop |
| `memory/plan-<slug>.md` | The approved plan until the work is done: the requirements, the goals, how to know that each goal is reached, and the safe way to each goal (risks, what must not break, how to go back) |
| `memory/` | The shared project memory and the debug notes. `memory/computers/{name}/` holds notes for one computer. |
| `handoffs/` | The handoffs that you ask for |
| Pings (`agents` branch) and mailboxes (`mailbox/*` branches) | Agent communication across computers |
| `NOTIFY.md` (`agents` branch) | The topic of the push relay for board notifications |
| `.claude/agent-memory/<agent>/` | The learning of each agent from session to session |

## Parallel Work

1. **Session worktrees.** Before `/new-feature`, `/new-project` or `/debug` starts, Claude looks for another session on the same repository. If one is active, Claude moves into a worktree. If not, Claude works in the main checkout. Say "no worktree" or "use a worktree" to override this.
2. **Agent worktrees.** Agents that change source code in parallel run in their own worktrees.
3. **Merge.** After parallel worktree agents finish, `worktree-merger` merges their branches into the branch of the lead. When two changes contradict each other, it stops and the decision comes to you. After the merge, Claude removes the agent branches and their worktrees without a question.

## Rules You Should Know

- **You choose the mode: Live or Loop.** Claude asks before the first change to code or files.
- **"Do X" is your approval.** Claude does not ask again. "What does X need?" gets a numbered list of steps.
- **You make the design choices.** If a design choice is not clearly stated, Claude asks. A design choice changes behavior, appearance, wording or scope. Surprises and deviations also come to you.
- **Your words win.** Then the project files, then the global rules. Claude shows each conflict to you. When a project file and the global rules conflict, Claude asks one time and records your ruling in the project file as a dated line.
- **Evidence before "done".** Claude marks nothing complete without a check that can fail.
- **Root cause before fix.** After two failed fixes, Claude reproduces the fault in a check first.
- **Own branch: no question.** On its own branch, Claude commits, pushes, opens a pull request and merges main into the branch without a question. It also commits and pushes the board branches. A merge into main needs your go for that merge, and happens only when the feature is complete. Your go also approves the cleanup of the branch and its worktrees after the merge. Claude never pushes to main directly and never uses git to discard changes.
- **Deletions.** Claude asks each time before it deletes or overwrites data that git does not hold. A deletion that git can bring back is part of the approved work.
- **Reviews.** Claude examines its own diff. The review depth follows the risk: docs and wording get the self-review only. Shared behavior, stored data, money, security and legal matters get one fresh independent review. Claude proposes the level, and you decide. Any other independent review runs only when you ask. When you say that a branch is complete, Claude offers one final independent review on the most capable model available, at high or xhigh effort.
- **Tests.** The tests of the changed code and the shared behavior. In a Loop, the verify hook blocks the end of the run while a done-check fails. The full suite and mutation tests run only when you ask.
- **Writing.** Text outside the chat is in strict Simplified Technical English. The `ste-lint.py` lint runs only for user-facing STE text when it is truly necessary.
- **Parked questions.** In a Loop, a new design question goes to "Decisions for the user" in `NEXT.md` with a recommendation. The loop continues with other work. When only parked questions are left, it uses the recommendation and records it. You can reverse it.
- **Touchpoints.** Each report lists each point where the work needed you. These points show what to automate next.
- **Knowledge.** Claude records only what it cannot find in the code: hidden dependencies, undocumented services, gotchas, reasons and your rulings. When it must guess such a fact, it records the guess in `NEXT.md` so that you can give the fact.
- **Safety.** The first time that Claude works in a project, it asks one time: apply the defaults or customize them. The defaults are deny rules for acts that cannot be undone (discarding work, force pushes, pushes to main, reading secrets), the board, and the folder as a trusted place. After that, Claude keeps the setup and does not ask again. The OS sandbox is an option in each Loop, on by default.
- **Context.** Use `/compact` to free context. When the work drifts, Claude recommends `/handoff` and a new session.

## Quick Decision Guide

| You want to... | Use |
|----------------|-----|
| Install or update Marcdown | `/marcdown-setup` |
| Let Claude work while you are away | `/loop-setup` |
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
