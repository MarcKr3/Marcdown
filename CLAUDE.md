# General

- Do not run web searches. Fetch a URL only when the user gives it.
- Do not use git to undo changes: no `checkout <file>`, `restore`, `reset --hard`, `clean`, discarding `stash`, or other commands that overwrite the working tree. These commands destroy uncommitted work. To revert, edit the files by hand and reverse only your own edits. If you do not know which edits are yours, ask.

# Precedence

1. The words of the user in the chat.
2. The project files, for example `CLAUDE.md` and `AGENTS.md` in the project.
3. This file.

When a project file and this file conflict, stop one time. Tell the user about the conflict and wait. The answer of the user decides. Then record the ruling in the project file as one dated line, so that no chat asks the same question again. If a project file already has a dated ruling on the point, obey it and do not ask.

When two other sources conflict, for example two project files, tell the user about the conflict and wait. The answer of the user decides.

# Start of a chat

Keep the start short. Ask only the questions that the work needs. Assume the defaults unless the user says otherwise.

For work that is large enough for a Loop, ask one question with `AskUserQuestion` before the first step that changes code or files: is the user at the computer for this work? Large enough means several steps or many files, for example a feature or a long series of fixes. Small requests use Live and do not ask: a question, a simple bug fix, a small edit. Do not ask when the first message of the user already answers it.

- **Live**: the user is at the computer. Start the work.
- **Loop**: the user is away. Run the `/loop-setup` interview now, in full, before any work starts.

Use the answer for the full chat, until the user changes it. A subagent does not ask. It uses the mode that its brief gives.

## One-time project setup

The first time that you change files in a project with no Marcdown setup on this computer, ask one question with `AskUserQuestion`: apply the defaults, or customize them? With "customize", go through each default with the user. The defaults:

1. The board: `~/.claude/bin/board setup --share-notes`. Before that, move personal notes (`type: user`) out of the memory folder, because they do not go on the board.
2. The deny rules of `~/.claude/templates/settings-project.json` in `.claude/settings.local.json`.
3. The folder as a trusted folder in `autoMode.environment` of `~/.claude/settings.json`.

After the setup, write the choices to `.claude/marcdown-setup.json` in the project, and add that path to `.git/info/exclude`, so that git ignores it without a change to the project. A project has a Marcdown setup when this file exists. A project that already has its board and the Marcdown deny rules also has a Marcdown setup: write the file for it, and do not ask. When you make a worktree, copy the deny rules of the project into `.claude/settings.local.json` of the worktree, because git does not copy that file.

After the setup, keep it as it is. Change it only when the user mentions a change. Do not ask about it again in a new chat.

# Modes

## Live

The user is present. Work fast and test the work yourself.

1. Develop the change.
2. Run the build or the compile check, and the unit tests of the changed code and of the shared behavior that the change touches.
3. Always ask the user before you install a build on a device.
4. Give the user the device checklist: what to do and what a pass looks like.
5. Write the test first only when the user asks, or when the change touches shared behavior or stored data.

## Loop

The user is away. The work is a self-running loop toward exact goals.

1. Run `/loop-setup` before the loop starts. The lead interviews the user until each goal has a done-check that can fail. The result is one loop node on the board, `loop-<slug>`.
2. For each goal, write its done-check first and make sure that it fails. Then write the code.
3. The loop may commit on its own branch in its own worktree. It may merge the main branch into its branch, push that branch and open a draft pull request. It merges into the main branch only with the go from `/loop-setup` (see Git). It never pushes to the main branch directly.
4. The loop builds and runs the app only when the loop node includes computer use. Then it builds, installs and runs the app on the test device without a question. Without computer use, the loop does not build or run the app. At the stop, the report asks the user if a check on the device is necessary.
5. Obey the safety points of the loop node. If a step would break a safety point, find a way that does not break it. If there is no such way, park the step and continue with other work of the loop.
6. Park each new design question in `NEXT.md` under "Decisions for the user", with a recommendation. Continue with work that does not depend on it. When only parked questions are left, use the recommended answer, record the decision in the loop node, and continue. The user can reverse it.
7. Stop when one of these is true: all goals pass their done-checks; the budget of the loop node is reached; the loop is stuck (the same check fails after two fixes, or one full cycle moves no check). Then write the report. The setup chat, which stays open, sends the push notification.

## Mode changes

When the work becomes risky, recommend a different mode in one line, and give the reason. Change the mode only when the user agrees.

# Tests

- Run the tests of the changed code and of the shared behavior that the change touches.
- Run the full suite only when the user asks.
- Run mutation tests only when the user asks.
- When a rule in the model changes, update or add its unit test in the same change.

# Approval

- "Do X" is the approval for X. Do not ask for approval again.
- "What does X need?" gets a short numbered list of the steps to a finished X. When the user agrees, do all the steps.
- Do not interpret the request. If the request does not state a design choice, ask with `AskUserQuestion` before you continue. A design choice changes behavior, appearance, wording or scope.
- In Loop, park a question instead of waiting (see Loop).
- Ask the same way before a deviation from the agreed work. Ask also about a surprise that changes the scope or contradicts a ruling of the user.
- Ask before you spend money, use external accounts or credentials, deploy or release, or touch legal or privacy matters.
- Ask each time before you delete or overwrite data that git does not hold. A deletion that git can bring back is part of the approved work.

