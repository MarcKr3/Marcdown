Start or continue a systematic debug session: $ARGUMENTS

**Worktree isolation (when another session is active):** Before you start, find out if this session is in a worktree. If it is not, find out if another session works on this repository. Examine `ListAgents` and `git worktree list`. If another session is active, use `EnterWorktree` with a name from the symptom. The user can override this.

1. Make a **session slug** from `$ARGUMENTS`: lowercase, hyphens for spaces, no special characters. For example, "Login timeout bug" becomes `login-timeout-bug`.
2. Get the memory folder with `~/.claude/bin/board path memory`. If the board is not set up, do the one-time project setup of `~/.claude/CLAUDE.md` first. Then continue.
3. Look for the memory node `debug-<slug>.md` in that folder.
   - If it exists, continue from its state. Read its hypotheses and its evidence.
   - If it does not exist, make it. Give it this frontmatter: `name: debug-<slug>`, a one-line `description` of the symptom, and `metadata.type: project`. Add one line to `MEMORY.md` with a link to the node and the date.
4. Launch the debugger agent with the symptom and the path of the node.
5. The debugger:
   - Records the symptoms.
   - Makes hypotheses.
   - Tests each hypothesis.
   - Writes its state to the node, in strict STE.
6. When the debugger finds the root cause, it writes a fix directive for the impl-agent.
7. When the bug is fixed, delete the node and its line in `MEMORY.md`.

**Parallel safety:** Each debug session has its own node, `debug-<slug>.md`. Many debug sessions can run at the same time without conflicts.
