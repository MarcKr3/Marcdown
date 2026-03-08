Record a plan deviation: $ARGUMENTS

Append to `.planning/DEVIATIONS.md`:

```
## Deviation: [description from arguments]
- **Plan said**: [what was originally specified]
- **Actual**: [what is being done instead]
- **Reason**: [why the deviation is necessary]
- **Impact**: [what this affects downstream]
```

Create `.planning/` directory and file if they don't exist.
Ask the user to confirm the deviation details before writing.
