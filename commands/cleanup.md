Cleanup after the implementation: $ARGUMENTS

**Scope:** the files that `$ARGUMENTS` names. If `$ARGUMENTS` names no files, use the recent changes.

Launch the docs-and-cleanup agent. Tell it to:
1. Read the recent diffs and the implementation changes.
2. Update the documentation (docstrings, comments, READMEs), so that it agrees with the new code.
3. Add or correct the type hints and the signatures.
4. Remove the unused imports and the dead code that the implementation left.
5. Make sure that the code is clean and that its documentation is correct.

Run this after the checks of the mode pass: the build and the affected tests in Live, the done-checks of the loop node in Loop.
