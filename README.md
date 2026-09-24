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
| <img src="https://thdxg.dev/favicon.svg" height="18"/> | **[thdxg.dev](https://thdxg.dev)** | portfolio |
| <img src="https://macterm.thdxg.dev/assets/icons/icon.png" height="18"/> | **[macterm.thdxg.dev](https://macterm.thdxg.dev)** | macterm site · docs |
| <img src="https://headlamp.dev/img/favicon.png" height="18"/> | **[headlamp.thdxg.dev](https://headlamp.thdxg.dev)** | cluster dashboard · read-only |
| <img src="https://cdn.simpleicons.org/grafana" height="18"/> | **[grafana.thdxg.dev](https://grafana.thdxg.dev)** | metrics dashboards · login, shared dashboards public |

## Nodes

| node   | role          | disk  | wired            | wifi        |
| ------ | ------------- | ----- | ---------------- | ----------- |
| node-1 | control-plane | 0.5TB | 192.168.100.1/30 | 10.0.0.200  |
| node-2 | worker        | 0.5TB | 192.168.100.2/30 | 10.0.0.201  |

Pi 5 · 8GB · Ubuntu 26.04 · kernel pinned `7.0.0-1010-raspi`

## Ops

```bash
mise run sync     # reconcile flux from git
mise run reboot   # rolling reboot, node-2 then node-1, workloads kept served
```

Ingress path and TLS are described in [`apps/networking/`](apps/networking).
Monitoring (Mimir, Alloy, Grafana) lives in [`apps/monitoring/`](apps/monitoring).

From-scratch install lives in [`bootstrap/`](bootstrap) — OS, k3s, Cilium, Flux.
