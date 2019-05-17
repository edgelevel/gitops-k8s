
#!/bin/bash

PREFIX="argo-cd-"
INSTALL_FILE="install.yaml"
TEMPLATES_PATH="templates/"

cd ${TEMPLATES_PATH}
# remove all files except the one starting with number
rm [^0-9]*

# https://argoproj.github.io/argo-cd/getting_started/#1-install-argo-cd
curl -o ${INSTALL_FILE} https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# split by resource type
split -p "---" -a 3 ${INSTALL_FILE} ${PREFIX}

function extract_file_name {
  local FILE=$1
  # extract second column from lines starting with "kind"
  # convert upper case to dash
  # convert upper to lower case
  # add file extension
  awk '/^kind/ { print $2 }' $FILE |
    sed 's/\(.\)\([A-Z]\)/\1-\2/g' |
    tr '[:upper:]' '[:lower:]' |
    awk '{ print $1".yaml" }'
}

# append content to file of the same resource type
for FILE in ${PREFIX}*; do
  FILE_NAME=$(extract_file_name $FILE)
  cat $FILE >> $FILE_NAME
done

# remove comment
find . -type f -name '*.yaml' -exec sed -i '.orig' 's/^.*DO NOT EDIT$/---/' {} \;

# cleanup
rm ${INSTALL_FILE}
rm ${PREFIX}*
rm *".orig"
