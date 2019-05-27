#!/bin/bash

# unofficial bash strict mode
set -euo pipefail
IFS=$'\n\t'

# run from any directory (no symlink allowed)
CURRENT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)
cd ${CURRENT_PATH}

##############################

ROOT_PATH="${CURRENT_PATH}/.."
SEED_PATH="${ROOT_PATH}/seed/"
TMP_REPOSITORY="tmp-gh-pages"

cd ${SEED_PATH}
helm repo add edgelevel-public https://edgelevel.github.io/helm-charts
helm dependency update
helm template --values values.yaml .
helm lint .

git clone -b gh-pages git@github.com:edgelevel/gitops-k8s.git ${ROOT_PATH}/${TMP_REPOSITORY}

cd ${ROOT_PATH}/${TMP_REPOSITORY}
helm package ${SEED_PATH}
helm repo index .
git add .
git commit -m "release seed chart"
git push origin gh-pages
cd ${ROOT_PATH}
rm -fr ${ROOT_PATH}/${TMP_REPOSITORY}
