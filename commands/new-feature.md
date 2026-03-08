Add a new feature to an existing codebase with streamlined discovery and planning.

Arguments: $ARGUMENTS

You are orchestrating a feature addition pipeline. This is a shorter alternative to `/new-project` — scoped for adding features to existing codebases. Follow these stages IN ORDER. Never skip a stage. Each stage requires explicit user approval before proceeding to the next.

**Parallel safety:** Each feature gets its own namespace under `.planning/features/<slug>/`. Multiple features can be developed concurrently without file conflicts.

---

## Pre-Stage: Worktree Isolation (default)

**Before any other work**, check if this session is already in a worktree. If not:

1. Use `EnterWorktree` with the feature name as the worktree name (e.g., `EnterWorktree` with name `auth-feature`)
2. This isolates the entire session so parallel feature work in other tabs cannot conflict

**This is the default behavior.** Only skip if the user explicitly opts out (e.g., "no worktree", "work in main", "skip worktree").

---

## Stage 0: Input Analysis & Feature Naming

1. Determine the **feature name** from `$ARGUMENTS`:
   - If arguments contain a clear feature name, use it
   - If arguments are file paths or vague, defer naming to Stage 1
2. Derive a **slug** from the feature name: lowercase, hyphens for spaces, strip special characters (e.g., "User Authentication" → `user-authentication`)
3. Create `.planning/features/<slug>/` directory
4. If `$ARGUMENTS` contains file paths, read ALL provided files — these are the user's feature specs, notes, or references
5. Check for existing project-level state:
   - If `.planning/PLAN.md` exists, note the current project plan context
   - If `.planning/REQUIREMENTS.md` exists, note existing project requirements for cross-referencing
6. Check for existing feature state:
   - If `.planning/features/<slug>/` already exists with artifacts, report this and ask: resume, overwrite, or rename?
7. If files were provided, produce a structured analysis:

```markdown
## Feature Input Analysis

### Feature
- **Name**: [feature name]
- **Slug**: `<slug>`
- **Namespace**: `.planning/features/<slug>/`

### What's Defined
- [What the provided documents establish about this feature]

### Integration Points
- [How this feature relates to existing codebase/plan]

### Open Questions
- [What needs clarification before proceeding]
```

8. Present analysis to user. If no files were provided, proceed directly to Stage 1.

**Stage 0 exit**: Get user acknowledgment (including the feature name/slug) before proceeding.

---

## Stage 1: Feature Discovery (2 rounds)

If the feature name was not determined in Stage 0, establish it during this stage and derive the slug.

### Round 1 — Feature Definition (ask 4-6 questions)
- What exactly is this feature? What does it do for the user?
- What triggers it? (user action, event, schedule, API call?)
- What's the expected output/behavior? Walk me through the main flow.
- What are the edge cases you're already thinking about?
- What's the scope boundary — what is this feature NOT?
- Priority: must-ship quality or iterative/experimental?

### Round 2 — Integration & Constraints (ask 3-5 questions)
- Where does this feature live in the existing architecture? (new module, extension of existing, cross-cutting?)
- What existing code does it interact with? Any known dependencies?
- Are there API contracts, database changes, or UI components involved?
- Any performance, security, or backwards-compatibility constraints?
- Does this affect existing tests or require new test infrastructure?

**Rules for questioning:**
- Ask one round at a time. Wait for answers.
- Build on previous answers — don't re-ask what's been covered.
- If Stage 0 provided context, skip questions already answered by the documents.
- If an answer is vague, probe deeper with follow-ups.

**Stage 1 exit**: Present a brief feature summary back to the user, confirming the feature name and slug. Ask: "Does this capture the feature accurately? Anything to add or correct?" Get explicit approval.

---

## Stage 2: Feature Requirements

Write `.planning/features/<slug>/REQUIREMENTS.md` using this structure:

```markdown
# Feature Requirements: [Name]

## Summary
[2-3 sentences capturing what this feature does and why]

## User Stories
- As a [user type], I want [action] so that [benefit]

## Requirements
### Must Have
- FREQ-001: [requirement with clear acceptance criteria]
- FREQ-002: ...

### Nice to Have
- FREQ-XXX: ...

## Integration Constraints
- [How it must interact with existing code]
- [API contracts to respect]
- [Data model implications]

## Out of Scope
- [Explicitly excluded from this feature]

## Acceptance Criteria
- [Observable, testable measures that this feature is complete]
```

