Archive the current plan and start fresh.

1. Check if `.planning/PLAN.md` exists
2. If yes:
   - Create `.planning/archive/` directory if needed
   - Move `PLAN.md` to `.planning/archive/PLAN-[timestamp].md`
   - Also archive `CHECKPOINTS.md` and `DEVIATIONS.md` if they exist
   - Report what was archived
3. If no plan exists, report that there's nothing to archive
