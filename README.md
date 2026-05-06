# Kubernetes Homelab

A two-node Kubernetes cluster running on Raspberry Pis, built on [k3s](https://k3s.io/).

## Hardware

| name   | machine        | RAM | Disk  |
| ------ | -------------- | --- | ----- |
| node-1 | Raspberry Pi 5 | 8GB | 0.5TB |
| node-2 | Raspberry Pi 5 | 8GB | 1TB   |

## Software

- **OS:** Ubuntu Server 26.04
- **Kubernetes:** k3s v1.35.4
- **CNI:** Cilium 1.19.3
- **Networking:** Tailscale for remote access

## Requirements

1. Two nodes running Ubuntu Server 26.04 (`node-1`, `node-2`)
2. Password-less SSH access to both nodes (hostnames resolvable as `node-1` / `node-2`)
3. Local and Tailscale IPs for each node set in [mise.toml](mise.toml)
4. [mise](https://mise.jdx.dev/) installed locally — `kubectl` and `cilium-cli` are managed by mise

## Getting Started

Install tooling and bootstrap the cluster:

```sh
mise install
mise run //bootstrap:all
```
