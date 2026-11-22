Add a new feature to an existing codebase with a short discovery and a plan.

Arguments: $ARGUMENTS

You lead a feature addition. This command is a short alternative to `/new-project` for a feature in an existing codebase. Do the stages in order. Each stage needs the approval of the user before the next stage starts.

---

## Pre-Stage: Worktree isolation (when another session is active)

Before other work, find out if this session is in a worktree. If it is not:

1. Find out if another session works on this repository. Examine `ListAgents` and `git worktree list`. If no other session is active, work in the main checkout and skip steps 2 and 3.
2. Use `EnterWorktree` with the feature name as the worktree name, for example `auth-feature`.
3. The worktree isolates the session. Then feature work in other tabs cannot conflict with it.

The user can override this. Examples: "no worktree", "work in main", "use a worktree".

---

## Stage 0: Input analysis and feature name

1. Get the feature name from `$ARGUMENTS`.
   - If the arguments give a clear feature name, use it.
   - If the arguments are file paths or are not clear, find the name in Stage 1.
2. If `$ARGUMENTS` gives file paths, read all of the files. They are the specifications, notes or references of the user for the feature.
3. Read `NEXT.md` on the board (`~/.claude/bin/board path next`). Find the items that touch this feature.
4. If the user gave files, write this analysis:

```markdown
## Feature Input Analysis

### Feature
- **Name**: [feature name]

### What the input defines
- [What the documents state about the feature]

### Integration points
- [How the feature connects to the existing codebase and to the items in NEXT.md]

### Open questions
- [What the user must make clear before the next stage]
```

5. Show the analysis to the user. If the user gave no files, go to Stage 1.

**Stage 0 exit**: Get the approval of the user for the analysis and the feature name.

---

## Stage 1: Feature discovery (3 rounds)

If Stage 0 did not find the feature name, find it in this stage.

### Round 1: Feature definition
Ask only what the input does not answer. Topics:
- What the feature is, and what it does for the user.
- What starts it: a user action, an event, a schedule or an API call.
- The output and the behavior. The main flow, step by step.
- The edge cases that the user knows about.
- The scope limit: what the feature does not do.
- The quality: ready to ship, or iterative and experimental.

### Round 2: Integration and constraints
Ask only what the input and Round 1 do not answer. Topics:
- Where the feature goes in the architecture: a new module, an extension of a module, or a change across modules.
- The existing code that the feature touches, and known dependencies.
- API contracts, database changes and UI parts.
- Performance, security and backward compatibility.
- The effect on the existing tests, and new test infrastructure.

### Round 3: Hidden context
Ask only what the input and the earlier rounds do not answer. Ask about the things that the code cannot show:
- External systems, and the services that are old or have no documentation.
- The people and the owners: who decides, who uses it, who maintains the systems around it.
- Money: costs, prices, accounts and limits.
- Legal and compliance limits.

Store each answer as one memory node on the board (`~/.claude/bin/board path memory`), with frontmatter (`name`, `description`, `metadata.type: project`) and one line in `MEMORY.md` that ends with the date. Record only what a session cannot find in the code.

**Rules for the questions:**
- Ask the discovery questions with `AskUserQuestion`, up to 4 questions in each call.
- Ask one round at a time. Wait for the answers.
- Do not ask again about a topic that an answer or a document covers.
- If an answer is not clear, ask a follow-up question.

**Stage 1 exit**: Give the user a short summary of the feature with its name. Ask: "Is this summary of the feature correct? Must I add or correct something?" Get the approval of the user.

---

## Stage 2: Feature requirements

Write the requirements in the chat.

**Rules:**
- Give each requirement an ID, for example FREQ-1, so that the plan can refer to it.
- Give each requirement acceptance criteria.
- Keep the scope to this feature.

**Stage 2 exit**: Ask: "Are these requirements complete, and is the scope correct?" Get the approval of the user.

---

## Stage 3: Codebase map

This stage is necessary, because the feature goes into an existing codebase.

Launch the built-in Explore agent. Tell it to find:
1. The parts of the codebase that the feature touches.
2. The existing patterns, conventions and interfaces that the feature must agree with.
3. The integration points and the possible conflicts.

Give the result to the user in the chat as a short codebase map.

**Stage 3 exit**: Ask: "Do you see a problem with this integration?" Get the acknowledgment of the user.

---

## Stage 4: Feature plan

Launch the built-in Plan agent with the requirements of Stage 2 and the codebase map of Stage 3. The plan must give:
- The goals. Connect each requirement ID to a goal.
- For each goal, how to know that the goal is reached.
- The way to each goal, with its safety points: the risks, what must not break, and how to go back.
- The tasks on each way. The tasks agree with the codebase patterns of Stage 3.
- The dependencies on other items in `NEXT.md`. The plan does not change those items.

Give the plan to the user in the chat.

**Stage 4 exit**: Ask: "Is this the correct approach?" Get the approval of the user.

---

## Stage 5: Kickoff

1. Get the memory folder with `~/.claude/bin/board path memory`. If the board is not set up, do the one-time project setup of `~/.claude/CLAUDE.md` first. Then continue.
2. Write the approved plan as one memory node `plan-<slug>.md`, in strict STE. Give it this frontmatter: `name: plan-<slug>`, a one-line `description`, and `metadata.type: project`. The node holds the approved requirements (ID, text and acceptance criteria), the goals, how to know that each goal is reached, and the safe way to each goal.
3. Add one line to `MEMORY.md` that points to the node. End the line with the date.
4. Write the tasks of the plan as to-do items in `NEXT.md` on the board. Each item names its goal and points to `plan-<slug>`.
5. Delete the node and its line in `MEMORY.md` when the work is done.

Then tell the user:

```
FEATURE READY
=============
Feature: [Name]
Requirements: in the plan node
Plan: memory node plan-<slug> on the board
To-do items: NEXT.md on the board
```

Do not start the work. The user decides when the work starts.
