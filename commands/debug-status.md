Report the current debug session status.

1. If `$ARGUMENTS` names a session: read `.planning/debug/<slug>/DEBUG.md`
2. If no arguments: scan `.planning/debug/*/DEBUG.md` for all sessions
   - If one session exists, show its status
   - If multiple, list all with brief summaries
3. If no active sessions found, report that
4. For the selected session, summarize:
   - Bug description and severity
   - Hypotheses tested (with results)
   - Current hypothesis being investigated
   - Evidence collected so far
   - Whether a root cause has been found
