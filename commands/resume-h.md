Resume work from a previous session.

Arguments: $ARGUMENTS

## Handoff location

Run `~/.claude/bin/board path next`.
- If the command gives a folder, the project has a board. Then `HANDOFF_DIR` is `<folder>/handoffs/` and `DEFAULT_HANDOFF` is `<folder>/handoffs/HANDOFF.md`. The board sync shares the handoff with the other computers.
- If the command fails, `HANDOFF_DIR` is `.planning/handoffs/` and `DEFAULT_HANDOFF` is `.planning/HANDOFF.md`.

Determine the resume mode based on arguments:

### Mode: `list`
If `$ARGUMENTS` is "list":
1. Check for `DEFAULT_HANDOFF` (the default handoff)
2. Check for `HANDOFF_DIR` directory and list all `*.md` files inside
3. Present a list of all available handoffs with their names and dates
4. Do nothing else — this is informational only

### Mode: Named resume
If `$ARGUMENTS` is provided (and not "list"):
1. Use `$ARGUMENTS` as the handoff name
2. Look for `HANDOFF_DIR/<name>.md`
3. If found, read it and proceed with resume steps below
4. If NOT found, list all available handoffs (default + named) and ask the user which one to resume

### Mode: Default resume (no arguments)
If `$ARGUMENTS` is empty:
1. Read `DEFAULT_HANDOFF` for the last session's context
2. If it does not exist, check `HANDOFF_DIR` for any named handoffs
3. If named handoffs exist, list them and ask which to resume
4. If nothing exists, report a clean slate

---

## Resume Steps

Once the handoff file is identified and read:

1. Note the handoff date — if it's very old, ask if it's still relevant
2. Read `.planning/PLAN.md` for the project-level plan state
3. Read `.planning/CHECKPOINTS.md` for project-level completed work
4. Read `.planning/DEVIATIONS.md` for any project-level plan changes
5. If the project has a board, read `NEXT.md` on the board (`~/.claude/bin/board path next`) for the open to-do items.
6. Scan `.planning/features/*/` for all feature workstreams — read each feature's `PLAN.md`, `CHECKPOINTS.md`, `DEVIATIONS.md`
7. Scan `.planning/debug/*/DEBUG.md` for any active debug sessions

Present a comprehensive "here's where we are" summary and recommend what to tackle next.