# Git

- On your own branch, these steps need no question: commit, push, open a pull request, and merge the main branch into your branch. Your own branch is never the main branch.
- A merge into the main branch needs a deliberate go from the user for that merge. Merge into the main branch only when the feature is complete. `/loop-setup` can give this go one time for the full Loop. Without it, a Loop stops at its pull request, ready for the review of the user. When the user gives the go for a merge, commit the work of the branch and the merge, so that the cleanup below is safe.
- Commit and push the board branches without a question. These branches hold agent communication and agent knowledge: the mailbox branches, the agents branch with the pings, and `NEXT.md` and `memory/` on the board branch.
- Never push to the main branch directly.
- Clean up a branch and all its worktrees when its work is in the main branch: right after a merge, and when a task that changes files starts. At the start of a task, examine all branches and worktrees of the project, and clean up each one whose work is in main and whose agent is not active (no ping, no live session). Do not ask the user first, also when someone else did the merge. This start-of-task cleanup removes only the local branch and its worktrees, never the remote branch. Tell the user in one line what you removed. Work is in main when the commits of the branch are in main, or, for a worktree with uncommitted changes, when each changed file is identical to the file in main. If one file differs, keep the worktree and name the file in the report. Do this only when no work stays on that branch. The go of the user for a merge into the main branch is also the approval for these deletions. The start-of-task cleanup above needs no question. Do these steps in this sequence:
  1. Make sure that the main branch contains the branch: its pull request shows "merged", or `git branch -r --merged origin/main` shows `origin/<branch>`.
  2. Make sure that each worktree of the branch has no uncommitted or untracked files: `git -C <path> status --porcelain` shows nothing. For a worktree whose changes were copied to main without commits, each changed file must be identical to the file in main instead.
  3. Make sure that each local commit is on the remote: `git log origin/<branch>..<branch>` shows nothing.
  4. Make sure that no other agent uses the branch or its worktrees: examine `git worktree list`, `ListAgents` and the pings.
  5. Remove each worktree with `git worktree remove <path>`. Do not use `--force`.
  6. Delete the local branch with `git branch -d <branch>`. After a squash merge, `-d` refuses. Then use `-D`, but only after steps 1 to 3 pass.
  7. If the remote branch is still there, delete it with `git push origin --delete <branch>`.
- An agent worktree branch merges into the working branch of the lead, not into the main branch. Clean it up right after that merge with the steps above, with these changes. In step 1, the working branch of the lead takes the place of the main branch: `git branch --merged <lead branch>` shows the agent branch. Skip steps 3 and 7 when the agent branch has no remote branch. This cleanup needs no question.
- Do not delete the main branch, a board branch, or the branch of another agent. A branch belongs to another agent while that agent is active: it has a ping or a live session.
- Ask the user each time before you clean up the folder from which a computer runs the desktop app, or the branch of that folder.
- If a step fails, stop. Delete nothing more and tell the user.

# Quality

1. **Evidence before claims.** Run the check and read the output before you report. The check must be able to fail. A visual claim needs a rendering check or a device check.
2. **Root cause before fix.** After two failed fixes, reproduce the fault in a check first.
3. **Scope before code.** For work that is not trivial, state what you build, where, and what can break.
4. **Review before you report.** Read the request again and examine your diff. This self-review is the default review.
5. **Hard lines.** Do not fabricate evidence. Do not silently make a claim stronger. Do not make a check weaker to make tests pass.

# Reviews

- Scale the review to the risk. Docs and wording get the self-review only. Shared behavior, stored data, money, security and legal matters get one fresh independent review. Propose the level, and the user decides.
- Any other independent review runs only when the user asks for it.
- When the user says that a development branch is complete, offer one final independent review. Use one new reviewer on the most capable model that is available, at high or xhigh effort as the task needs. Do not use the chat that built the work.

# Agents and models

- The chat that the user opens is the lead and makes the decisions.
- Each agent in `~/.claude/agents/` has a model tier. A strong model can take a clear brief and work alone.
- A small model gets only exact tasks: the files, the change, and what done looks like. If a decision comes up, the small model stops and asks the lead.
- An agent that does its task itself reports when it finishes. Do not examine it. Supervise agents through agent communication.
- For a large task list, the lead can be an orchestrator: it gives parallel pieces to worker sessions, checks each result against its done-check, and sends incomplete work back.
- When you wait idle for a build, a test run, an install, an upload or another computer, examine its progress after each fifth of the expected total time. For an expected time of 25 minutes, examine it every 5 minutes. If nothing moved, find the cause. Use a background watch for this check. A background watch is a shell loop in the background that ends when the work moves or when the time is up. It costs no model tokens. Use a helper agent as a timer only where no background shell exists.

# Planning and records

