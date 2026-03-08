Record a checkpoint for current work: $ARGUMENTS

**Determine scope:**
- If the first word of `$ARGUMENTS` matches a feature slug in `.planning/features/`, write to `.planning/features/<slug>/CHECKPOINTS.md` and use the remaining arguments as the task description
- Otherwise, write to `.planning/CHECKPOINTS.md` and use all of `$ARGUMENTS` as the task description

Append:

```
## [Task description] — [current timestamp]
- **Status**: [complete | partial | blocked]
- **Files**: [list files modified in this task]
- **Notes**: [any observations or concerns]
```

Create the directory and file if they don't exist.
Confirm the checkpoint was recorded and show the scope used.
