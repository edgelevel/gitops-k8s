# bootstrap-unofficial

This chart

1. installs `argocd` as subchart from [charts/argocd](charts/argocd) and it's generated from [install.yaml](https://github.com/argoproj/argo-cd/blob/master/manifests/install.yaml)
    ```bash
    # download and split chart
    ./split-templates.sh
    ```
2. creates a `Namespace`
3. creates an `AppProject`
4. creates an `Application` of applications with [automated Sync Policy](https://argoproj.github.io/argo-cd/user-guide/auto_sync)

## Setup

```bash
cd bootstrap-unofficial/

# apply chart
helm template --values values.yaml . | kubectl apply -n argocd -f -
```
