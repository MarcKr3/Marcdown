Show consolidated project status.

Gather and present:
1. **Git status**: current branch, uncommitted changes, recent commits
2. **Project plan**: from `.planning/PLAN.md` (phase, progress)
3. **Project checkpoints**: from `.planning/CHECKPOINTS.md` (completed tasks)
4. **Project deviations**: from `.planning/DEVIATIONS.md` (any divergences)
5. **Features**: scan `.planning/features/*/` for all feature workstreams:
   - For each feature: plan status, checkpoints, deviations
6. **Debug sessions**: scan `.planning/debug/*/DEBUG.md` for all active investigations
7. **Handoff notes**: from `.planning/HANDOFF.md` (default) and `.planning/handoffs/` (named handoffs)

Present as a concise dashboard. Skip sections where no data exists.
Group feature-level state under each feature heading.
