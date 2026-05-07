# Bootstrap

Initial cluster setup. Tasks defined in [`mise.toml`](mise.toml) take two fresh Ubuntu nodes to a working k3s + Cilium cluster.

## Details

- Relax the `cri-containerd` AppArmor profile on each node so k3s pods can start on Ubuntu 26.04.
- Install k3s — server on `node-1`, agent on `node-2` — with Flannel, kube-proxy, servicelb, and Traefik disabled, leaving CNI and load balancing to Cilium.
- Fetch the kubeconfig from `node-1` to the operator machine.
- Install Cilium as kube-proxy replacement, with vxlan tunneling, BPF masquerade, L2 announcements, Gateway API, and Hubble enabled, then run a connectivity test.

The aggregate `all` task chains all of the above. Uninstall tasks for the k3s server and agent are also defined.

## Inputs

Env vars from the root [`mise.toml`](../mise.toml): `NODE_1_IP_ETH`, `NODE_1_IP_TAILSCALE`, `NODE_2_IP_ETH`, `NODE_2_IP_TAILSCALE`. Password-less SSH to `node-1` and `node-2` is assumed.
