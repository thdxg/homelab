# Homelab

Two-node k3s cluster (`node-1` control-plane, `node-2` agent) managed by Flux
from this repo. Local `kubectl`/`flux` on the Mac are configured for the
cluster.

## Rules

- Do not add the Claude co-author trailer (or any `Co-Authored-By`/generated-by
  attribution) to commit messages or PR bodies.
- Utilize macterm workflows as much as possible: run commands in Macterm panes
  via the macterm CLI (remote projects `node-1` and `node-2` for node-local
  commands) rather than plain shell/SSH, and use the `healthcheck` skill's
  `mtrun.sh` helper to run a pane command and capture its output.
- Record any discussion, architectural decision, troubleshooting session, or
  new concept in memory. Read and write memory frequently to preserve as much
  context as possible across sessions.
