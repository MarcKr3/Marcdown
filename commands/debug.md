Start or continue a systematic debug session: $ARGUMENTS

**Worktree isolation (default):** Before starting, check if this session is already in a worktree. If not, use `EnterWorktree` with a name derived from the symptom. Only skip if the user explicitly opts out.

1. Derive a **session slug** from `$ARGUMENTS` (lowercase, hyphens for spaces, strip special characters — e.g., "Login timeout bug" → `login-timeout-bug`)
2. Check if `.planning/debug/<slug>/DEBUG.md` exists
   - If yes: resume from where it left off, read existing hypotheses and evidence
   - If no: create `.planning/debug/<slug>/` directory and a new debug session using the template from `~/.claude/templates/DEBUG.md`
3. Launch the debugger agent with the symptom description
4. The debugger will:
   - Capture symptoms
   - Form hypotheses
   - Test systematically
   - Record all state to `.planning/debug/<slug>/DEBUG.md`
5. When root cause is found, produce a fix directive for impl-agent

**Parallel safety:** Each debug session is namespaced under `.planning/debug/<slug>/`. Multiple debug sessions can run concurrently without conflicts.
