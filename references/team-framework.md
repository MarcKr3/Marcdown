# Team Design Framework — Reference

Load this file when planning agent team composition. Not needed for simple tasks.

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

## State Management

Active work state in `.planning/` at the project root:

| File | Purpose | Owner |
|------|---------|-------|
| `PLAN.md` | Current plan with YAML frontmatter | planning-agent |
| `CHECKPOINTS.md` | Task completion log | impl-agent |
| `DEVIATIONS.md` | Plan deviation records | impl-agent |
| `DEBUG.md` | Active debug session state | debugger |
| `HANDOFF.md` | Session continuity — default (thin pointer) | orchestrator |
| `handoffs/` | Named session handoffs (thin pointers) | orchestrator |
| `archive/` | Previous plans and debug sessions | any |

Agent memory (`.claude/agent-memory/`) = cross-session learning. `.planning/` = current work state.
