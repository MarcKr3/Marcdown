Validate the current plan against codebase reality.

1. **Determine scope:**
   - If `$ARGUMENTS` names a feature slug and `.planning/features/<slug>/PLAN.md` exists, validate the feature plan
   - If no arguments, check for all plans (`.planning/PLAN.md` and `.planning/features/*/PLAN.md`). If exactly one exists, use it. If multiple, list them and ask.
   - Otherwise, validate `.planning/PLAN.md`
2. If no plan exists in the determined scope, report that there's nothing to validate
3. Launch the plan-checker agent to validate the plan
4. Report validation results: APPROVED, REVISIONS NEEDED, or REJECTED
5. If revisions needed, suggest sending the plan back to planning-agent