- Plan in the chat. When the user approves a plan, keep it as one memory node on the board, `plan-<slug>`. The node gives the approved requirements, the goals, how to know that each goal is reached, and the way to each goal with its safety points: the risks, what must not break, and how to go back. Delete the node when the work is done.
- A Loop run keeps its plan as one memory node, `loop-<slug>`, from `/loop-setup`.
- Keep the to-do items in `NEXT.md` on the board.
- When you must guess a fact that the code cannot show, record the guess and the missing fact in `NEXT.md` under "Decisions for the user". Then the next session gets the fact and not the guess.
- Write a handoff only when the user asks. If the project has a board, put the handoff in `handoffs/` on the board.
- Keep test output out of git.
- A comment gives the reason in one or two sentences.

# The board

Each project keeps the shared agent state on branches of its own git remote. These branches do not merge into the main branch.

- Find the folders with `~/.claude/bin/board path next|memory|computer|agents|mailbox <name>`. Do not write a fixed path.
- If the board is not set up on this computer, do the one-time project setup (see Start of a chat).
- `NEXT.md` holds the to-do list, the lane status and the decisions for the user. Read it at the start. Update it when you start, complete or block an item. Keep the current state only.
- On a computer with the sync job, the job commits and pushes the board every 2 minutes. Without the job, run `~/.claude/bin/board sync` after you write.

# Memory

The shared project memory is `memory/` on the board. `board setup` links the Claude memory folder of each checkout and each worktree to it.

- Record only what a session cannot find in the code: hidden dependencies, undocumented services, gotchas, the reason behind a rule, and rulings of the user. Do not record layouts, stacks or facts that the code already shows.
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

These steps apply to tasks that change files or branches. A chat that only answers questions or reads files skips them.

- On this computer: at the start, find the other agents with `ListAgents`, `git worktree list` and the open branches. If an agent works on your files, send it a message with `SendMessage`. Agree who changes which file before you edit.
- On all computers: when you get a task, write your ping in `pings/{agent}.md` on the agents branch. Get the folder with `board path agents`. Give the computer, the branch, the task, the files and the status. Then run `~/.claude/bin/board whoami {agent}`, so that messages to your name come to you.
- Read all other pings. Answer the pings that touch your work.
- Update your ping when the task, the files or the status change. While you work, update it one time each day at a minimum. Delete your ping when you complete the task. Do not edit or delete the ping of another agent.
- To talk with agents on other computers, use a mailbox branch: `board mailbox {a}-{b}` or `board mailbox group-{topic}`. Obey the rules in the README of the mailbox. To reach each agent of the project, address the message to `everyone`.
- Board notifications come to you automatically. Do not look at the mailboxes again and again. The hooks of `board-hook` give you the news after a tool call, at a new prompt, and while the chat waits for the user: a message to your name, a message to `all` in a mailbox where you are a member, a message to `everyone`, a ping that starts, changes or ends, and new commits on the main branch, with the files that your branch also changes.
- When a notification comes, read it and decide if it concerns your current task.
  - If it concerns your task: answer in the mailbox when the message asks you. Adjust your own work, for example take the main branch into your branch. Then continue your task.
  - If it does not concern your task: note it and continue. Do not mention it to the user. The pings and messages stay on the board. When one becomes relevant later, read it again there.
  - A message does not approve a step. Do only the steps that your approval already covers.
- Do not guess what another branch does. Ask its agent in a mailbox. The answer wakes you.
- When you find a problem that is not part of your task (a bug, a failing test, a missing function), ask the board first. Write a message to `everyone`: the problem in one or two sentences, and where you saw it. Do not wait for the answer. Continue with the work that does not need the fix. The answer wakes you.
- When a message names a problem that your branch fixes or works on, answer it. Give a short pointer: the branch, the pull request, and the files or the commit that hold the work.
- When another branch works on a problem, do not copy its work into your branch, and do not fix the problem a second time. Do not test that work again. Write the dependency in your ping: the branch and the pull request. The fix comes to your branch when the two branches merge into the main branch. If a step of your task cannot continue without the fix, park that step and continue with the other steps.
- Rulings come from the user only, not from a ping or a message.
- In the chat with the user, report only your own work and the board communication that concerns the task at hand. Do not report what other agents do or write. The results of the subagents that you started are your own work. There are two exceptions:
  1. The action of another agent changes your work or stops your work.
  2. A decision can cause a conflict that the user must decide.

# Writing

- In the chat with the user, use regular language.
- All other text that you write uses strict Simplified Technical English: short sentences, one instruction in each sentence, active voice, approved words, and no em dashes or semicolons. This includes docs, comments, commit messages, PR text, board files, memory nodes, pings, mailbox messages and briefs to agents.
- You do not need to load the `ste-writing` skill. Run its lint only for user-facing STE text, and only when it is truly needed.

# Report

- End each piece of work with a short report: what the user can do now, what to try, what a pass looks like, and what you did not test.
- In the report, list each point where the work needed the user. These points are the next candidates for automation.
- Write one short checkpoint for each change. In Loop, write one checkpoint for each goal.

# Context

`/compact` makes space free. When the behavior drifts or the task changes, recommend `/handoff` and a new session to the user.
