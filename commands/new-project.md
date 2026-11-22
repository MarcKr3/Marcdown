Start a new project with a full discovery and a plan.

Arguments: $ARGUMENTS

You lead the setup of a project. Do the stages in order. Each stage needs the approval of the user before the next stage starts.

---

## Pre-Stage: Worktree isolation (when another session is active)

Before other work, find out if this session is in a worktree. If it is not:

1. Find out if another session works on this repository. Examine `ListAgents` and `git worktree list`. If no other session is active, work in the main checkout and skip steps 2 and 3.
2. Use `EnterWorktree` with a name from the project, for example `new-project` or a short form of the project name.
3. The worktree isolates the session. Then work in other tabs cannot conflict with it.

The user can override this. Examples: "no worktree", "work in main", "use a worktree".

---

## Stage 0: Input analysis (when the user gives files)

If the arguments give file paths, do this stage before the discovery. If the user gave no files, go to Stage 1.

1. Read all of the files. They are the project documents of the user, for example briefs, outlines, specifications, plans and notes.
2. Write this analysis:

```markdown
## Input Document Analysis

### What the documents define
- [All that the documents state clearly: vision, features, tech stack, audience]

### Strengths
- [What the documents do well: a clear scope, detailed user flows, a strong business case]

### Gaps
- [Important topics that the documents do not cover: deployment, error handling, data model, authentication, tests]

### Unclear items
- [Items that are vague or that contradict each other]

### Assumptions
- [Assumptions that the documents make without a statement. The user must confirm them.]

### Risks
- [Possible problems: scope growth, technical debt, a timeline that is not realistic, missing integrations]

### Questions
- [Questions that the documents raise but do not answer]
```

3. Show the analysis to the user.
4. Go to Stage 1 with this context. In the discovery, ask about the gaps, the unclear items and the open questions. Do not ask again about what the documents cover.

---

## Stage 1: Discovery

Get a complete picture of what the user wants to build. Ask about the vision first. Then ask about the details.

**If Stage 0 ran:**
- Confirm what the documents state, for example: "The brief mentions X. Is that still correct?"
- Ask about the gaps and the unclear items of Stage 0.
- Ask about the assumptions that you found.
- Cover the 5 round topics. Skip a topic when the documents answer it clearly.

### Round 1: Vision and context
Ask only what the input does not answer. Topics:
- What the project is, and the problem that it solves.
- The audience and the end users.
- Success after 3 months and after 1 year.
- The reason for the project now, and the urgency.
- A new codebase or an existing codebase.
- The role of the user: solo developer, team or client work.
- Hard constraints: deadline, budget, platform, tech stack.

### Round 2: Technical shape
Ask only what the input and Round 1 do not answer. Topics:
- The tech stack, and the items that cannot change.
- The core user flows. The main flow, step by step.
- The data that the system manages, and the key entities.
- The integrations: APIs, authentication, payment, email.
- The deployment target.
- The test strategy: test first, integration tests or manual tests.
- Performance and scale.

### Round 3: Scope and priorities
Ask only what the earlier rounds do not answer. Topics:
- The minimum viable product against the full vision. The limit for version 1.
- The features that are necessary for the launch.
- The features that can wait for version 2.
- Features from other products that the user wants.
- What is out of scope.
- The quality: a prototype, or production quality from the start.

### Round 4: Edge cases and unknowns
Ask only what the earlier rounds do not answer. Topics:
- The most difficult part of the project.
- The largest uncertainty.
- Similar projects in the past, and what went wrong.
- Regulatory, compliance and security requirements.
- What can stop the project.

### Round 5: Hidden context
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
- Tell the user what you understand, so that the user can correct it.
- Continue with more rounds until the picture is clear and complete. A complex project can need more than 5 rounds.

**Stage 1 exit**: Give the user a short summary of the project. Ask: "Is this summary of the project correct? Must I add or correct something?" Get the approval of the user.

---

## Stage 2: Requirements

Write the requirements in the chat.

**Rules:**
- Give each requirement an ID, for example REQ-1, so that the plan can refer to it.
- Give each requirement acceptance criteria: how to know that it is done.
- Keep the must-have list strict.
- Give the answer of the user that sets the priority of each requirement.

**Stage 2 exit**: Ask: "Are these requirements complete, and is the priority correct?" Get the approval of the user. Correct the requirements if necessary.

---

## Stage 3: Codebase map and technical research

### 3a: Codebase map (existing codebase only)
If the project has an existing codebase:
1. Launch the built-in Explore agent to map the project.
2. Give the user a short summary in the chat: architecture, tech stack, key files, conventions, integration points and technical debt.

### 3b: Technical research
For the key technical decisions of Stage 1 and Stage 2:
1. Find the recommended libraries, frameworks and patterns. Use your knowledge and the documents of the user. Do not run web searches.
2. Find the possible problems and the best practices.
3. Give the findings to the user in the chat.

If you know the tech stack well and the user has clear preferences, keep this stage short.

**Stage 3 exit**: Ask: "Do you see a problem with these technical choices?" Get the acknowledgment of the user.

---

## Stage 4: Roadmap and phase plan

Launch the built-in Plan agent with the requirements of Stage 2 and the findings of Stage 3. The plan must give:
- The goals. Connect each requirement ID to a goal.
- For each goal, how to know that the goal is reached.
- The way to each goal, with its safety points: the risks, what must not break, and how to go back.
- The phases. Connect each goal to a phase.
- The tasks of Phase 1 only. The tasks of each later phase are planned when that phase starts.

Give the roadmap and the Phase 1 plan to the user in the chat.

**Stage 4 exit**: Ask: "Is this phase division correct? Can the work start?" Get the approval of the user.

---

## Stage 5: Kickoff

1. Get the memory folder with `~/.claude/bin/board path memory`. If the board is not set up, do the one-time project setup of `~/.claude/CLAUDE.md` first. Then continue.
2. Write the approved plan as one memory node `plan-<slug>.md`, in strict STE. Give it this frontmatter: `name: plan-<slug>`, a one-line `description`, and `metadata.type: project`. The node holds the approved requirements (ID, text and acceptance criteria), the goals, how to know that each goal is reached, the safe way to each goal, and the phases.
3. Add one line to `MEMORY.md` that points to the node. End the line with the date.
4. Write the phases and the tasks of Phase 1 as to-do items in `NEXT.md` on the board (`~/.claude/bin/board path next`). Each item names its goal and points to `plan-<slug>`.
5. When a later phase starts, add its tasks to the node and to `NEXT.md`. Delete the node and its line in `MEMORY.md` when the work is done.

Then tell the user:

```
PROJECT READY
=============
Project: [Name]
Phases: [N]
Current: Phase 1, [Name]
Plan: memory node plan-<slug> on the board
To-do items: NEXT.md on the board
```

Do not start the work. The user decides when the work starts.
