# bootstrap-unofficial

This chart

1. installs `argocd` as subchart from [charts/argocd](charts/argocd) which it's generated from [install.yaml](https://github.com/argoproj/argo-cd/blob/master/manifests/install.yaml)
    ```bash
    # download and split chart
    ./bootstrap-unofficial/charts/argocd/split-templates.sh
    ```
2. creates a `Namespace`
3. creates an `AppProject`
4. creates an `Application` of applications with [automated Sync Policy](https://argoproj.github.io/argo-cd/user-guide/auto_sync)

## Setup

Apply chart
```bash
# from any folder
./bootstrap-unofficial/apply.sh

# manually
cd bootstrap-unofficial/
helm template --values values.yaml . | kubectl apply -n argocd -f -
```