**Rules:**
- Every requirement gets a FREQ-ID for traceability
- Every requirement has acceptance criteria
- Cross-reference existing REQ-IDs from `.planning/REQUIREMENTS.md` if they exist
- Keep scope tight — this is one feature, not a project

**Stage 2 exit**: Present the requirements to the user. Ask: "Are these requirements complete and correctly scoped?" Get explicit approval.

---

## Stage 3: Codebase Mapping (mandatory)

This stage is always required — you're adding to an existing codebase.

Propose a team architecture for investigation:
```
Proposed Team Architecture:
- Pipeline: codebase-investigator
- Structure: single-team
- Agent count: 1
- Reasoning: Map existing code relevant to this feature
```

The investigator should:
1. Map the areas of the codebase this feature will touch
2. Identify existing patterns, conventions, and interfaces to follow
3. Find integration points and potential conflicts
4. Write findings to `.planning/features/<slug>/CODEBASE.md`:

```markdown
# Feature Codebase Map: [Feature Name]

## Relevant Files & Modules
| File/Module | Relevance | Will Modify? |
|-------------|-----------|-------------|
| ... | ... | Yes/No |

## Existing Patterns to Follow
- [Coding conventions, naming, architecture patterns in use]

## Integration Points
- [Where the feature connects to existing code]

## Potential Conflicts
- [Areas where the feature might clash with existing behavior]

## Test Infrastructure
- [Existing test patterns, frameworks, relevant test files]
```

**Stage 3 exit**: Present the codebase map. Ask: "Any concerns about integration approach?" Get acknowledgment.

---

## Stage 4: Feature Planning

Propose a team architecture for planning:
```
Proposed Team Architecture:
- Pipeline: planning-agent
- Structure: single-team
- Agent count: 1
- Reasoning: Plan feature implementation from requirements + codebase map
```

The planning-agent should:
1. Read `.planning/features/<slug>/REQUIREMENTS.md` and `.planning/features/<slug>/CODEBASE.md`
2. Create `.planning/features/<slug>/PLAN.md` with the feature implementation plan
3. If a project-level `.planning/PLAN.md` exists, note any dependencies or integration points — but do NOT modify the project plan
4. Ensure every FREQ-ID maps to a task in the plan
5. Respect existing codebase patterns identified in Stage 3

**Stage 4 exit**: Present the plan. Ask: "Does this implementation approach look right? Ready to validate?" Get explicit approval.

---

## Stage 5: Validation & Kickoff

Launch the plan-checker agent to validate the plan against codebase reality.

Report validation results. If REVISIONS NEEDED, send back to planning-agent and re-validate.

Once validated, announce:

```
FEATURE READY
=============
Feature: [Name] (slug: <slug>)
Namespace: .planning/features/<slug>/
Requirements: .planning/features/<slug>/REQUIREMENTS.md
Codebase Map: .planning/features/<slug>/CODEBASE.md
Plan: .planning/features/<slug>/PLAN.md (validated)

Ready to execute. Use:
- /implement <slug> — to start execution
- /plan-status — to check progress
- /status — for full dashboard
```

Do NOT auto-start execution. Let the user decide when to begin with `/implement`.

---

## Files Created by This Pipeline
| File | Stage | Purpose |
|------|-------|---------|
| `.planning/features/<slug>/REQUIREMENTS.md` | Stage 2 | Feature requirements with FREQ-IDs |
| `.planning/features/<slug>/CODEBASE.md` | Stage 3 | Codebase map for feature integration |
| `.planning/features/<slug>/PLAN.md` | Stage 4 | Feature implementation plan |

Additional files created during implementation:
| File | Created by | Purpose |
|------|------------|---------|
| `.planning/features/<slug>/CHECKPOINTS.md` | `/implement` | Task completion records |
| `.planning/features/<slug>/DEVIATIONS.md` | `/implement` | Plan deviation records |
