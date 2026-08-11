---
name: healthcheck
description: Full health inspection of the homelab k3s cluster (node-1, node-2) driven through Macterm remote project panes — node/pod status, system load, inter-node ethernet, wifi/internet reachability, and Flux GitOps state including drift between the cluster and the git repo. Use whenever the user asks to check cluster health, inspect the nodes, verify the homelab after a change (reboot, network move, image update, flux change), diagnose whether the cluster is OK, or look for GitOps drift — even casual phrasings like "how's the cluster looking" or "is everything up".
---

# Homelab cluster healthcheck

Inspect the two-node k3s homelab and report what is healthy, what is broken,
and whether the cluster matches the git repo. All checks are read-only —
never restart, delete, or reconcile anything as part of a healthcheck; report
findings and let the user decide on fixes.

## Topology facts

- Two Raspberry Pi nodes: `node-1` (control-plane) and `node-2` (agent),
  k3s with Cilium as CNI (Flannel/kube-proxy/servicelb/Traefik disabled).
- Inter-node traffic rides a direct ethernet link: `192.168.100.1` (node-1)
  and `192.168.100.2` (node-2) on a /30. k3s INTERNAL-IPs must be these.
- External traffic uses wifi (`wlan0`, DHCP — the address changes when the
  user moves networks; that alone is not a problem). Tailscale also present.
- GitOps: Flux (with image-reflector and image-automation controllers)
  syncing `github.com/thdxg/homelab`, path `bootstrap/flux`. The local
  checkout lives at `~/dev/homelab`.

## Running commands on the nodes

Macterm remote projects `node-1` and `node-2` hold SSH panes to each node.
Use the bundled helper, which types a command into a pane, waits for a
runtime-assembled completion marker, and prints only that command's output.
It lives in this skill's `scripts/` directory — call it by absolute path
(`<repo>/.claude/skills/healthcheck/scripts/mtrun.sh`), not relative to your
working directory:

```sh
~/dev/homelab/.claude/skills/healthcheck/scripts/mtrun.sh node-1 "kubectl get nodes -o wide"
~/dev/homelab/.claude/skills/healthcheck/scripts/mtrun.sh node-2 "uptime; ip -br addr"
```

The two nodes are independent panes — send long-running checks to both
before reading either, or run two `mtrun.sh` calls in parallel, rather than
strictly alternating. `kubectl` and `flux` only work on node-1 (or on the
operator Mac, which has a kubeconfig for the cluster — prefer local
`kubectl`/`flux` for cluster-level queries and reserve the panes for
node-local facts like `uptime`, `ip`, `df`, `ping`).

If a pane is missing, `macterm pane list --project <name>` errors — report
that the remote project is not open instead of trying to create one.

## Checks

Work through all four areas even if an early one finds a problem — the user
wants a full picture, and independent failures often share a root cause.

### 1. Nodes

- `kubectl get nodes -o wide` — both Ready, INTERNAL-IP on the ethernet /30.
- Per node: `uptime` (load, unexpected recent reboot), `df -h /` (disk
  pressure starts biting kubelet at ~85%), `free -m` if load looks off.

### 2. Workloads

- `kubectl get pods -A | grep -vE ' (Running|Completed) '` — anything else
  is a finding.
- Restart counts: a pod with hundreds of restarts is a finding even when
  currently Running (get the last few `kubectl logs -p` lines). Single-digit
  restarts whose timestamps line up with a node reboot are expected churn,
  not findings — compare the restart age against `uptime`.

### 3. Network

- Inter-node ethernet: from node-2, `ping -c 2 -W 2 192.168.100.1`
  (expect sub-millisecond).
- Internet per node: `ping -c 2 -W 2 1.1.1.1` and a DNS check
  (`getent hosts github.com`).
- Wifi addresses on both nodes (`ip -br addr`) — report the current
  addresses so the user knows where the nodes landed after a network change.

### 4. GitOps state and drift

- `flux get kustomizations` and `flux get helmreleases -A` — anything not
  Ready, or suspended, is a finding. Include the message column verbatim.
- Revision drift: compare the revision Flux applied against
  `git ls-remote origin main` — a stale revision means Flux stopped pulling.
- Local drift: is `~/dev/homelab` behind origin (`git fetch --dry-run` or
  compare `git rev-parse HEAD` vs `origin/main`)? Not a cluster problem,
  but flag it so the user doesn't debug against a stale checkout.
- Spot-check image drift: the deployed image of the website deployment —
  `kubectl -n website get deploy website-deployment -o jsonpath='{.spec.template.spec.containers[0].image}'`
  — should match `apps/website/manifests/deployment.yaml` in the repo. Divergence here
  caught a dead cluster once — an old controller was silently failing to
  apply manifests — so treat any mismatch as significant, and check which
  GitOps controller actually owns the object if it appears.

## Report format

Lead with a one-line verdict, then three sections:

```
Cluster is healthy / degraded / broken — <one-line reason>.

## Healthy
- <what was checked and passed, compressed>

## Findings
- <each problem: symptom, evidence (verbatim message), likely cause>

## Suggested next steps
- <ordered, most valuable first; read-only diagnosis vs. fixes clearly separated>
```

Skip the Findings section only when there are genuinely none. Never "fix
quietly and report healthy" — a healthcheck that mutates the cluster is
lying about what it found.
