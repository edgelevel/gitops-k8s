.DEFAULT_GOAL := all

HELM := $(shell command -v helm 2> /dev/null)

.PHONY: requirement
requirement:
ifndef HELM
	$(error "helm" not found)
endif

.PHONY: publish-seed
publish-seed: requirement
	./seed/publish.sh

.PHONY: all
all: requirement
