Create an implementation plan for: $ARGUMENTS

**Worktree isolation (default):** Before starting, check if this session is already in a worktree. If not, use `EnterWorktree` with a name based on the task. Only skip if the user explicitly opts out.

Follow this workflow:
1. Read the project's CLAUDE.md and any existing `.planning/` state
2. **Determine scope:**
   - If `$ARGUMENTS` starts with a feature slug matching `.planning/features/<slug>/`, create the plan at `.planning/features/<slug>/PLAN.md`
   - Otherwise, create at `.planning/PLAN.md` (project scope)
3. If the task is complex enough to warrant investigation, propose an agent pipeline (codebase-investigator -> code-analyser -> theorycrafting -> planning-agent)
4. If the task is straightforward, proceed directly with planning-agent
5. Write the plan to the scoped `PLAN.md` with proper YAML frontmatter
6. If a `PLAN.md` already exists in the target scope, archive it first to the scope's `archive/` directory
7. Present the plan for user approval before marking it active
