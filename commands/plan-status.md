Report the current planning and implementation status.

Read and summarize from all scopes:

**Project-level:**
1. `.planning/PLAN.md` — current plan, phase, and status
2. `.planning/CHECKPOINTS.md` — completed tasks
3. `.planning/DEVIATIONS.md` — any plan deviations

**Per-feature** (scan `.planning/features/*/`):
4. Each feature's `PLAN.md`, `CHECKPOINTS.md`, `DEVIATIONS.md`

**Cross-cutting:**
5. `.planning/debug/*/DEBUG.md` — active debug sessions
6. `.planning/HANDOFF.md` — last session handoff notes (also check `.planning/handoffs/` for named handoffs)

Present a concise status overview showing what's done, what's in progress, and what's next — grouped by scope.
If no `.planning/` directory exists, report that no active plan is in progress.
