# Bootstrap

From two fresh Ubuntu nodes to a cluster that Flux manages from this repo.
Everything after this directory is applied by Flux, never by hand.

## Steps

`mise run //bootstrap:all` chains these, in order:

1. `os:eth0`: static IPs on the wired link between the nodes (a /30).
2. `os:apparmor`: relax the `cri-containerd` AppArmor profile on each node so
   k3s pods can start on Ubuntu 26.04.
3. `k3s:install:master`, `k3s:install:worker`: k3s from config files (no CLI
   args), server on `node-1`, agent on `node-2`. Flannel, kube-proxy,
   servicelb and Traefik are disabled; the NodePort range starts at 80 so the
   public edge can use 80/443 directly.
4. `k3s:kubeconfig`: fetch the kubeconfig to this machine, pointed at
   `node-1`'s Tailscale address.
5. `cilium:install`: the Gateway API CRDs (pinned to the version Envoy
   Gateway is built against), then Cilium as kube-proxy replacement with vxlan
   tunneling, BPF masquerade, and Hubble (relay + UI). Cilium's own Gateway
   API, L7 proxy and L2 announcements are **off**; L7 and TLS are Envoy
   Gateway's job (`apps/envoy-gateway`).
6. `flux:install`: `flux bootstrap github` against `bootstrap/flux`, plus the
   sops age key Secret that Flux uses to decrypt secrets in `apps/`.

Uninstall tasks for the k3s server and agent are also defined. `cilium:test`
runs the connectivity test. `os:wifi` and `os:cilium-link` are one-off fixes
that are not part of `all`.

## Inputs

Env vars from the root `mise.toml`, loaded from `.env` (never committed):
`NODE_1_IP_ETH`, `NODE_2_IP_ETH`, `NODE_1_IP_TAILSCALE`, `NODE_2_IP_TAILSCALE`,
`CLUSTER_CIDR`, `K3S_VERSION`, `TAILNET_DOMAIN`, `GITHUB_TOKEN`,
`SOPS_AGE_KEY_FILE`, `WIFI_SSID`, `WIFI_PASSWORD`. Password-less SSH to
`node-1` and `node-2` is assumed. The age key lives in `.secrets/age.agekey`
(gitignored) and must match the recipient in `.sops.yaml`.
