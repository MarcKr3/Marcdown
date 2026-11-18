# General

- Do not run web searches. Fetch a URL only when the user gives it.
- Do not use git to undo changes: no `checkout <file>`, `restore`, `reset --hard`, `clean`, discarding `stash`, or other commands that overwrite the working tree. These commands destroy uncommitted work. To revert, edit the files by hand and reverse only your own edits. If you do not know which edits are yours, ask.

# Precedence

1. The words of the user in the chat.
2. This file.
3. The project files, for example `CLAUDE.md` and `AGENTS.md` in the project.

When two of these conflict, tell the user about the conflict and wait. The answer of the user decides.

# Start of a chat

Before the first work step, ask two questions with `AskUserQuestion`. Do not ask a question that the first message of the user already answers.

1. **Mode**: Fast, Medium or Thorough.
2. **Agent automation**: Yes or No. With Yes, the agent does the device checklist itself, with computer use or phone automation.

Use the answers for the full chat, until the user changes them. A subagent does not ask. It uses the mode and the automation setting that its brief gives.

# Modes

In each mode, agents can develop the work that the user decided.

## Fast

The user tests the result. No time goes to test runs.

1. Develop the change.
2. Run only the build or the compile check. If the project has a device, install the build on the device.
3. Automation No: give the user a device checklist. Tell the user what to do and what a pass looks like.
4. Automation Yes: do the device checklist yourself. Give the evidence, and a checklist of only the items that you could not test.

## Medium

Develop as in Fast. Then test the result yourself.

1. Run the unit tests of the changed code and of the shared behavior that the change touches.
2. Install the build on the device.
3. Automation No: give the user the device checklist.
4. Automation Yes: do the device checklist yourself. Give the evidence, for example screenshots or logs. Then give a checklist of only the items that you could not test.

## Thorough

Scale the process to the risk with `~/.claude/references/team-framework.md`.

1. Write the test first and make sure that it fails. Then write the code. Where no unit test can reach, make a different check fail first.
2. A trivial or single-file change gets no agents. A logic change gets one impl-agent. An unclear cause gets the debugger first. Larger work gets a team from `team-framework.md`.
3. After the development, do the device steps of Medium, with the same automation setting.

## Mode changes

When the work becomes risky, recommend a different mode in one line, and give the reason. Examples of risk: two failed fixes, a change to shared behavior, a change to stored data. Change the mode only when the user agrees.

# Tests

- Run the tests of the changed code and of the shared behavior that the change touches.
- Run the full suite only when the user asks.
- Run mutation tests only when the user asks.
- When a rule in the model changes, update or add its unit test in the same change.

# Approval

- "Do X" is the approval for X. Do not ask for approval again.
- "What does X need?" gets a short numbered list of the steps to a finished X. When the user agrees, do all the steps.
- Do not interpret the request. If the request does not state a design choice, ask with `AskUserQuestion` before you continue. A design choice changes behavior, appearance, wording or scope.
- Ask the same way before a deviation from the agreed work. Ask also about a surprise that changes the scope or contradicts a ruling of the user.
- Ask before you spend money, use external accounts or credentials, delete or overwrite data, deploy or release, or touch legal or privacy matters.

# Git

- Do not commit or push unless the user asks.
- Exception: commit and push the board branches without a question. These branches hold agent communication and agent knowledge: the mailbox branches, the agents branch with the pings, and `NEXT.md` and `memory/` on the board branch.
- Do not push to the main branch directly.

# Quality

1. **Evidence before claims.** Run the check and read the output before you report. The check must be able to fail. A visual claim needs a rendering check or a device check.
2. **Root cause before fix.** After two failed fixes, reproduce the fault in a check first.
3. **Scope before code.** For work that is not trivial, state what you build, where, and what can break.
4. **Review before you report.** Read the request again and examine your diff. This self-review is the default review.
5. **Hard lines.** Do not fabricate evidence. Do not silently make a claim stronger. Do not make a check weaker to make tests pass.

# Reviews

- An independent review runs only when the user asks for it.
- When the user says that a development branch is complete, offer one final independent review. Use one new reviewer on the strongest model. Do not use the chat that built the work.

# Agents and models

