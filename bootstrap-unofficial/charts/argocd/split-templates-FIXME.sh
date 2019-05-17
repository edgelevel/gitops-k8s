#!/bin/bash

# unofficial bash strict mode
set -euo pipefail
IFS=$'\n\t'

# run from any directory (no symlink allowed)
CURRENT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)
cd ${CURRENT_PATH}

##############################

function reset_templates {
  local TEMPLATES_PATH="templates/"

  rm -fr ${TEMPLATES_PATH}
  mkdir -p ${TEMPLATES_PATH}
  # FIXME update relative paths
  cd ${TEMPLATES_PATH}
}

# https://argoproj.github.io/argo-cd/getting_started/#1-install-argo-cd
# param #1: <output_name>
function download_install_chart {
  local OUTPUT_NAME=$1
  local URL="https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"

  curl -s -o ${OUTPUT_NAME} ${URL}
}

# param #1: <file_name>
# param #2: <prefix>
function split_by_resource {
  local FILE_NAME=$1
  local PREFIX=$2
  
  case "$(uname -s)" in
    Darwin)
      # macOS
      split -p "---" -a 3 ${FILE_NAME} ${PREFIX}
      ;;
    Linux)
      # Ubuntu
      echo "FIXME on Linux" && exit 1

      # multi-character separator not supported
      sed -i'.tmp' -e 's/---/!/g' ${FILE_NAME}
      split -t '!' -a 3 ${FILE_NAME} ${PREFIX}
      ;;
    *)
      echo "unknown OS" && exit 1
      ;;
  esac
}

# param #1: <file_name>
function extract_file_name {
  local FILE_NAME=$1

  # extract second column from lines starting with "kind"
  # prefix upper case with dash
  # convert upper to lower case
  # add file extension
  awk '/^kind/ { print $2 }' $FILE_NAME |
    sed 's/\(.\)\([A-Z]\)/\1-\2/g' |
    tr '[:upper:]' '[:lower:]' |
    awk '{ print $1".yaml" }'
}

# param #1: <prefix>
function append_to_resource {
  local PREFIX=$1

  # append content to file of the same resource type
  for FILE in ${PREFIX}*; do
    FILE_NAME=$(extract_file_name $FILE)
    cat ${FILE} >> ${FILE_NAME}
  done
}

# param #1: <suffix>
function remove_comment {
  local SUFFIX=$1

  find . -type f -name '*.yaml' -exec sed -i ${SUFFIX} 's/^.*DO NOT EDIT$/---/' {} \;
}

function main {
  local INSTALL_FILE="install.yaml"
  local PREFIX="argo-cd-"
  local SUFFX=".orig"

  reset_templates
  download_install_chart ${INSTALL_FILE}
  split_by_resource ${INSTALL_FILE} ${PREFIX}
  append_to_resource ${PREFIX}
  remove_comment '.orig'

  # cleanup
  rm -fr ${INSTALL_FILE} ${PREFIX} *${SUFFX}
}

main
