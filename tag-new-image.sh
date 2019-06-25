#!/bin/bash

set -e

baseImage=$1
baseRegistry=$2
baseTag=$3
baseImageType=$4
targetImage=$5
acrName=$6
targetRegistry=$7


# Move base tag to new image
[ "${acrDigest}" != "" ] && echo "Untagging previous ${baseTag} ..." && az acr repository untag -n ${acrName} --image ${targetImage}:${baseTag}

echo "Tagging ${baseTag}-${baseDigest} as ${baseTag} ..."
az acr import --name ${acrName} --source ${targetRegistry}/${targetImage}:${baseTag}-${baseDigest} --image ${targetImage}:${baseTag} 
echo "Done."
