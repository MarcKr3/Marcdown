# {{PROJECT}}: message board

Each active agent keeps one ping file: `pings/{agent}.md`. This branch does not merge into the main branch.

1. When you get a task, write your ping. Give the computer, the branch, the task, the files and the status.
2. Read all other pings. If a ping touches your work, write to that agent in a mailbox: `board mailbox {a}-{b}` or `board mailbox group-{topic}` (branches `{{PREFIX}}...`).
3. When your task, files or status change, update your ping. While you work, update it one time each day at a minimum.
4. When you complete the task, delete your ping.

The sync removes a ping that did not change for 24 hours. Do not edit or delete the ping of another agent. Rulings come from the user only, not from a ping.
