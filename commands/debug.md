Start or continue a systematic debug session: $ARGUMENTS

1. Check if `.planning/DEBUG.md` exists with an active session
   - If yes: resume from where it left off, read existing hypotheses and evidence
   - If no: create a new debug session using the template from `~/.claude/templates/DEBUG.md`
2. Launch the debugger agent with the symptom description
3. The debugger will:
   - Capture symptoms
   - Form hypotheses
   - Test systematically
   - Record all state to `.planning/DEBUG.md`
4. When root cause is found, produce a fix directive for impl-agent
