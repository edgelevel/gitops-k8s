.DEFAULT_GOAL := all

HELM := $(shell command -v helm 2> /dev/null)

.PHONY: requirements
requirements:
ifndef HELM
	$(error "helm" not found)
endif

# publish to https://edgelevel.github.io/gitops-k8s
.PHONY: publish-seed
publish-seed: requirements
	./scripts/publish_seed.sh

.PHONY: bootstrap
bootstrap: requirements
	./scripts/bootstrap.sh

.PHONY: all
all: requirements
