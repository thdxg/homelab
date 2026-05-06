# Bootstrap

The bootstrap process sets up the initial infrastructure for k3s. This includes changing OS configuration (e.g. AppArmor), installing k3s on nodes, and installing Cilium as a CNI and kube-proxy replacement.

## Prerequisites

1. Two nodes running Ubuntu Server 26.04 (`node-1`, `node-2`)
2. Password-less SSH access to the nodes
3. Local IP and Tailscale IP set as environment variables in the root `mise.toml`

## Process

To set up everything in one command, run:

```sh
mise run //bootstrap:all
```

Alternatively, use individual commands:

```sh
mise run //bootstrap:k3s:install:master
mise run //bootstrap:k3s:install:worker
mise run //bootstrap:k3s:kubeconfig
mise run //bootstrap:cilium:install
mise run //bootstrap:cilium:test
```
