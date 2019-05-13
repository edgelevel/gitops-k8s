# Setup

Docs
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl)
* [helm](https://helm.sh/docs/using_helm/#installing-helm)
* [argocd](https://argoproj.github.io/argo-cd/getting_started/#2-download-argo-cd-cli)

## Ubuntu

```bash
# kubectl
sudo snap install kubectl --classic

# helm
sudo snap install helm --classic

# argocd
sudo mkdir -p /opt/argo
sudo curl -L -o /opt/argo/argocd-linux-amd64 \
  https://github.com/argoproj/argo-cd/releases/download/v0.12.3/argocd-linux-amd64
sudo chmod +x /opt/argo/argocd-linux-amd64
sudo ln -s /opt/argo/argocd-linux-amd64 /usr/local/bin/argocd
```

## macOS

```bash
# kubectl
brew install kubernetes-cli

# helm
brew install kubernetes-helm

# argocd
brew tap argoproj/tap
brew install argoproj/tap/argocd
```
