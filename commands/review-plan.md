Review and critique the current plan before execution.

1. **Determine scope:**
   - If `$ARGUMENTS` names a feature slug and `.planning/features/<slug>/PLAN.md` exists, review the feature plan
   - If no arguments, check for all plans (`.planning/PLAN.md` and `.planning/features/*/PLAN.md`). If exactly one exists, use it. If multiple, list them and ask.
   - Otherwise, review `.planning/PLAN.md`
2. Evaluate the plan for:
   - Completeness: are all requirements addressed?
   - Feasibility: are tasks realistic given the codebase?
   - Dependencies: is the ordering sound?
   - Scope: are boundaries clear and non-overlapping?
   - Risks: are they identified with mitigations?
   - Exit criteria: are they testable?
3. Provide constructive feedback and specific improvement suggestions
4. Recommend: proceed as-is, revise, or rethink

The orchestrator decides whether to perform the review directly or launch agents based on scope and complexity.
