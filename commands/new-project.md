Initialize a new project with full discovery, planning, and execution pipeline.

Arguments: $ARGUMENTS

You are orchestrating a complete project setup. Follow these stages IN ORDER. Never skip a stage. Each stage requires explicit user approval before proceeding to the next.

---

## Pre-Stage: Worktree Isolation (default)

**Before any other work**, check if this session is already in a worktree. If not:

1. Use `EnterWorktree` with a name derived from the project (e.g., `EnterWorktree` with name `new-project` or a slug of the project name if known)
2. This isolates the session so parallel work in other tabs cannot conflict

**This is the default behavior.** Only skip if the user explicitly opts out (e.g., "no worktree", "work in main", "skip worktree").

---

## Stage 0: Input Analysis (if files provided)

If the user provided file paths as arguments, this stage runs BEFORE discovery. If no files were provided, skip directly to Stage 1.

### Process:
1. Read ALL provided files thoroughly — these are the user's existing project documents (briefs, outlines, specs, plans, notes, etc.)
2. Produce a structured analysis:

```markdown
## Input Document Analysis

### What's Already Defined
- [List everything the documents clearly establish: vision, features, tech stack, audience, etc.]

### Strengths
- [What the documents do well: clear scope, detailed user flows, strong business case, etc.]

### Blindspots
- [Critical topics not addressed: deployment strategy, error handling, data model, auth, testing, etc.]

### Ambiguities
- [Things mentioned but left vague or contradictory]

### Assumptions Detected
- [Implicit assumptions that should be made explicit and validated]

### Risks & Concerns
- [Potential issues: scope creep signals, technical debt traps, unrealistic timelines, missing integrations, etc.]

### Questions Arising
- [Specific questions the documents raise but don't answer]
```

3. Present this analysis to the user
4. Proceed to Stage 1 with this context — the discovery rounds should focus on blindspots, ambiguities, and unanswered questions rather than re-asking what the documents already cover

---

## Stage 1: Discovery Questioning

Your goal is to extract a complete mental model of what the user wants to build. This is NOT requirements gathering — this is dream extraction. Ask about the vision first, then drill into specifics.

**If Stage 0 ran**: You already have substantial context from the input documents. Do NOT re-ask what's already covered. Instead:
- Validate your understanding of what the documents say ("The brief mentions X — is that still accurate?")
- Focus discovery rounds on the blindspots, ambiguities, and questions identified in Stage 0
- Probe areas the documents are weakest on
- Challenge assumptions you detected
- Still cover all 4 round topics, but skip/shorten questions where documents already gave clear answers

### Round 1 — Vision & Context (ask 5-7 questions)
- What is this project? What problem does it solve?
- Who is it for? Who are the end users?
- What does success look like in 3 months? In 1 year?
- What's the driver — why now? What's the urgency?
- Is this greenfield (new) or brownfield (existing codebase)?
- What's your role — solo dev, team, client work?
- Any hard constraints? (deadline, budget, platform, tech stack requirements)

### Round 2 — Technical Shape (ask 5-7 questions, building on Round 1)
- What tech stack are you leaning toward? Any non-negotiables?
- What are the core user flows? Walk me through the main one.
- What data does this system manage? What are the key entities?
- What integrations are needed? (APIs, auth providers, payment, email, etc.)
- What's the deployment target? (Vercel, AWS, self-hosted, etc.)
- What's the testing strategy? (TDD, integration tests, manual?)
- Any performance requirements? Scale expectations?

### Round 3 — Scope & Priorities (ask 4-6 questions, building on Rounds 1-2)
- What's MVP vs full vision? Where do you draw the line for v1?
- What features are absolutely critical for launch?
- What can be deferred to v2?
- Are there features you've seen elsewhere you want to replicate?
- What's explicitly OUT of scope?
- Risk tolerance — prototype quality or production-grade from day 1?

### Round 4 — Edge Cases & Unknowns (ask 3-5 questions)
- What's the hardest part of this project?
- What are you most uncertain about?
- Have you built something like this before? What went wrong?
- Any regulatory, compliance, or security requirements?
- What would make you abandon this project?

**Rules for questioning:**
- Ask one round at a time. Wait for answers.
- Build on previous answers — don't re-ask what's been covered.
- If an answer is vague, probe deeper with follow-ups.
- Reflect understanding back: "So what I'm hearing is..." to validate.
- Continue rounds until you have a clear, complete picture.
- It's OK to ask 5+ rounds if the project is complex.

**Stage 1 exit**: Present a brief project summary back to the user. Ask: "Does this capture your project accurately? Anything to add or correct?" Get explicit approval.

---

## Stage 2: Requirements Crystallization

Transform the discovery answers into a structured requirements document.

Write `.planning/REQUIREMENTS.md` using this structure:

