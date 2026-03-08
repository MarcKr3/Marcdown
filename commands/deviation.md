Record a plan deviation: $ARGUMENTS

**Determine scope:**
- If the first word of `$ARGUMENTS` matches a feature slug in `.planning/features/`, write to `.planning/features/<slug>/DEVIATIONS.md` and use the remaining arguments as the deviation description
- Otherwise, write to `.planning/DEVIATIONS.md` and use all of `$ARGUMENTS` as the deviation description

Append:

```
## Deviation: [description]
- **Plan said**: [what was originally specified]
- **Actual**: [what is being done instead]
- **Reason**: [why the deviation is necessary]
- **Impact**: [what this affects downstream]
```

Create the directory and file if they don't exist.
Ask the user to confirm the deviation details before writing.
