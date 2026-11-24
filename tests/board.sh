#!/usr/bin/env bash
# End-to-end test of ~/.claude/bin/board against a local bare remote: three computers (A, B, C) share one project.
# Run: bash ~/.claude/tests/board.sh   (needs git 2.42+; touches nothing outside a temp folder)
set -u
unset CLAUDE_CONFIG_DIR
BOARD="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/bin/board"
T="$(mktemp -d)"; [ -n "${KEEP:-}" ] || trap 'rm -rf "$T"' EXIT; echo "tmp: $T"
T="$(cd "$T" && pwd -P)"
# A local stand-in for the push relay, so that the test never sends anything to the internet.
python3 "$(dirname "${BASH_SOURCE[0]}")/relay-stub.py" "$T/relay.port" "$T/relay.log" & STUB=$!
trap 'kill $STUB 2>/dev/null; pkill -f "$T/" 2>/dev/null; [ -n "${KEEP:-}" ] || rm -rf "$T"' EXIT
for i in 1 2 3 4 5 6 7 8 9 10; do [ -s "$T/relay.port" ] && break; sleep 0.5; done
export BOARD_NOTIFY_SERVER="http://127.0.0.1:$(cat "$T/relay.port")"
pass=0; fail=0
ok() { if eval "$2"; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL: $1"; fi; }
g() { git -c user.name=t -c user.email=t@t -c init.defaultBranch=main "$@"; }
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
slug() { local p="$1"; command -v cygpath >/dev/null && p="$(cygpath -m "$p")"; printf '%s' "$p" | sed 's/[^A-Za-z0-9]/-/g'; }

g init -q --bare "$T/remote.git"
mkdir -p "$T/A" "$T/B" "$T/C"
g clone -q "$T/remote.git" "$T/A/proj" 2>/dev/null
( cd "$T/A/proj" && echo app > app.txt && g add . && g commit -q -m init && g push -q origin HEAD:main ) || exit 1

# ---- computer A: old local Claude memory exists ----
HOME_A="$T/A/home"; mkdir -p "$HOME_A/LaunchAgents"
bA() { HOME="$HOME_A" BOARD_LAUNCH_AGENTS="$HOME_A/LaunchAgents" bash "$BOARD" --project "$T/A/proj" "$@"; }
oldmem="$HOME_A/.claude/projects/$(slug "$T/A/proj")/memory"; mkdir -p "$oldmem"
printf -- '- [Old](old-note.md) — from A (1 Jan)\n' > "$oldmem/MEMORY.md"
printf -- '---\nname: old-note\n---\nfact\n' > "$oldmem/old-note.md"

# setup stops and lists local notes before it shares anything
out="$(bA setup --no-autosync 2>&1)"; rc=$?
ok "setup stops on local notes" '[ "$rc" = 3 ] && echo "$out" | grep -q "old-note.md"'
ok "nothing linked yet" '[ ! -L "$oldmem" ]'
ok "note not shared yet" '! g -C "$T/remote.git" show roadmap:memory/old-note.md >/dev/null 2>&1'

out="$(bA setup --no-autosync --share-notes 2>&1)"; echo "$out" | sed 's/^/  A: /'
ok "next branch on remote" 'g -C "$T/remote.git" rev-parse -q --verify refs/heads/roadmap >/dev/null'
ok "agents branch on remote" 'g -C "$T/remote.git" rev-parse -q --verify refs/heads/agents >/dev/null'
NEXT_A="$(bA path next)"
ok "board beside project" '[ "$(cd "$NEXT_A" && pwd -P)" = "$T/A/proj.roadmap" ]'
ok "computers folder" '[ -d "$NEXT_A/memory/computers" ] && [ "$(bA path computer)" = "$NEXT_A/memory/computers/$(hostname | cut -d. -f1 | tr -c "A-Za-z0-9\n" "-")" ]'
ok "old note folded in" '[ -f "$NEXT_A/memory/old-note.md" ] && grep -q "old-note.md" "$NEXT_A/memory/MEMORY.md"'
ok "claude memory linked" '[ -f "$oldmem/old-note.md" ] && [ "$(cd "$oldmem" && pwd -P)" = "$(cd "$NEXT_A/memory" && pwd -P)" ]'
ok "backup kept" 'ls -d "$oldmem".before-board-* >/dev/null 2>&1'
ok "old note pushed" 'g -C "$T/remote.git" show roadmap:memory/old-note.md >/dev/null 2>&1'
ok "main untouched by board" '! g -C "$T/remote.git" show main:NEXT.md >/dev/null 2>&1'
ok "no file written into the project" '[ -z "$(g -C "$T/A/proj" status --porcelain)" ]'

# ---- worktrees get the shared memory ----
g -C "$T/A/proj" worktree add -q "$T/A/wt-feature" -b feature 2>/dev/null
wtmem="$HOME_A/.claude/projects/$(slug "$T/A/wt-feature")/memory"
bA sync
ok "new worktree linked by sync" '[ -L "$wtmem" ] && [ "$(cd "$wtmem" && pwd -P)" = "$(cd "$NEXT_A/memory" && pwd -P)" ]'
g -C "$T/A/proj" worktree add -q "$T/A/wt-notes" -b notes 2>/dev/null
wtmem2="$HOME_A/.claude/projects/$(slug "$T/A/wt-notes")/memory"; mkdir -p "$wtmem2"; echo "local only" > "$wtmem2/wt-note.md"
bA sync
ok "worktree with notes left alone" '[ ! -L "$wtmem2" ] && [ -f "$wtmem2/wt-note.md" ]'
ok "status lists it" 'bA status | grep -q "wt-notes"'
ok "its note not shared" '! g -C "$T/remote.git" show roadmap:memory/wt-note.md >/dev/null 2>&1'
ok "board worktree not linked" '[ ! -e "$HOME_A/.claude/projects/$(slug "$NEXT_A")/memory" ]'

# ---- computer B: a fresh clone finds the existing board ----
g clone -q "$T/remote.git" "$T/B/proj" 2>/dev/null
HOME_B="$T/B/home"; mkdir -p "$HOME_B/LaunchAgents"
bB() { HOME="$HOME_B" BOARD_LAUNCH_AGENTS="$HOME_B/LaunchAgents" bash "$BOARD" --project "$T/B/proj" "$@"; }
bB setup --no-autosync >/dev/null 2>&1
NEXT_B="$(bB path next)"
ok "B sees A's note" '[ -f "$NEXT_B/memory/old-note.md" ]'
memB="$HOME_B/.claude/projects/$(slug "$T/B/proj")/memory"
echo "from B" > "$memB/b-note.md"
echo "- [B](b-note.md) — b (2 Jan)" >> "$memB/MEMORY.md"
bB sync; bA sync
ok "B's note reached A" '[ -f "$NEXT_A/memory/b-note.md" ]'
# a background job starts with almost no PATH (Task Scheduler, launchd): only git is findable
echo "from a job" > "$NEXT_B/memory/job-note.md"
env -i HOME="$HOME_B" GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t PATH="$(dirname "$(command -v git)")" "$BASH" "$BOARD" sync --project "$T/B/proj"
bA sync
ok "sync works from a bare job PATH" '[ -f "$NEXT_A/memory/job-note.md" ]'

# ---- computer C: --keep-local keeps local notes off the board ----
g clone -q "$T/remote.git" "$T/C/proj" 2>/dev/null
HOME_C="$T/C/home"; mkdir -p "$HOME_C/LaunchAgents"
bC() { HOME="$HOME_C" BOARD_LAUNCH_AGENTS="$HOME_C/LaunchAgents" bash "$BOARD" --project "$T/C/proj" "$@"; }
memC="$HOME_C/.claude/projects/$(slug "$T/C/proj")/memory"; mkdir -p "$memC"; echo "private" > "$memC/c-private.md"
bC setup --no-autosync --keep-local >/dev/null 2>&1
ok "keep-local links" '[ -L "$memC" ]'
ok "keep-local does not share" '! g -C "$T/remote.git" show roadmap:memory/c-private.md >/dev/null 2>&1'
ok "keep-local backup has the note" 'ls "$memC".before-board-*/c-private.md >/dev/null 2>&1'

# ---- pings and mailboxes ----
echo "ping A" > "$(bA path agents)/pings/2026-01-01T0000Z-a.md"
bA sync; bB sync
ok "ping reached B" '[ -f "$(bB path agents)/pings/2026-01-01T0000Z-a.md" ]'
bA mailbox a-b >/dev/null 2>&1
echo "To: b · Re: -" > "$(bA path mailbox a-b)/messages/2026-01-01T0001Z-a.md"
bA sync
bB mailbox a-b >/dev/null 2>&1
ok "mailbox joined on B" '[ -f "$(bB path mailbox a-b)/messages/2026-01-01T0001Z-a.md" ]'
AG_A="$(bA path agents)"; bA sync
OLD="$(date -d '-25 hours' '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date -v-25H '+%Y-%m-%dT%H:%M:%S')"
echo "old" > "$AG_A/pings/old-agent.md"
( cd "$AG_A" && g add -A && GIT_COMMITTER_DATE="$OLD" GIT_AUTHOR_DATE="$OLD" g commit -q -m old )
echo "fresh" > "$AG_A/pings/a-agent.md"
bA sync
ok "stale ping removed" '! g -C "$T/remote.git" show agents:pings/old-agent.md >/dev/null 2>&1'
ok "fresh ping kept" 'g -C "$T/remote.git" show agents:pings/a-agent.md >/dev/null 2>&1'
MB_A="$(bA path mailbox a-b)"
( cd "$MB_A" && sed -i.bak 's/^Members:.*/Members: a-agent, gone-agent, fresh-talker, old-talker/' README.md && rm -f README.md.bak \
  && echo hi > messages/2026-01-02T0000Z-fresh-talker.md && g add -A && g commit -q -m talk \
  && echo hi > messages/2026-01-01T0000Z-old-talker.md && g add -A && GIT_COMMITTER_DATE="$OLD" g commit -q -m old-talk )
bB mailbox group-x >/dev/null 2>&1
MB_B="$(bB path mailbox group-x)"
( cd "$MB_B" && sed -i.bak 's/^Members:.*/Members: gone-two/' README.md && rm -f README.md.bak && g commit -q -am members )
bB sync
bA sync
ok "inactive members dropped" '[ "$(g -C "$T/remote.git" show mailbox/a-b:README.md | grep "^Members:")" = "Members: a-agent, fresh-talker" ]'
ok "dropped where not checked out" '[ "$(g -C "$T/remote.git" show mailbox/group-x:README.md | grep "^Members:")" = "Members: " ]'
bB sync
ok "B gets the shorter list" '[ "$(grep "^Members:" "$MB_B/README.md")" = "Members: " ]'
ok "no leftover edit folder" '! git -C "$T/A/proj" worktree list | grep -q mailbox-edit'

# ---- notifications: messages, pings and the main branch reach the agents that they concern ----
ok "topic on the agents branch" 'g -C "$T/remote.git" show agents:NOTIFY.md | grep -Eq "^Topic: board-[0-9a-f]{32}$"'
ok "B uses the same topic" '[ "$(grep "^Topic:" "$(bB path agents)/NOTIFY.md")" = "$(g -C "$T/remote.git" show agents:NOTIFY.md | grep "^Topic:")" ]'
SB=sessionB-0001
out="$(bB inbox --session $SB)"
ok "first look marks all as seen" '[ -z "$out" ]'
bB whoami b-agent --session $SB >/dev/null
echo "- Status: works on feature" > "$(bB path agents)/pings/b-agent.md"
bB sync; bA sync
ok "whoami names the session" 'grep -qx "name=b-agent" "$T/B/proj/.git/board/notify/sessions/$SB"'
MB_A="$(bA path mailbox a-b)"
: > "$T/relay.log"
printf 'To: b-agent · Re: -\nPlease take main in.\n' > "$MB_A/messages/2026-01-03T0000Z-a-agent.md"
printf 'To: c-agent · Re: -\nNot for b.\n' > "$MB_A/messages/2026-01-03T0001Z-a-agent.md"
printf 'To: everyone · Re: -\nFreeze at noon.\n' > "$MB_A/messages/2026-01-03T0002Z-a-agent.md"
bA sync
ok "a push sends an event" 'grep -q " mailbox/a-b$" "$T/relay.log"'
ok "the event holds only the branch" '! grep -q "Please" "$T/relay.log"'
bB event mailbox/a-b
out="$(bB inbox --session $SB)"
ok "direct message arrives" 'echo "$out" | grep -q "Message to you from a-agent" && echo "$out" | grep -q "Please take main in."'
ok "message to another agent stays out" '! echo "$out" | grep -q "Not for b."'
ok "message to everyone arrives" 'echo "$out" | grep -q "Freeze at noon."'
ok "a message comes one time" '[ -z "$(bB inbox --session $SB)" ]'
( cd "$MB_A" && sed -i.bak 's/^Members:.*/Members: a-agent, b-agent/' README.md && rm -f README.md.bak )
printf 'To: all · Re: -\nFor the members.\n' > "$MB_A/messages/2026-01-03T0003Z-a-agent.md"
printf 'To: b-agent · Re: -\nNot to myself.\n' > "$(bB path mailbox a-b)/messages/2026-01-03T0004Z-b-agent.md"
bB sync; bA sync; bB event mailbox/a-b
out="$(bB inbox --session $SB)"
ok "message to all members arrives" 'echo "$out" | grep -q "For the members."'
ok "own message stays out" '! echo "$out" | grep -q "Not to myself."'
echo "- Status: blocked on review" > "$(bA path agents)/pings/a-agent.md"
bA sync; bB event agents
ok "ping change arrives" 'bB inbox --session $SB | grep -q "Ping changed: a-agent. Status: blocked on review"'

# the main branch moved, and it touches a file that the branch of the session changes
g -C "$T/B/proj" worktree add -q "$T/B/wt-feat" -b feat 2>/dev/null
( cd "$T/B/wt-feat" && echo feat > app.txt && g commit -q -am feat )
SB2=sessionB-0002
bB inbox --session $SB2 >/dev/null
sed -i.bak "s#^cwd=.*#cwd=$T/B/wt-feat#" "$T/B/proj/.git/board/notify/sessions/$SB2" && rm -f "$T/B/proj/.git/board/notify/sessions/$SB2.bak"
( cd "$T/A/proj" && g pull -q origin main 2>/dev/null; echo main2 > app.txt && g commit -q -am "main change" && g push -q origin HEAD:main )
bB event main
out="$(bB inbox --session $SB2)"
ok "main moved arrives" 'echo "$out" | grep -q "main moved: 1 new commit" && echo "$out" | grep -q "main change"'
ok "overlap is named" 'echo "$out" | grep -A3 "change files that your branch" | grep -q "app.txt"'

# a waiting session sleeps, and a board event wakes it with the news
bB inbox --session $SB >/dev/null   # read the news of the main branch first
bB wait --session $SB --cwd "$T/B/proj" 2> "$T/wait.err" & WPID=$!
sleep 2
ok "the waiter sleeps while nothing is new" 'kill -0 $WPID 2>/dev/null'
printf 'To: b-agent · Re: -\nWake up.\n' > "$MB_A/messages/2026-01-03T0005Z-a-agent.md"
bA sync; bB event mailbox/a-b
for i in 1 2 3 4 5 6 7 8 9 10; do kill -0 $WPID 2>/dev/null || break; sleep 1; done
wait $WPID; rc=$?
ok "the waiter wakes with exit 2" '[ "$rc" = 2 ] && grep -q "Wake up." "$T/wait.err"'
bB wait --session $SB --cwd "$T/B/proj" 2>/dev/null & W1=$!; sleep 3
bB wait --session $SB --cwd "$T/B/proj" 2>/dev/null & W2=$!; sleep 2
ok "a new waiter replaces the old one" '! kill -0 $W1 2>/dev/null && kill -0 $W2 2>/dev/null'
pkill -f "wait --session $SB " 2>/dev/null; wait $W2 2>/dev/null

# the listener gets the event of another computer by itself
SB3=sessionB-0003
bB inbox --session $SB3 >/dev/null; bB whoami b-agent --session $SB3 >/dev/null
bB listen >/dev/null 2>&1 & LPID=$!
sleep 3
printf 'To: b-agent · Re: -\nBy the relay.\n' > "$MB_A/messages/2026-01-03T0006Z-a-agent.md"
bA sync
got=""
for i in $(seq 1 20); do got="$(bB inbox --session $SB3 --peek)"; echo "$got" | grep -q "By the relay." && break; sleep 1; done
ok "listener brings the message from A" 'echo "$got" | grep -q "By the relay."'
pkill -f "$T/B/proj listen" 2>/dev/null; pkill -f "$BOARD_NOTIFY_SERVER/" 2>/dev/null; kill $LPID 2>/dev/null
wait $LPID 2>/dev/null

# the hook: a ping write names the session, and news comes as context after a tool call
HOOK="$(dirname "$BOARD")/board-hook"
SB4=sessionB-0004
hook() { HOME="$HOME_B" bash "$HOOK"; }
printf '{"hook_event_name":"SessionStart","session_id":"%s","cwd":"%s","source":"startup"}' $SB4 "$T/B/proj" | hook > "$T/hook.out"
ok "SessionStart says notifications are on" 'grep -q "Board notifications are on" "$T/hook.out"'
printf '{"hook_event_name":"PostToolUse","session_id":"%s","cwd":"%s","tool_name":"Write","tool_input":{"file_path":"%s/pings/b-four.md"}}' \
  $SB4 "$T/B/proj" "$(bB path agents)" | hook >/dev/null
ok "a ping write names the session" 'grep -qx "name=b-four" "$T/B/proj/.git/board/notify/sessions/$SB4"'
printf 'To: b-four · Re: -\nHook news.\n' > "$MB_A/messages/2026-01-03T0007Z-a-agent.md"
bA sync; bB event mailbox/a-b
printf '{"hook_event_name":"PostToolUse","session_id":"%s","cwd":"%s","tool_name":"Read","tool_input":{"file_path":"/x"}}' $SB4 "$T/B/proj" | hook > "$T/hook.out"
ok "PostToolUse gives the news as context" 'python3 -c "import json,sys; d=json.load(open(sys.argv[1])); assert \"Hook news.\" in d[\"hookSpecificOutput\"][\"additionalContext\"]" "$T/hook.out"'
printf '{"hook_event_name":"PostToolUse","session_id":"%s","cwd":"%s","tool_name":"Read","tool_input":{"file_path":"/x"}}' $SB4 "$T/B/proj" | hook > "$T/hook.out"
ok "no news, no output" '[ ! -s "$T/hook.out" ]'
printf '{"hook_event_name":"PostToolUse","session_id":"%s","agent_id":"sub1","cwd":"%s","tool_name":"Read"}' $SB4 "$T/B/proj" | hook > "$T/hook.out"
ok "a subagent gets nothing" '[ ! -s "$T/hook.out" ]'
printf '{"hook_event_name":"PostToolUse","session_id":"%s","cwd":"%s","tool_name":"Read"}' $SB4 "$T" | hook > "$T/hook.out"; rc=$?
ok "outside a board project the hook is silent" '[ "$rc" = 0 ] && [ ! -s "$T/hook.out" ]'

# ---- a real conflict stops, keeps the local commit, never force-pushes ----
echo "A line" > "$NEXT_A/NEXT.md"; echo "B line" > "$NEXT_B/NEXT.md"
bA sync
bB sync; rc=$?
ok "conflict reported" '[ "$rc" != 0 ] && bB status | grep -q STUCK'
ok "remote keeps A" '[ "$(g -C "$T/remote.git" show roadmap:NEXT.md)" = "A line" ]'
ok "B keeps its commit" '[ "$(g -C "$NEXT_B" show HEAD:NEXT.md)" = "B line" ]'

# ---- setup stops on a board checkout that is not in step ----
out="$(bB setup --no-autosync 2>&1)"; rc=$?
ok "setup stops on a stale checkout" '[ "$rc" = 4 ] && echo "$out" | grep -q "local only"'

# ---- setup stops when another job syncs the board folder ----
printf '<plist><string>%s/sync.sh</string></plist>\n' "$NEXT_A" > "$HOME_A/LaunchAgents/com.example.old-sync.plist"
out="$(bA setup --no-autosync 2>&1)"; rc=$?
ok "setup stops on an old job" '[ "$rc" = 5 ] && echo "$out" | grep -q "old-sync.plist"'
rm -f "$HOME_A/LaunchAgents/com.example.old-sync.plist"

# ---- memory health check ----
echo "see [[missing-node]]" >> "$NEXT_A/memory/old-note.md"
ok "check finds broken link" '! bA check >/dev/null 2>&1'

echo "board tests: $pass passed, $fail failed"
[ "$fail" = 0 ]
