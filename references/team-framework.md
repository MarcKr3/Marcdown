# Team Design Framework: Reference

Load this file when planning agent team composition. Not needed for simple tasks.

## Modes

For work that is large enough for a Loop, the lead asks one question before the first change: is the user at the computer? Small requests use Live and do not ask. (`~/.claude/CLAUDE.md`)

| Mode | Development | Checks after development | Device checklist |
|------|-------------|--------------------------|------------------|
| Live (user present) | Agents can develop. Test first only on request, or for shared behavior or stored data | Build and the tests of the changed code and the shared behavior, then install | The user |
| Loop (user away) | `/loop-setup` first. Test first for each goal, team scaled to the risk | The done-checks of the loop node, enforced by the verify hook | The agent, with device automation. Items it cannot check go to the report |

The full suite and mutation tests run only when the user asks.

## Model Tiers

| Tier | Agents | Rule |
|------|--------|------|
| `opus` | theorycrafting, impl-agent, debugger | Can take a clear brief and work alone |
| `sonnet` | docs-and-cleanup, worktree-merger, test-validator | Exact tasks only. Stop and ask the lead when a decision comes up. |

## Agent Roster

| Agent | Role |
|-------|------|
| Explore (built-in) | Locates and reads the relevant files and code sections |
| theorycrafting | Feasibility assessment, approach evaluation, coarse phasing |
| Plan (built-in) | Implementation plans: phases, tasks, dependencies. The plan goes to the chat. |
| impl-agent | Faithful code execution per plan directives |
| test-validator | Runs tests, validates implementations, reports results |
| debugger | Systematic debugging with persistent hypothesis tracking |
| docs-and-cleanup | Aligns docs, type hints, and cleans dead code post-implementation |
| worktree-merger | Merges worktree branches after parallel agents complete |

## Pipeline Selection

| Task Type | Pipeline |
|-----------|----------|
| Trivial or single-file change | None. The orchestrator edits and verifies. |
| Simple bug fix | impl-agent. Add Explore only when the files are unknown. |
| Feature (clear requirements) | Explore -> Plan -> impl-agent -> test-validator -> docs-and-cleanup |
| Architecture decision | Explore -> theorycrafting |
| Complex feature (unclear approach) | Explore -> theorycrafting -> Plan -> impl-agent -> test-validator -> docs-and-cleanup |
| Large-scale parallel changes | Full pipeline. The lead runs the parallel agents. |
| Debugging session | debugger -> impl-agent -> test-validator |

test-validator runs in Live and in Loop. In Loop, write each done-check first and make sure that it fails. In Live, write the test first only on request, or for shared behavior or stored data.

## Team Structure

| Condition | Structure |
|-----------|-----------|
| Linear dependency chain | Single team (you orchestrate) |
| Independent parallel workstreams | Multi-team. The lead orchestrates |
| Same task replicated N times | Homogeneous teams. The lead orchestrates |
| Cross-cutting changes, shared interfaces | Multi-team. The teams align through agent communication. The lead orchestrates |

## Scaling Impl-Agents

Impl-agents map to **independent sub-tasks**, not phases.

| Signal | Decision |
|--------|----------|
| Single focused change | 1 impl-agent |
| Phase has N independent sub-tasks | N parallel impl-agents (1 per sub-task) |
| Multiple phases, each with sub-tasks | impl-agents per sub-task, respecting phase dependencies |
| Large repetitive task (e.g., 20 files) | Homogeneous team: divide evenly across impl-agents |
| Tightly coupled changes (shared state, ordering) | Fewer agents, sequential: avoid merge conflicts |

Run in parallel only work that shares no files and no processes. Start with few agents. Add agents when the task proves larger than you expected.

## Worktree Isolation

### Session-Level Isolation (when another session is active)

Before a work command (`/new-feature`, `/new-project`, `/debug`) starts, the lead finds out if another session works on the same repository. The lead examines `ListAgents` and `git worktree list`. If another session is active, the lead enters a worktree with `EnterWorktree`. If no other session is active, the lead works in the main checkout.

The user can override this. Examples: "no worktree", "work in main", "use a worktree".

### Sub-Agent Isolation

When spawning agents that modify source code in parallel, use `isolation: "worktree"` on the Agent tool call. This gives each agent an isolated copy of the repository via `git worktree`, preventing filesystem conflicts. If the agent makes changes, its worktree path and branch are returned in the result for merging.

### When to Use Worktrees

| Scenario | Worktree? | Why |
|----------|-----------|-----|
| Parallel impl-agents on independent tasks | **Yes** | Prevents source code conflicts |
| Parallel impl-agents on tightly coupled code | No | Need shared state; run sequentially instead |
| Single impl-agent (no parallel work) | No | No conflict risk |
| Agents that do not change source code (Explore, Plan, theorycrafting) | No | No source code changes. theorycrafting writes only notes and pings |
| Debugger running alongside implementation | **Yes** | May run commands that conflict |
| test-validator after worktree impl-agent | **Same worktree** (resume the agent) | Must validate against that agent's changes |
| docs-and-cleanup after worktree impl-agent | **Same worktree** (resume the agent) | Must operate on that agent's changes |

### Agent Classification

**Worktree-eligible** (modify source code: use worktree when parallel):
- `impl-agent`
- `debugger`
- `docs-and-cleanup`
- `test-validator`

**Never need worktree** (no source code changes):
- `Explore` (built-in)
- `Plan` (built-in)
- `theorycrafting`

### Merging Worktree Results

After worktree agents complete, deploy the `worktree-merger` agent to integrate their branches:
1. Collect all completed worktree branch names and their task descriptions
2. Determine merge order (respect dependency relationships: independent branches in any order, dependent branches in dependency order)
3. Spawn `worktree-merger` with the ordered branch list
4. If the merger escalates conflicts, resolve with user input before continuing
5. After merge completes cleanly, optionally run `test-validator` against the merged result
6. Then clean up the merged branches and their worktrees with the steps in the Git section of `~/.claude/CLAUDE.md`

## Agent Selection

| Agent | Use When | Skip When |
|-------|----------|-----------|
| Explore (built-in) | Unknown code, locating and reading the relevant code | Exact files already known |
| theorycrafting | Multiple approaches, architectural decisions | Approach obvious or user decided |
| Plan (built-in) | Multi-step implementation that needs phases | Single-file or trivial change |
| impl-agent | Code to write beyond a trivial change | No code changes, or a trivial change the orchestrator makes |
| test-validator | A change to shared behavior | Trivial change, or a check that can fail already covers it |
| debugger | Bug reproduction fails, systematic root cause needed | Simple/obvious bugs, typos |
| docs-and-cleanup | Validated impl needs doc/type updates | Trivial change |
| worktree-merger | After parallel worktree agents complete | No worktrees used, single agent |

## State Management

Plan in the chat. When the user approves a plan, the lead keeps it as one board memory node, `plan-<slug>`, until the work is done. No agent writes plan, checkpoint or deviation files in the repository.

| Place | Holds |
|-------|-------|
| The chat | The plan draft, the checkpoints and the approved deviations |
| `NEXT.md` on the board (`~/.claude/bin/board path next`) | The to-do items, the lane status and the decisions for the user |
| `memory/` on the board (`~/.claude/bin/board path memory`) | The shared project memory, the approved plans (`plan-<slug>`: requirements, goals, done-criteria, the safe way) and the debug notes of the debugger |
| `pings/` and the mailbox branches on the board | The agent communication |
| `handoffs/` on the board | A handoff that the user asks for |
| `.claude/agent-memory/<agent>/` | The learning of each agent from session to session |
