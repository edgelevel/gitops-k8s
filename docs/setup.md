## Setup

* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl) to run commands against Kubernetes clusters
* [helm](https://helm.sh/docs/using_helm/#installing-helm) for templating purposes only
* [argocd](https://argoproj.github.io/argo-cd/getting_started/#2-download-argo-cd-cli) CLI

### Ubuntu

```bash
# kubectl
sudo snap install kubectl --classic

# helm
sudo snap install helm --classic

# argocd
sudo mkdir -p /opt/argo
ARGO_VERSION=1.0.0 && \
  sudo curl -L -o /opt/argo/argocd-linux-amd64 \
  https://github.com/argoproj/argo-cd/releases/download/v$ARGO_VERSION/argocd-linux-amd64
sudo chmod +x /opt/argo/argocd-linux-amd64
sudo ln -s /opt/argo/argocd-linux-amd64 /usr/local/bin/argocd
```

### macOS

```bash
# kubectl
brew install kubernetes-cli

# helm
brew install kubernetes-helm

# argocd
brew tap argoproj/tap
brew install argoproj/tap/argocd
```

## Recommended tools

* [kubectx](https://ahmet.im/blog/kubectx/index.html) - A tool to switch between Kubernetes contexts
* [kube-ps1](https://github.com/jonmosco/kube-ps1) - Kubernetes prompt

Add to `.bashrc` or `.bash_profile`
```bash
# K8S PROMPT
[[ -f /opt/kube-ps1/kube-ps1.sh ]] && source /opt/kube-ps1/kube-ps1.sh
#export KUBE_PS1_SYMBOL_COLOR=green
PS1='$(kube_ps1)'$PS1
# default
kubeoff

# K8S CONFIGS
function kube-config-local {
  export KUBECONFIG=
}
function kube-config-<MY_CLUSTER> {
  export KUBECONFIG=~/.kube/<MY_CLUSTER>-kubeconfig.yaml
  kubeon
}
# default
kube-config-local
```
