#!/bin/bash

# unofficial bash strict mode
set -euo pipefail
IFS=$'\n\t'

# run from any directory (no symlink allowed)
CURRENT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)
cd ${CURRENT_PATH}

##############################

ROOT_PATH="${CURRENT_PATH}/.."
SEED_PATH="${ROOT_PATH}/charts/seed/"

cd ${SEED_PATH}

# add helm repository
helm repo add edgelevel-public https://edgelevel.github.io/helm-charts

# download chart locally
helm dependency update

# apply chart
helm template --values values.yaml . | kubectl apply -n argocd -f -
