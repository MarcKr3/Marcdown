Install or update Marcdown with a review of each change: $ARGUMENTS

This command is the main way to install or update Marcdown. It shows the changes first. It installs nothing until the user approves.

**Limits:** Do not touch credentials, `projects/`, `agent-memory/` or the board memory. Do not commit or push, because the install changes the setup folder of the user and not a work branch. In the settings files, change only the Marcdown keys below, and never print or quote the other keys.

**Marcdown default (apply it with no question, unless the user said otherwise):**
- In `~/.claude/settings.json`: the Stop hook `~/.claude/bin/verify-hook` under `hooks.Stop`. Add it once. It does nothing outside a Loop.
- In `~/.claude/settings.json`: the hooks of the board notifications. Add each one once. They do nothing in a project without board notifications.
  - `hooks.SessionStart`, `hooks.UserPromptSubmit` and `hooks.PostToolUse`: `{"type": "command", "command": "~/.claude/bin/board-hook"}`.
  - `hooks.Stop`: `{"type": "command", "command": "~/.claude/bin/board-hook", "async": true, "asyncRewake": true, "timeout": 604800}`. It waits in the background while the chat is idle, and wakes the chat when board news comes. Keep it beside the verify hook.
- Merge with `jq --slurpfile` from a file made with `mktemp`. Check the result with `jq empty` before you write it.

Do not change the settings of a project. The one-time project setup of `~/.claude/CLAUDE.md` does that, the first time that Claude works in the project.

## 1. Get the new version

1. If `$ARGUMENTS` names a folder that holds `install.sh`, `CLAUDE.md` and `agents/`, use that folder as `NEW`.
2. Else make a temporary folder with `mktemp -d`. Clone the repository into it: `git clone --depth 1 https://github.com/MarcKr3/Marcdown.git <tmp>/marcdown`. Use `<tmp>/marcdown` as `NEW`.
3. If the clone fails, tell the user the error and stop.

## 2. Find the differences

Compare only the files that the installer manages. In `NEW`, these are `agents/`, `bin/`, `commands/`, `references/`, `templates/`, `skills/ste-writing/` and `CLAUDE.md`. In `~/.claude`, they are the files in `~/.claude/.marcdown-manifest`. If no manifest exists, this is a first install: use the same folder list in `~/.claude`.

Make three lists:
- **New files**: in `NEW`, not in `~/.claude`.
- **Changed files**: in both, with a different content. Get the diff with `diff -u`.
- **Removed files**: in the manifest, not in `NEW`. The installer deletes these files.

If the three lists are empty, tell the user that Marcdown is up to date and stop.

## 3. Interview the user

Show a short summary first: the number of new, changed and removed files in each group.

Then ask one question with `AskUserQuestion`: take all changes as they are, or go through the setup interview.
- **Take all changes**: say that the installer overwrites each changed file, edits of the user included, and deletes each removed file. If the user agrees, go to step 4 and skip the choices of step 3.
- **Go through the setup**: do the interview below.

In the interview, ask about each group with `AskUserQuestion`. Give up to 4 questions in each call. For each change, say what it changes in the behavior of Claude, not only which lines change.

1. **CLAUDE.md**: ask about each changed rule one at a time. Quote the old rule and the new rule.
2. **Agents**: one question for each new, changed or removed agent.
3. **Commands, references and templates**: one question for each group.
4. **bin/ and skills/ste-writing**: one question for each group.
5. **Removed files**: list them. Tell the user that the installer deletes them. Offer to keep a copy in a folder that the user names.

For each changed file, the diff can contain edits that the user made. Give these choices:
- **Take new**: the installer writes the new version.
- **Keep mine**: after the install, put back the copy of the user.
- **Merge**: show the two versions side by side. Write the merged file with the user after the install.

If the user stops the interview, install nothing and stop.

## 4. Install

1. Before the install, copy each file with the choice "Keep mine" or "Merge" to the temporary folder. Copy each removed file that the user wants to keep to the folder that the user named.
2. Run the installer: `bash <NEW>/install.sh --yes`. The `--yes` flag skips the confirmation prompt of the installer, because the user already approved in step 3.
3. Put back each "Keep mine" file from the temporary folder.
4. Make each "Merge" file with the user. Show the result before you write it.
5. If the installer fails, tell the user the error and the state of `~/.claude`. Do not try again without the approval of the user.

## 5. Report

Tell the user:
- The files that the installer added, changed and removed.
- The files that you put back or merged.
- The folder with the copies of the removed files, if any.
- The next step: in each project, run `~/.claude/bin/board setup` one time on this computer, if the board is not set up there.
- A new session loads the new `CLAUDE.md`, agents and commands.
