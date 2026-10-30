# Networking

One public edge for every site. TLS and HTTP routing happen in Cilium's
Gateway API implementation: cilium-envoy, the per-node Envoy DaemonSet that
Cilium manages, runs in hostNetwork mode and binds the Gateway's listener
ports directly on every node. Envoy Gateway served this role until
2026-10-30; `bootstrap/cilium/values.yaml` has the settings and the hard
prerequisite (the Tailscale `src_valid_mark` fix) that made the switch
possible.

```
  Browser
     │  https://thdxg.dev, https://*.thdxg.dev
     ▼
  Cloudflare (proxied)
     │  apex A record kept current by cloudflare-ddns (apps/cert-manager/manifests/ddns.yaml);
     │  *.thdxg.dev is a CNAME to the apex, so new hosts need no DNS work
     ▼
  Router  ──  WAN 80/443 forwarded same-port to node-1
     │
     ▼
  cilium-envoy  ×2, one per node (DaemonSet, hostNetwork), host :80/:443
     │  no Service in between: the listeners are plain host sockets, so
     │  nothing else may claim 80/443 on the nodes (a NodePort Service there
     │  would shadow them in BPF)
     ▼
  Gateway public-gateway-cilium (this directory, class cilium)
     │  https listener terminates TLS with thdxg-dev-tls: a wildcard
     │  Let's Encrypt cert issued by cert-manager via Cloudflare DNS-01
     ▼
  HTTPRoute per app (apps/*/manifests/httproute.yaml)  →  Service
```

## Adding a site

One HTTPRoute in the app's own namespace, attached to `public-gateway-cilium`
in `networking`, hostname `<name>.thdxg.dev`. DNS and the certificate already
cover it. `apps/buggyracer/manifests/httproute.yaml` is the smallest example.

## What lives here

- `public-gateway-cilium.yaml`: the Gateway. Both listeners allow routes from
  all namespaces.
- `gatewayclass.yaml`: the `cilium` GatewayClass. The cilium operator only
  creates it at first install, so it is declared here to survive Gateway API
  CRD reinstalls.

The Gateway API CRDs and Cilium itself are installed by `bootstrap/cilium`;
the certificate and issuer are in `apps/cert-manager`. Traffic metrics come
from cilium-envoy's `:9964/metrics` endpoint (job `cilium-envoy` in Mimir;
per-site clusters are named `networking/cilium-gateway-public-gateway-cilium/<ns>_<svc>_<port>`)
and feed the Sites / Traffic dashboard in `apps/monitoring`.
