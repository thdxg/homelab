# Networking

One public edge for every site. TLS and HTTP routing happen in Envoy Gateway;
Cilium is CNI only (its Gateway API and L7 proxy are off, see
`bootstrap/cilium/values.yaml` for why).

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
  Service edge-gateway (NodePort 80/443, apps/envoy-gateway)
     │  plain L4 to the Envoy proxy pods; EG listens on 10080/10443
     ▼
  Envoy proxy pods  ×2, one per node (EnvoyProxy public-gateway-proxy)
     │
     ▼
  Gateway public-gateway (this directory)
     │  https listener terminates TLS with thdxg-dev-tls: a wildcard
     │  Let's Encrypt cert issued by cert-manager via Cloudflare DNS-01
     ▼
  HTTPRoute per app (apps/*/manifests/httproute.yaml)  →  Service
```

## Adding a site

One HTTPRoute in the app's own namespace, attached to `public-gateway` in
`networking`, hostname `<name>.thdxg.dev`. DNS and the certificate already
cover it. `apps/buggyracer/manifests/httproute.yaml` is the smallest example.

## What lives here

- `public-gateway.yaml`: the Gateway. Both listeners allow routes from all
  namespaces.
- `gatewayclass.yaml`: the `cilium` GatewayClass. Unused while Cilium's
  gateway is disabled; declared so a future re-enable doesn't fight helm over
  ownership (see the note in `bootstrap/cilium/values.yaml`).

The `envoy` GatewayClass, the EnvoyProxy, and the NodePort Service are in
`apps/envoy-gateway`; the certificate and issuer are in `apps/cert-manager`.
