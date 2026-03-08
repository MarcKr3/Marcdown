Archive the current plan and start fresh.

1. **Determine scope:**
   - If `$ARGUMENTS` names a feature slug and `.planning/features/<slug>/PLAN.md` exists, archive the feature plan
   - If no arguments, check for all plans (`.planning/PLAN.md` and `.planning/features/*/PLAN.md`). If exactly one exists, use it. If multiple, list them and ask.
   - Otherwise, archive `.planning/PLAN.md`
2. If a plan exists in the determined scope:
   - Create the appropriate archive directory:
     - Project: `.planning/archive/PLAN-[timestamp].md`
     - Feature: `.planning/features/<slug>/archive/PLAN-[timestamp].md`
   - Also archive `CHECKPOINTS.md` and `DEVIATIONS.md` if they exist in the same scope
   - Report what was archived
3. If no plan exists in the determined scope, report that there's nothing to archive
