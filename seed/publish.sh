#!/bin/bash

# unofficial bash strict mode
set -euo pipefail
IFS=$'\n\t'

# run from any directory (no symlink allowed)
CURRENT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)
cd ${CURRENT_PATH}

##############################

TMP_REPOSITORY="tmp-gh-pages"

helm repo add edgelevel-public https://edgelevel.github.io/helm-charts
helm dependency update
helm template --values values.yaml .
helm lint .

git clone -b gh-pages https://github.com/edgelevel/gitops-k8s.git ${TMP_REPOSITORY}

cd ${TMP_REPOSITORY}
helm package ../
helm repo index .
git add .
git commit -m "release seed chart"
git push origin gh-pages
cd ..
rm -fr ${TMP_REPOSITORY}
