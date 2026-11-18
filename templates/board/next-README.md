# {{PROJECT}}: board branch `{{BRANCH}}`

This branch holds the shared agent state of {{PROJECT}}. It has no app code. Do not merge it into the main branch.

- `NEXT.md`: the to-do list, the lane status and the decisions for the user. It shows the current state only.
- `memory/MEMORY.md`: the index of the shared project memory.
- `memory/computers/{name}/`: notes that are true on one computer only.
- `handoffs/`: handoffs that the user asked for.

To set up a computer, run `~/.claude/bin/board setup` in a checkout of the project. The command checks out this branch, links the Claude memory folders, and starts a sync every 2 minutes. `board status` shows the sync.
