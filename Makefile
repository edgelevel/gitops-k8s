# http://makefiletutorial.com
# https://danyspin97.org/blog/makefiles-best-practices

.DEFAULT_GOAL := all

KUBECTL := $(shell command -v kubectl 2> /dev/null)
HELM := $(shell command -v helm 2> /dev/null)
ARGOCD := $(shell command -v argocd 2> /dev/null)

BOOTSTRAP_PATH = bootstrap

.PHONY: requirement
requirement:
ifndef KUBECTL
	$(error "kubectl" not found)
endif
ifndef HELM
	$(error "helm" not found)
endif
ifndef ARGOCD
	$(error "argocd" not found)
endif

.PHONY: bootstrap
bootstrap:
	bootstrap-unofficial/apply.sh

.PHONY: all
all: requirement bootstrap
