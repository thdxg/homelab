# Networking

```
PUBLIC

  Browser
     │
     │  https://overburrow.org
     ▼
  Cloudflare  ◄──── TLS terminates here, Cloudflare's cert
     │
     │  http (internal, no TLS needed)
     ▼
  cloudflared pod (in cluster)
     │
     ▼
  public-gateway (Cilium)
     │
     ▼
  HTTPRoute → website service


PRIVATE

  Browser
     │
     │  https://argocd.overburrow.dev
     │
     │  DNS: overburrow.dev → Tailscale IP  (Cloudflare, grey cloud)
     ▼
  Tailscale (encrypted tunnel, but NOT TLS termination)
     │
     │  https (still needs TLS cert)
     ▼
  private-gateway (Cilium)  ◄──── TLS terminates here, cert-manager cert
     │                             (*.overburrow.dev from Let's Encrypt)
     │  http (internal)
     ▼
  HTTPRoute → argocd / grafana / infisical / headlamp ...
```
