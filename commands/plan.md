Create an implementation plan for: $ARGUMENTS

Follow this workflow:
1. Read the project's CLAUDE.md and any existing `.planning/` state
2. If the task is complex enough to warrant investigation, propose an agent pipeline (codebase-investigator -> code-analyser -> theorycrafting -> planning-agent)
3. If the task is straightforward, proceed directly with planning-agent
4. Write the plan to `.planning/PLAN.md` with proper YAML frontmatter
5. If `.planning/PLAN.md` already exists, archive it first to `.planning/archive/`
6. Present the plan for user approval before marking it active
