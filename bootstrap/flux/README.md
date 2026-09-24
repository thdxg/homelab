# Flux Reconciliation Tree

`flux bootstrap` points the `flux-system` Kustomization at this directory.
Everything below it is discovered from git.

```mermaid
graph TD
    A([gotk-sync.yaml]) --> B([flux-system/kustomization.yaml])
    B --> C([gotk-components.yaml]):::note
    B --> D([apps.yaml]):::ks
    D --> F([apps/kustomization.yaml])
    F --> G([apps/*/ks.yaml]):::ks
    G --> H([apps/*/manifests/*.yaml]):::note

    classDef ks fill:#7F77DD,stroke:#534AB7,color:#fff
    classDef note fill:#888780,stroke:#5F5E5A,color:#fff
```

Each app directory is self-contained: its `ks.yaml` is a Flux Kustomization
with `targetNamespace` set, and `manifests/` holds the Namespace, any
HelmRepository and HelmRelease, and the app's own objects. There is no shared
sources directory; chart repositories are declared next to the release that
uses them.

Ordering that matters is expressed with `dependsOn`
(`cert-manager-issuers` waits for `cert-manager`) and `wait: true` on the
Kustomizations that install CRDs (`cert-manager`, `envoy-gateway`).
