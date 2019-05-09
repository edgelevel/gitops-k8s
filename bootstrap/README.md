# bootstrap (not working)

This chart

1. installs `argocd` from official [charts](https://github.com/argoproj/argo-helm/tree/master/charts/argo-cd) as requirements
2. creates a `Namespace`
3. creates an `AppProject`
4. creates an `Application` of applications with [automated Sync Policy](https://argoproj.github.io/argo-cd/user-guide/auto_sync)

## Setup

```bash
cd bootstrap/

# add helm repository
helm repo add argo https://argoproj.github.io/argo-helm
# download tgz in bootstrap/charts
helm dependency update

# --namespace argocd overrides .Release.Namespace
# --name argocd overrides .Release.Name
# @see argo-helm/charts/argo-cd/templates/argocd-application-controller-clusterrolebinding.yaml
# apply chart
helm template --namespace argocd --name argocd --values values.yaml . | kubectl apply -n argocd -f -
```

## Issue

As soon as you sync `argocd` itself, the following secrets are deleted from `argocd-secret` and the [solution](https://argoproj.github.io/argo-cd/faq/#i-forgot-the-admin-password-how-do-i-reset-it) proposed in the docs is not working. Investigate further the reason or open an issue.

* admin.password
* admin.passwordMtime
* server.secretkey
* tls.crt
* tls.key

```bash
# error in the logs "invalid session: admin.password is missing" after sync first time
# https://github.com/argoproj/argo-cd/blob/af896533dfb5d23568034f87f39114156630658f/test/manifests/base/patches.yaml
kubectl get secret argocd-secret -o yaml -n argocd
kubectl edit secret argocd-secret -n argocd
```
