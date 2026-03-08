Create a session handoff for continuity.

Arguments: $ARGUMENTS

Determine the handoff mode based on arguments:

### Mode: `list`
If `$ARGUMENTS` is "list":
1. Check for `.planning/HANDOFF.md` (the default handoff)
2. Check for `.planning/handoffs/` directory and list all `*.md` files inside
3. Present a list of all available handoffs with their names and dates
4. Do nothing else — this is informational only

### Mode: Named handoff
If `$ARGUMENTS` is provided (and not "list"):
1. Use `$ARGUMENTS` as the handoff name
2. Create `.planning/handoffs/` directory if it doesn't exist
3. Write `.planning/handoffs/<name>.md` using the template from `~/.claude/templates/HANDOFF.md`
4. Set the **Name** field to `<name>`

### Mode: Default handoff (no arguments)
If `$ARGUMENTS` is empty:
1. Write `.planning/HANDOFF.md` using the template from `~/.claude/templates/HANDOFF.md`
2. Set the **Name** field to "default"

---

**This file is a thin pointer, NOT a full history.** All history lives in CHECKPOINTS.md, PLAN.md, and DEVIATIONS.md. The handoff only captures:

1. What is the current task right now? (one sentence)
2. What is the exact next action? (so the new session knows what to do first)
3. Any blockers or open questions?
4. Why the handoff is happening (context pressure, drift, end of day, task switch)

Do NOT duplicate information already in other .planning/ files. Keep this under 20 lines of content.
Every handoff fully replaces the previous one of the same name — this is always a snapshot of "right now", not a log.
