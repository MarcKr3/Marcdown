# Team Design Framework — Reference

Load this file when planning agent team composition. Not needed for simple tasks.

## Agent Roster

| Agent | Role |
|-------|------|
| codebase-investigator | Locates relevant files/code sections with light context |
| code-analyser | Deep logic, dependency, and behavioral analysis of code |
| theorycrafting | Feasibility assessment, approach evaluation, coarse phasing |
| planning-agent | Detailed implementation plans: phases, tasks, dependencies |
| plan-checker | Validates plans against codebase reality before execution |
| impl-agent | Faithful code execution per plan directives |
| test-validator | Runs tests, validates implementations, reports results |
| debugger | Systematic debugging with persistent hypothesis tracking |
| docs-and-cleanup | Aligns docs, type hints, and cleans dead code post-implementation |
| team-leader | Multi-team orchestration, agent assignment, stop authority |
| team-communicator | Centralized cross-team communication hub |
| worktree-merger | Merges worktree branches after parallel agents complete |

## Pipeline Selection

| Task Type | Pipeline |
|-----------|----------|
| Simple bug fix | investigator -> analyzer -> impl-agent -> test-validator |
| Feature (clear requirements) | investigator -> code-analyser -> planning-agent -> impl-agent -> test-validator -> docs-and-cleanup |
| Architecture decision | investigator -> code-analyser -> theorycrafting |
| Complex feature (unclear approach) | investigator -> code-analyser -> theorycrafting -> planning-agent -> impl-agent -> test-validator -> docs-and-cleanup |
| Large-scale parallel changes | Full pipeline + team-leader for parallel execution |
| Debugging session | debugger -> impl-agent -> test-validator |
| Feature with plan validation | ...planning-agent -> plan-checker -> impl-agent... |

## Team Structure

| Condition | Structure |
|-----------|-----------|
| Linear dependency chain, ≤4 agents | Single team (you orchestrate) |
| Independent parallel workstreams | Multi-team (deploy team-leader) |
| Same task replicated N times | Homogeneous teams (deploy team-leader) |
| Cross-cutting changes, shared interfaces | Multi-team + team-communicator |

## Scaling Impl-Agents

Impl-agents map to **independent sub-tasks**, not phases.

| Signal | Decision |
|--------|----------|
| Single focused change | 1 impl-agent |
| Phase has N independent sub-tasks | N parallel impl-agents (1 per sub-task) |
| Multiple phases, each with sub-tasks | impl-agents per sub-task, respecting phase dependencies |
| Large repetitive task (e.g., 20 files) | Homogeneous team: divide evenly across impl-agents |
| Tightly coupled changes (shared state, ordering) | Fewer agents, sequential — avoid merge conflicts |

Default to generous parallelism. Respect team size limits (7 single-team, 14 multi-team).

## Worktree Isolation

### Session-Level Isolation (default — opt-out)

**All work-initiating commands** (`/new-feature`, `/new-project`, `/implement`, `/plan`, `/debug`) enter a worktree via `EnterWorktree` before doing any work. This is the **default behavior** — the user must explicitly opt out (e.g., "no worktree", "work in main", "skip worktree") to work directly on the main checkout.

This ensures that separate Claude Code tabs/sessions never conflict on the filesystem, even at the top level.

### Sub-Agent Isolation

When spawning agents that modify source code in parallel, use `isolation: "worktree"` on the Agent tool call. This gives each agent an isolated copy of the repository via `git worktree`, preventing filesystem conflicts. If the agent makes changes, its worktree path and branch are returned in the result for merging.

### When to Use Worktrees

| Scenario | Worktree? | Why |
|----------|-----------|-----|
| Parallel impl-agents on independent tasks | **Yes** | Prevents source code conflicts |
| Parallel impl-agents on tightly coupled code | No | Need shared state; run sequentially instead |
| Single impl-agent (no parallel work) | No | No conflict risk |
| Read-only agents (investigator, analyser, theorycrafting) | No | Don't modify files |
| Debugger running alongside implementation | **Yes** | May run commands that conflict |
| test-validator after worktree impl-agent | **Same worktree** (resume the agent) | Must validate against that agent's changes |
| docs-and-cleanup after worktree impl-agent | **Same worktree** (resume the agent) | Must operate on that agent's changes |

