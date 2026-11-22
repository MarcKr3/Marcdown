Write a session handoff, so that a new session can continue the work.

Arguments: $ARGUMENTS

## Handoff location

Run `~/.claude/bin/board path next`.
- If the command gives a folder, `HANDOFF_DIR` is `<folder>/handoffs/` and `DEFAULT_HANDOFF` is `<folder>/handoffs/HANDOFF.md`. The board sync shares the handoff with the other computers.
- If the command fails, the board is not set up. Do the one-time project setup of `~/.claude/CLAUDE.md` first. Then run the command again.

Find the handoff mode from the arguments:

### Mode: `list`
If `$ARGUMENTS` is "list":
1. Look for `DEFAULT_HANDOFF`.
2. Look for `HANDOFF_DIR`, and list all `*.md` files in it.
3. Show a list of all handoffs with their names and dates.
4. Do nothing more. This mode only gives information.

### Mode: Named handoff
If `$ARGUMENTS` has a value and is not "list":
1. Use `$ARGUMENTS` as the handoff name.
2. Make the `HANDOFF_DIR` folder if it does not exist.
3. Write `HANDOFF_DIR/<name>.md` with the template `~/.claude/templates/HANDOFF.md`.
4. Set the **Name** field to `<name>`.

### Mode: Default handoff (no arguments)
If `$ARGUMENTS` is empty:
1. Write `DEFAULT_HANDOFF` with the template `~/.claude/templates/HANDOFF.md`.
2. Set the **Name** field to "default".

---

**The handoff is a short pointer, not a full history.** `NEXT.md`, the memory and the pings on the board keep the state. The handoff gives only:

1. The current task, in one sentence.
2. The next action, so that the new session knows what to do first.
3. The blockers and the open questions.
4. The reason for the handoff: context pressure, drift, end of the day or a change of task.

Do not copy information that `NEXT.md`, the memory or the pings already have. Keep the handoff short.
A new handoff replaces the old handoff with the same name. The handoff shows the state now. It is not a log.
