Post-implementation cleanup: $ARGUMENTS

**Determine scope:**
- If `$ARGUMENTS` starts with a feature slug matching `.planning/features/<slug>/`, use feature scope
- Otherwise, use project scope

Launch the docs-and-cleanup agent to:
1. Review recent diffs and implementation changes
2. Update documentation (docstrings, comments, READMEs) to match new code
3. Add or correct type hints and signatures
4. Remove unused imports and dead code left by implementation
5. Ensure the codebase remains clean and accurately documented

Only run this after implementation has been validated by test-validator.
