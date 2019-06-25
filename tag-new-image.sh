#!/bin/bash

set -e

baseTag=$1
targetImage=$2
acrName=$3
targetRegistry=$4
acrDigest=$5
baseDigest=$6

# Move base tag to new image
[ "${acrDigest}" != "" ] && echo "Untagging previous ${baseTag} ..." && az acr repository untag -n ${acrName} --image ${targetImage}:${baseTag}

echo "Tagging ${baseTag}-${baseDigest} as ${baseTag} ..."
az acr import --name ${acrName} --source ${targetRegistry}/${targetImage}:${baseTag}-${baseDigest} --image ${targetImage}:${baseTag} 
echo "Done."
