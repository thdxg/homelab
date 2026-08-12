#!/bin/sh
# Run a command in a Macterm remote project pane and print just its output.
#
# Usage: mtrun.sh <project> <command>
#   mtrun.sh node-1 "kubectl get nodes -o wide"
#
# Types the command into the project's first pane, waits for a unique
# completion marker to appear on screen, then prints the lines between the
# echoed command and the marker. Exit codes: 0 ok, 1 timeout, 2 send failed.
#
# Keep commands free of single quotes; wrap complex pipelines in double
# quotes at the call site. Output is read from the pane's scrollback, so
# very long output (>2000 lines) may be truncated at the top.

MT=/Applications/Macterm.app/Contents/Resources/bin/macterm
PROJECT=$1
shift
CMD=$*

ID=$(od -An -N4 -tx1 /dev/urandom | tr -d ' \n')

# Target the project's shell pane by session name — never pane:1 blindly.
# Users open TUIs (btop, k9s) in panes, and typing a command into one of
# those sends it keystrokes it may act on.
SESSION=$($MT pane list --project "$PROJECT" --json | /usr/bin/python3 -c '
import json, sys
for p in json.load(sys.stdin)["panes"]:
    if p.get("process") in ("bash", "zsh", "sh", "fish", "nu"):
        print(p["session"]); break
')
if [ -z "$SESSION" ]; then
  echo "mtrun: no shell pane found in project $PROJECT (all running TUIs?)" >&2
  exit 2
fi

# The marker is assembled at runtime by the remote printf, so the joined
# string "MTRUN-<id>" only ever appears in real output, never in the echo
# of the typed command line.
$MT pane run --project "$PROJECT" --session "$SESSION" "$CMD; printf 'MTRUN-%s\n' $ID" >/dev/null || exit 2

i=0
while [ "$i" -lt 90 ]; do
  if $MT pane dump --project "$PROJECT" --session "$SESSION" --scrollback | grep -q "MTRUN-$ID"; then
    # The echoed command line contains the raw id but never the joined
    # marker ("MTRUN-%s\n' <id>"); the real marker line contains the joined
    # form. Start after the echo, stop at the marker.
    $MT pane dump --project "$PROJECT" --session "$SESSION" --scrollback | awk -v id="MTRUN-$ID" -v raw="$ID" '
      /printf/ && index($0, raw) { started = 1; next }
      index($0, id) { exit }
      started { print }'
    exit 0
  fi
  sleep 1
  i=$((i + 1))
done

echo "mtrun: timed out waiting for command to finish in project $PROJECT" >&2
exit 1
