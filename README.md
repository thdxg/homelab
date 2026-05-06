# Kubernetes Homelab

Two-node k3s cluster on Raspberry Pi 5s, with Cilium as CNI, kube-proxy replacement, and Gateway API implementation. Bootstrap and operations are driven by [mise](https://mise.jdx.dev/) tasks.

## Nodes

| name   | role   | machine        | RAM | Disk  |
| ------ | ------ | -------------- | --- | ----- |
| node-1 | master | Raspberry Pi 5 | 8GB | 0.5TB |
| node-2 | worker | Raspberry Pi 5 | 8GB | 1TB   |

## Software

- **OS:** Ubuntu Server 26.04
- **Kubernetes:** k3s v1.35.4 (Flannel, kube-proxy, servicelb, and Traefik disabled)
- **CNI:** Cilium 1.19.3 (kube-proxy replacement, Gateway API, L2 announcements, Hubble)
- **Networking:** Tailscale for remote access
- **Tooling:** mise, kubectl, cilium-cli (versions pinned in [mise.toml](mise.toml))

## Project Layout

- [`mise.toml`](mise.toml) — root mise config; declares the monorepo, pins tools (e.g. `kubectl`), and stores per-node local and Tailscale IPs as env vars.
- [`bootstrap/`](bootstrap) — initial cluster setup: OS tweaks (AppArmor), k3s install on both nodes, kubeconfig fetch, and Cilium install.

## Requirements

The setup assumes:

1. Two nodes running Ubuntu Server 26.04, reachable as `node-1` and `node-2`
2. Password-less SSH access to both nodes
3. Local and Tailscale IPs for each node set in [`mise.toml`](mise.toml)
4. [mise](https://mise.jdx.dev/) installed on the operator machine