```markdown
# Project Requirements: [Name]

## Vision
[2-3 sentences capturing the core purpose]

## Target Users
[Who uses this and what they need]

## Core Requirements
### Must Have (v1)
- REQ-001: [requirement with clear acceptance criteria]
- REQ-002: ...

### Should Have (v1 if time permits)
- REQ-XXX: ...

### Future (v2+)
- REQ-XXX: ...

## Technical Constraints
- [Stack, platform, integration requirements]

## Out of Scope
- [Explicitly excluded items]

## Success Criteria
- [Observable, testable measures of project success]
```

**Rules:**
- Every requirement gets a REQ-ID for traceability
- Every requirement has acceptance criteria (how to know it's done)
- Must-haves are truly must-haves — be ruthless about scope
- Reference specific user answers to justify priority decisions

**Stage 2 exit**: Present the full requirements doc to the user. Ask: "Are these requirements complete and correctly prioritized?" Get explicit approval. Revise if needed.

---

## Stage 3: Research & Codebase Mapping

### 3a: Codebase Mapping (brownfield projects only)
If the user said this is an existing codebase:
1. Launch a codebase-investigator agent to map the existing project
2. Produce a summary of: architecture, tech stack, key files, conventions, integration points, technical debt
3. Write findings to `.planning/CODEBASE.md`

### 3b: Tech Research
For key technical decisions identified in Stage 1-2:
1. Research the ecosystem — what libraries, frameworks, patterns are recommended?
2. Identify potential pitfalls and best practices
3. Write findings to `.planning/RESEARCH.md`

If the tech stack is well-known to you and the user has clear preferences, this stage can be brief. Don't over-research obvious choices.

**Stage 3 exit**: Present research findings. Ask: "Any concerns with these technical choices?" Get acknowledgment.

---

## Stage 4: Roadmap & Phase Planning

Propose a team architecture for planning:
```
Proposed Team Architecture:
- Pipeline: planning-agent
- Structure: single-team
- Agent count: 1
- Reasoning: Planning from crystallized requirements
```

The planning-agent should:
1. Read `.planning/REQUIREMENTS.md` (and `.planning/CODEBASE.md`, `.planning/RESEARCH.md` if they exist)
2. Create a phased roadmap in `.planning/ROADMAP.md`:
   ```markdown
   # Project Roadmap: [Name]

   ## Phases Overview
   | Phase | Name | Description | Dependencies | Complexity |
   |-------|------|-------------|-------------|------------|
   | 1 | ... | ... | None | S/M/L |
   | 2 | ... | ... | Phase 1 | S/M/L |

   ## Phase Details
   ### Phase 1: [Name]
   - **Goal**: [What's true when this phase is done]
   - **Requirements covered**: REQ-001, REQ-002, ...
   - **Key deliverables**: [List]
   - **Success criteria**: [Observable, testable]

   [Repeat per phase]

   ## Requirement Traceability
   | Requirement | Phase | Status |
   |------------|-------|--------|
   | REQ-001 | Phase 1 | Planned |
   | REQ-002 | Phase 1 | Planned |
   ```
3. Ensure 100% requirement coverage — every REQ-ID maps to a phase
4. Create detailed `.planning/PLAN.md` for Phase 1 (with proper YAML frontmatter)
5. Subsequent phase plans are created when each phase begins (not all upfront)

**Stage 4 exit**: Present the roadmap and Phase 1 plan. Ask: "Does this phasing make sense? Ready to validate and begin?" Get explicit approval.

---

## Stage 5: Plan Validation

Launch the plan-checker agent to validate the Phase 1 plan against codebase reality (if brownfield) or for internal consistency (if greenfield).

Report validation results. If REVISIONS NEEDED, send back to planning-agent and re-validate.

**Stage 5 exit**: Plan validated and APPROVED.

---

## Stage 6: Execution Kickoff

Announce that the project is ready for execution:

```
PROJECT INITIALIZED
==================
Project: [Name]
Phases: [N]
Current: Phase 1 — [Name]
Plan: .planning/PLAN.md (validated)

Ready to execute. Use:
- /implement — to start Phase 1 execution
- /plan-status — to check progress
- /status — for full dashboard
```

Do NOT auto-start execution. Present the status and let the user decide when to begin with `/implement`.

---

## Files Created by This Pipeline
| File | Stage | Purpose |
|------|-------|---------|
| `.planning/REQUIREMENTS.md` | Stage 2 | Structured requirements with REQ-IDs |
| `.planning/CODEBASE.md` | Stage 3a | Existing codebase map (brownfield only) |
| `.planning/RESEARCH.md` | Stage 3b | Tech research findings |
| `.planning/ROADMAP.md` | Stage 4 | Phased roadmap with requirement traceability |
| `.planning/PLAN.md` | Stage 4 | Detailed Phase 1 implementation plan |
