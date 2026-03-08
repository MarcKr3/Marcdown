Execute implementation from the current plan: $ARGUMENTS

**Worktree isolation (default):** Before starting, check if this session is already in a worktree. If not, use `EnterWorktree` with a name based on the plan scope (e.g., the feature slug or `project-impl`). Only skip if the user explicitly opts out.

1. **Determine plan scope:**
   - If `$ARGUMENTS` names a feature slug and `.planning/features/<slug>/PLAN.md` exists, use feature scope (paths under `.planning/features/<slug>/`)
   - If no feature match, use project scope (paths under `.planning/`)
   - If no arguments: check for all active plans (`.planning/PLAN.md` and `.planning/features/*/PLAN.md`). If exactly one exists, use it. If multiple, list them and ask which to implement.
2. Read the scoped `PLAN.md` to understand the full plan
3. Read the scoped `CHECKPOINTS.md` to see what's already done
4. Determine which phase/task to execute next (or use any remaining arguments as task specifier)
5. Propose the appropriate agent pipeline for execution
6. Impl-agents should follow the Commit Protocol, Checkpoint Protocol, and Deviation Protocol
7. After execution, update the scoped `CHECKPOINTS.md` and the plan frontmatter
