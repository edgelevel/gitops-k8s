.DEFAULT_GOAL := all

HELM := $(shell command -v helm 2> /dev/null)

.PHONY: requirements
requirements:
ifndef HELM
	$(error "helm" not found)
endif

.PHONY: publish-seed
publish-seed: requirements
	./scripts/publish-seed.sh

.PHONY: all
all: requirements
