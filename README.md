<div align="center">

# homelab

**two Raspberry Pi 5s serving [thdxg.dev](https://thdxg.dev)**

<img src="https://cdn.simpleicons.org/raspberrypi/A22846" height="22"/>&nbsp;&nbsp;&nbsp;
<img src="https://cdn.simpleicons.org/ubuntu/E95420" height="22"/>&nbsp;&nbsp;&nbsp;
<img src="https://cdn.simpleicons.org/k3s/FFC61C" height="22"/>&nbsp;&nbsp;&nbsp;
<img src="https://cdn.simpleicons.org/cilium/F8C517" height="22"/>&nbsp;&nbsp;&nbsp;
<img src="https://cdn.simpleicons.org/flux/5468FF" height="22"/>&nbsp;&nbsp;&nbsp;
<img src="https://cdn.simpleicons.org/envoyproxy/AC6199" height="22"/>&nbsp;&nbsp;&nbsp;
<img src="https://cdn.simpleicons.org/letsencrypt/003A70" height="22"/>&nbsp;&nbsp;&nbsp;
<img src="https://cdn.simpleicons.org/cloudflare/F38020" height="22"/>&nbsp;&nbsp;&nbsp;
<img src="https://cdn.simpleicons.org/tailscale/242424" height="22"/>

</div>

## Services

|     |                                                  |                              |
| :-: | ------------------------------------------------ | ---------------------------- |
| <img src="https://cdn.simpleicons.org/bun" height="18"/> | **[thdxg.dev](https://thdxg.dev)** | portfolio |
| <img src="https://headlamp.dev/img/favicon.png" height="18"/> | **[headlamp.thdxg.dev](https://headlamp.thdxg.dev)** | cluster dashboard · read-only |
| <img src="https://cdn.simpleicons.org/cilium" height="18"/> | `mise run hubble` | network flows · local only |

## Consoles

|     |                                                                    |                            |
| :-: | ------------------------------------------------------------------ | -------------------------- |
| <img src="https://cdn.simpleicons.org/cloudflare/F38020" height="18"/> | [dash.cloudflare.com](https://dash.cloudflare.com) | DNS · proxy · TLS mode |
| <img src="https://cdn.simpleicons.org/tailscale/242424" height="18"/> | [login.tailscale.com](https://login.tailscale.com/admin/machines) | node access |
| <img src="https://cdn.simpleicons.org/github" height="18"/> | [thdxg/homelab](https://github.com/thdxg/homelab) | Flux syncs this repo |

## Path in

```
Cloudflare (proxied, full-strict) → router 80/443 → NodePort 80/443
  → Envoy Gateway (TLS + HTTPRoutes) → Service
```

Exposing a new app = one `HTTPRoute` in its manifests.

## Nodes

| node   | role          | disk  | wired            | wifi        |
| ------ | ------------- | ----- | ---------------- | ----------- |
| node-1 | control-plane | 0.5TB | 192.168.100.1/30 | 10.0.0.200  |
| node-2 | worker        | 1TB   | 192.168.100.2/30 | 10.0.0.201  |

Pi 5 · 8GB · Ubuntu 26.04 · kernel pinned `7.0.0-1010-raspi`

## Ops

```bash
mise run sync     # reconcile flux
mise run hubble   # open hubble ui
mise run down     # drain both nodes
mise run up       # uncordon both nodes
```

From-scratch install lives in [`bootstrap/`](bootstrap) — OS, k3s, Cilium, Flux.
