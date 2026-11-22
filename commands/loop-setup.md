Set up a Loop run: interview the user on the goals before the user goes away: $ARGUMENTS

You lead the setup of a Loop. In a Loop, the user is away and the work runs on its own toward exact goals. The loop can run without the user only when each goal is exact and each goal has a check that can fail. Ask until each part is exact.

**Rules for the questions:**
- Ask with `AskUserQuestion`, up to 4 questions in each call.
- Do one part at a time. Wait for the answers.
- Give a recommendation for each question. Put it first, with "(recommended)" in its label.
- Do not ask about a topic that `$ARGUMENTS`, an answer or a document already covers.
- If an answer is not exact, ask again.

## 0. Before the interview

1. Get the board folders with `~/.claude/bin/board path next` and `~/.claude/bin/board path memory`. If the board is not set up, do the one-time project setup of `~/.claude/CLAUDE.md` first. Then continue.
2. Read `NEXT.md` and `MEMORY.md` on the board. Open the memory nodes that match the task.
3. If a plan node `plan-<slug>` exists for this work, use its requirements, goals and safety points as the start of the interview.

## 1. Goals

For each goal, get:
- The goal in one sentence.
- Its done-check: a command, a test, a build, a screenshot assertion or another check that can run without the user.
- The pass condition of the check, for example "exit code 0" or "the test X passes".

The loop runs each done-check first and makes sure that it fails. A goal with no check that can fail is not ready. Help the user find a check, or move the goal out of the loop.

## 2. Non-goals and off-limits areas

Get what the loop must not do, and the files, systems and data that it must not touch.

## 3. Safety points

Get what must not break, and how to go back from each step. Examples: "the existing users stay logged in", "go back by reverting the commit on the loop branch".

The loop obeys each safety point. If a step would break one, the loop finds a way that does not break it. If there is no such way, the loop parks the step and continues with other work.

**Sandbox.** Offer the OS sandbox for this loop. It is on by default. With the sandbox, shell commands and their child processes reach only the allowed folders and hosts. Ask which more folders and hosts the loop needs. The default list:
- Write: the loop worktree, the git folder of the main checkout (a worktree keeps its commits there, find it with `git rev-parse --git-common-dir`), the board folders beside the project (`<project>.roadmap`, `<project>.agents`, `<project>.mailbox-group-loops`), and the temporary folder. If the remote is a local folder, add it too.
- In the sandbox, push with `git push origin loop-<slug>`, not with `git push -u`: the sandbox does not let git write its config file.
- Network: `github.com` and the package registries of the project.

The sandbox does not cover the Read, Edit and Write tools of Claude, MCP servers or hooks. The deny rules still cover those.

## 4. Loop engine

Recommend one engine for this task, and ask the user to choose:
- **Local loop session**: a fresh background Claude session on this computer, started inside the loop worktree. It keeps the device and the local tools in reach. Recommend it when the work needs a device or local tools. It runs in auto mode: the deny rules, the sandbox and the verify hook still apply, and nobody has to answer a prompt.
- **Cloud sessions**: each task on a fresh, isolated machine with a clean clone. No local devices. Recommend it when the work needs no device and touches secrets on this computer.
- **Workflow**: many agents in phases. It uses many tokens. Use it only with the explicit yes of the user.

## 5. Budget and stop conditions

Get the budget: the maximum time and the maximum tokens. The loop stops when one of these is true:
- All goals pass their done-checks.
- The budget is reached.
- The loop is stuck: the same check fails after two fixes, or one full cycle moves no check.

## 6. Parked questions

Tell the user how the loop handles a new design question. It parks the question in `NEXT.md` under "Decisions for the user", with a recommendation. It continues with work that does not depend on the question. When only parked questions are left, it uses the recommendation, records the decision in the loop node, and continues. The user can reverse it later.

Ask whether some topics must always wait for the user. Record them in the loop node.

## 7. Hidden context

Ask about the things that the code cannot show: external systems, old or undocumented services, people and owners, money, and legal limits. Store each answer as one memory node on the board, with frontmatter (`name`, `description`, `metadata.type: project`) and one line in `MEMORY.md` that ends with the date. Record only what a session cannot find in the code.

During the run, the loop may also write a new memory node for a fact that it discovers. A fact that the loop would have to guess goes to `NEXT.md` under "Decisions for the user" instead.

## 8. Write the loop node

