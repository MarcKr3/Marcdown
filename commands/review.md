Review recent changes against plan intent: $ARGUMENTS

1. **Determine scope:**
   - If `$ARGUMENTS` starts with a feature slug matching `.planning/features/<slug>/`, use feature scope
   - Otherwise, use project scope
2. Read the scoped `PLAN.md` for the original intent and exit criteria
3. Check git diff or recent commits to see what was actually implemented
4. Compare implementation against plan:
   - Does the code achieve the stated objectives?
   - Were any requirements missed?
   - Are there deviations not documented in the scoped `DEVIATIONS.md`?
5. Report alignment status and any gaps found
