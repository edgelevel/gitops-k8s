# argocd chart

* official [install.yaml](https://github.com/argoproj/argo-cd/blob/master/manifests/install.yaml)

```bash
# download and split chart
./split-templates.sh

# print chart
helm template -f values.yaml .
```
