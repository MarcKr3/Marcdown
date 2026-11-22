Review recent changes against the plan: $ARGUMENTS

1. **Scope:** the files that `$ARGUMENTS` names. If `$ARGUMENTS` names no files, use the recent changes.
2. Get the goals, the done-criteria and the safety points from the plan node `plan-<slug>.md` in the board memory (`~/.claude/bin/board path memory`). Get the open items from `NEXT.md` (`~/.claude/bin/board path next`). If no plan node exists, use the plan in the chat. If the board is not set up, tell the user and give the command `~/.claude/bin/board setup`.
3. Read the git diff or the recent commits. Find what the change does.
4. Compare the change with the plan:
   - Does the code reach the goals by their done-criteria?
   - Does the code respect the safety points of the plan?
   - Is a requirement missing?
   - Does the code differ from the plan without an approved deviation?
5. Report the result and each gap.

The orchestrator does the review itself or launches agents, for example the built-in Explore agent. The scope and the complexity decide.
