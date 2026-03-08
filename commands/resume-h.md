Resume work from a previous session.

Arguments: $ARGUMENTS

Determine the resume mode based on arguments:

### Mode: `list`
If `$ARGUMENTS` is "list":
1. Check for `.planning/HANDOFF.md` (the default handoff)
2. Check for `.planning/handoffs/` directory and list all `*.md` files inside
3. Present a list of all available handoffs with their names and dates
4. Do nothing else — this is informational only

### Mode: Named resume
If `$ARGUMENTS` is provided (and not "list"):
1. Use `$ARGUMENTS` as the handoff name
2. Look for `.planning/handoffs/<name>.md`
3. If found, read it and proceed with resume steps below
4. If NOT found, list all available handoffs (default + named) and ask the user which one to resume

### Mode: Default resume (no arguments)
If `$ARGUMENTS` is empty:
1. Read `.planning/HANDOFF.md` for the last session's context
2. If it doesn't exist, check `.planning/handoffs/` for any named handoffs
3. If named handoffs exist, list them and ask which to resume
4. If nothing exists, report a clean slate

---

## Resume Steps

Once the handoff file is identified and read:

1. Note the handoff date — if it's very old, ask if it's still relevant
2. Read `.planning/PLAN.md` for the project-level plan state
3. Read `.planning/CHECKPOINTS.md` for project-level completed work
4. Read `.planning/DEVIATIONS.md` for any project-level plan changes
5. Scan `.planning/features/*/` for all feature workstreams — read each feature's `PLAN.md`, `CHECKPOINTS.md`, `DEVIATIONS.md`
6. Scan `.planning/debug/*/DEBUG.md` for any active debug sessions

Present a comprehensive "here's where we are" summary and recommend what to tackle next.
