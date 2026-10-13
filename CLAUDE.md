# General

- Do not run web searches. Fetch a URL only when the user gives it.
- Do not use git to undo changes: no `checkout <file>`, `restore`, `reset --hard`, `clean`, discarding `stash`, or other commands that overwrite the working tree. They destroy uncommitted work. To revert, edit the files by hand and reverse only your own edits. If you do not know which edits are yours, ask.
- Do not commit unless the user asks.

# Mode

At the start of each conversation, before the first work step, ask with `AskUserQuestion` which mode applies: **Fast** or **Thorough**. Use that mode for the whole conversation until the user changes it. A subagent does not ask. It uses the mode that its brief names.

## Fast

The user tests the result on the device or by hand. The goal is a correct change with the shortest wait.

- Make the change yourself. Do not spawn agents, run workflows or hold review rounds unless the user asks. This rule overrides any default that starts agents, for example ultracode.
- Prove the change once, at the end: the build or compile check and the full unit suite, or the quick check of the project. When a rule in the model changes, update or add its unit test in the same change.
- Do not run mutation, rig batteries, new rig claims, ledgers or red-first reports unless the user asks.
- End with a short checklist for the user: what to do, and what a pass looks like.
- Write one checkpoint of five lines or fewer per change.

## Thorough

Scale the process to the risk:

- Trivial or single-file change: edit and verify it yourself, with no agents.
- Logic change: one impl-agent, test first.
- Unclear cause: the debugger first.
- Larger work: choose agents with `~/.claude/references/team-framework.md`.

Validate only a change to shared behavior, and examine that claim, preferably by mutation. Do not repeat checks that the implementer ran. Background agents report when they finish. Do not poll them or read their output files.

Write one checkpoint of ten lines or fewer per phase.

# Approval

Present a proposal and wait for approval before you start a plan, write code or spawn agents. One approval covers one change and its agents. In Fast mode, the proposal is a few lines.

Do not interpret the user's request. If a design choice is not clearly stated, ask with `AskUserQuestion` before you continue. A design choice changes behavior, appearance, wording or scope. Ask the same way before any deviation from a plan. Ask also about a surprise that changes scope or contradicts a user ruling.

# Quality

1. **Evidence before claims.** Run the check and read the output before you report. The check must be able to fail. A visual claim needs a rendering check, or in Fast mode the user's device check.
2. **Root cause before fix.** After two failed fixes, reproduce the fault in a check first.
3. **Test first** (Thorough). Write the test and see it fail, then write the code. Where no unit test reaches, make another check fail first. In Fast mode, update the tests in the same change instead.
4. **Scope before code.** For non-trivial work, state what you build, where, and what can break.
5. **Review before you report.** Read the request again and examine the diff.

# Records

Record a deviation only after the user approves it. Archive completed phases. Keep test output out of git. Comments give the reason in one or two sentences.

# Writing

For docs, comments and messages, use the `ste-writing` skill and lint with `~/.claude/skills/ste-writing/ste-lint.py`.

# Context

`/compact` frees space. `/handoff` and a new session reset behavior: use it at the end of a session, on a task switch, or when behavior drifts.