### Agent Classification

**Worktree-eligible** (modify source code — use worktree when parallel):
- `impl-agent`
- `debugger`
- `docs-and-cleanup`
- `test-validator`

**Never need worktree** (read-only or write only to `.planning/`):
- `codebase-investigator`
- `code-analyser`
- `theorycrafting`
- `planning-agent` (writes to `.planning/` only — already namespaced by feature)
- `plan-checker`
- `team-communicator`

### Merging Worktree Results

After worktree agents complete, deploy the `worktree-merger` agent to integrate their branches:
1. Collect all completed worktree branch names and their task descriptions
2. Determine merge order (respect dependency relationships — independent branches in any order, dependent branches in dependency order)
3. Spawn `worktree-merger` with the ordered branch list
4. If the merger escalates conflicts, resolve with user input before continuing
5. After merge completes cleanly, optionally run `test-validator` against the merged result

## Agent Selection

| Agent | Use When | Skip When |
|-------|----------|-----------|
| codebase-investigator | Unknown codebase, locating relevant code | Exact files already known |
| code-analyser | Need deep understanding of existing logic | Simple change, no complex interactions |
| theorycrafting | Multiple approaches, architectural decisions | Approach obvious or user decided |
| planning-agent | Multi-step implementation needing phasing | Single-file or trivial change |
| plan-checker | Complex multi-phase plans, unfamiliar codebase | Simple single-phase plans |
| impl-agent | Any code to write | No code changes needed |
| test-validator | After any implementation | User explicitly skips validation |
| debugger | Bug reproduction fails, systematic root cause needed | Simple/obvious bugs, typos |
| docs-and-cleanup | Validated impl needs doc/type updates | Trivial change |
| team-leader | Multiple parallel teams needed | Single-team work |
| team-communicator | Parallel teams with shared interfaces | Single team |
| worktree-merger | After parallel worktree agents complete | No worktrees used, single agent |

## State Management

Active work state in `.planning/` at the project root:

### Project-Level (singleton)

| File | Purpose | Owner |
|------|---------|-------|
| `PLAN.md` | Project-level plan with YAML frontmatter | planning-agent |
| `CHECKPOINTS.md` | Project-level task completion log | impl-agent |
| `DEVIATIONS.md` | Project-level plan deviation records | impl-agent |
| `REQUIREMENTS.md` | Project requirements (from `/new-project`) | orchestrator |
| `ROADMAP.md` | Multi-phase roadmap (from `/new-project`) | planning-agent |
| `HANDOFF.md` | Session continuity — default (thin pointer) | orchestrator |
| `handoffs/` | Named session handoffs (thin pointers) | orchestrator |
| `archive/` | Archived plans | any |

### Per-Feature (namespaced — parallel-safe)

| Path | Purpose | Owner |
|------|---------|-------|
| `features/<slug>/REQUIREMENTS.md` | Feature requirements with FREQ-IDs | orchestrator |
| `features/<slug>/CODEBASE.md` | Feature codebase map | codebase-investigator |
| `features/<slug>/PLAN.md` | Feature implementation plan | planning-agent |
| `features/<slug>/CHECKPOINTS.md` | Feature task completion log | impl-agent |
| `features/<slug>/DEVIATIONS.md` | Feature plan deviation records | impl-agent |
| `features/<slug>/archive/` | Archived feature plans | any |

### Per-Debug-Session (namespaced — parallel-safe)

| Path | Purpose | Owner |
|------|---------|-------|
| `debug/<slug>/DEBUG.md` | Debug session state | debugger |

Agent memory (`.claude/agent-memory/`) = cross-session learning. `.planning/` = current work state.