1. Make the slug from the task: lowercase, hyphens for spaces.
2. Write one memory node `loop-<slug>.md` on the board, in strict STE. Give it this frontmatter: `name: loop-<slug>`, a one-line `description`, and `metadata.type: project`. The node holds the seven parts, the branch and the worktree name, and the verify command. The branch, the worktree and the node all have the name `loop-<slug>`. The node says that `.claude/loop.json` is the source of the verify command. If the two disagree, `.claude/loop.json` wins.
3. The verify command runs all done-checks and exits with a code that is not 0 when a check fails.
4. Add one line to `MEMORY.md` that points to the node. End the line with the date.
5. Write each goal as a to-do item in `NEXT.md`. Each item points to `loop-<slug>`.

## 9. Final yes and start

1. Find out if a push notification can reach the user (the `PushNotification` tool needs Remote Control). If it cannot, say so in the summary: the stop then goes to `NEXT.md` and to the mailbox `group-loops` only.
2. Show the user a short summary: the goals with their checks, the off-limits areas, the safety points, the sandbox, the engine, the permission mode of the loop session, the budget, the parked-question rule and how the user hears about the stop.
3. Get the final yes of the user. If the user says no, change the node with the user, or stop.
4. Make the branch `loop-<slug>` and its worktree `loop-<slug>`.
5. Copy the deny rules of the project into `.claude/settings.local.json` of the worktree, because git does not copy that file into a new worktree.
6. If the user kept the sandbox on: in `.claude/settings.local.json` of the worktree, note the current `sandbox` value. Step 7 stores it in `.claude/loop.json` as `sandbox_before`. Then set `sandbox.enabled` to `true`, `sandbox.filesystem.allowWrite` to the folder list, and `sandbox.network.allowedDomains` to the host list. Merge with `jq --slurpfile` from a file made with `mktemp`, and check the result with `jq empty`.
7. In the worktree, write `.claude/loop.json` with `{"node": "loop-<slug>", "verify": "<the verify command>"}`, plus `"sandbox_before"` from step 6 when the sandbox is on. This file switches on the verify hook. If `.claude/loop.json`, `.claude/loop.stuck`, `.claude/loop.verify-fails`, `.claude/loop.log` and `.claude/loop.stop` are not in the `.gitignore` of the project, add them. The user reviews this edit in `git diff`.
8. Start the loop with the chosen engine. For the local loop session, start a new session inside the worktree, so that its settings (deny rules, sandbox) and the verify hook apply from its first step. Start it detached, so that it keeps running when the setup chat closes:
   `cd <worktree> && nohup claude -p "<brief>" --permission-mode auto > .claude/loop.log 2>&1 &`
   The brief names the loop node `loop-<slug>`, says that this is a Loop of `~/.claude/CLAUDE.md`, and tells the session to do step 10 at the stop. Do not do the loop work in the setup chat.
9. Tell the user that the loop runs, where its log is (`.claude/loop.log` in the worktree), and that the user can leave now. Keep this setup chat open: it sends the stop notification.
10. Wait in this chat for the loop session to end: run a background Bash command that waits until its process exits. Then read the stop reason from `.claude/loop.stop` in the worktree, send it with the `PushNotification` tool in one line, and delete the file. This chat sends the push because it is the chat that Remote Control connects to the phone of the user. If the push is not sent, the note in `NEXT.md` and in the mailbox `group-loops` stays the record.

## 10. At the stop

1. If `.claude/loop.stuck` exists, the verify hook stopped the loop as stuck. Put its text in the report, then delete the file.
2. If `.claude/loop.json` has `sandbox_before`, put that value back as `sandbox` in `.claude/settings.local.json` of the worktree. Then delete `.claude/loop.json`.
3. Keep the worktree, the branch, its commits and the draft pull request for the review of the user. Delete nothing.
4. Write the stop reason to `NEXT.md` under "Decisions for the user" and to the mailbox `group-loops` (`~/.claude/bin/board mailbox group-loops`): all goals pass, the budget is reached, or the loop is stuck. Write the stop reason in one line to `.claude/loop.stop`. The setup chat sends it as the push notification.
5. Write the report: what the user can do now, what to try, what a pass looks like, what the loop did not check, and the decisions that the loop made for parked questions.
6. List each point where the run needed the user. These points are the next candidates for automation.
7. Update `NEXT.md` and the loop node. Delete the node when all its goals are done.