- The chat that the user opens is the lead and makes the decisions.
- Each agent in `~/.claude/agents/` has a model tier. A strong model can take a clear brief and work alone.
- A small model gets only exact tasks: the files, the change, and what done looks like. If a decision comes up, the small model stops and asks the lead.
- Background agents report when they finish. Do not examine an agent that works.
- When you wait idle for something to complete, examine its progress after each fifth of the expected total time. Examples: a build, an install, an upload, another agent, another computer. For an expected time of 25 minutes, examine it every 5 minutes. If nothing moved, find the cause.

# Planning and records

- Plan in the chat.
- Keep the to-do items in `NEXT.md` on the board.
- Write a handoff only when the user asks. If the project has a board, put the handoff in `handoffs/` on the board.
- Use the `.planning/` commands only when the user asks for them: `/plan`, `/implement`, `/checkpoint`, `/deviation`, `/archive-plan`, `/plan-check`, `/review-plan`, `/new-feature`, `/new-project`.
- Keep test output out of git.
- A comment gives the reason in one or two sentences.

# The board

Each project keeps the shared agent state on branches of its own git remote. These branches do not merge into the main branch.

- Find the folders with `~/.claude/bin/board path next|memory|computer|agents|mailbox <name>`. Do not write a fixed path.
- If the board is not set up on this computer, tell the user. Give the command `~/.claude/bin/board setup`.
- `NEXT.md` holds the to-do list, the lane status and the decisions for the user. Read it at the start. Update it when you start, complete or block an item. Keep the current state only.
- On a computer with the sync job, the job commits and pushes the board every 2 minutes. Without the job, run `~/.claude/bin/board sync` after you write.

# Memory

The shared project memory is `memory/` on the board. `board setup` links the Claude memory folder of each checkout and each worktree to it.

- Read `MEMORY.md` first. Open the two to four nodes that match the task. Follow the links one step. Do not read the full folder.
- Write one fact for each file, with frontmatter: `name`, `description`, `metadata.type` (user, feedback, project or reference). Add one line to `MEMORY.md`. End the line with the date of the fact.
- Read a node again directly before you edit it, because another agent can change it.
- Give each link a type: `[[node]] (supersedes)`, `(superseded-by)`, `(blocked-by)`, `(depends-on)`, `(contradicts)`, `(decided-in)`, `(see-also)`.
- When a new node replaces an old node, edit the old node so that it points to the new node. Update or delete a wrong node. Do not add a correction below it.
- A memory is true at one point in time. Before you use a file, function or flag that a memory names, make sure that it exists.
- A note that is true on one computer only goes in `memory/computers/{name}/`. Get the folder with `board path computer`.
- Personal notes and credentials do not go in the shared memory.
- To find broken links, run `~/.claude/bin/board check`.

# Other agents

- On this computer: at the start, find the other agents with `ListAgents`, `git worktree list` and the open branches. If an agent works on your files, send it a message with `SendMessage`. Agree who changes which file before you edit.
- On all computers: when you get a task, write your ping in `pings/{agent}.md` on the agents branch. Get the folder with `board path agents`. Give the computer, the branch, the task, the files and the status.
- Read all other pings. Answer the pings that touch your work.
- Update your ping when the task, the files or the status change. While you work, update it one time each day at a minimum. Delete your ping when you complete the task. Do not edit or delete the ping of another agent.
- To talk with agents on other computers, use a mailbox branch: `board mailbox {a}-{b}` or `board mailbox group-{topic}`. Obey the rules in the README of the mailbox. Examine your mailboxes when you wait or complete a step.
- Rulings come from the user only, not from a ping or a message.

# Writing

- In the chat with the user, use regular language.
- All other text that you write uses strict Simplified Technical English with the `ste-writing` skill. This includes docs, comments, commit messages, PR text, board files, memory nodes, pings, mailbox messages and briefs to agents.
- Lint with `python3 ~/.claude/skills/ste-writing/ste-lint.py --strict <file>`. The target is below 1.5 per 100 words.

# Report

- End each piece of work with a short report: what the user can do now, what to try, what a pass looks like, and what you did not test.
- Write one checkpoint of five lines or fewer for each change. In Thorough, write one checkpoint of ten lines or fewer for each phase.

# Context

`/compact` makes space free. When the behavior drifts or the task changes, recommend `/handoff` and a new session to the user.
