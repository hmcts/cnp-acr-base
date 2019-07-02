#!/bin/bash

set -e

baseImage=$1
baseRegistry=$2
baseTag=$3
targetImage=$4
acrName=$5
targetRegistry=$6
baseDigest=$7

# acr import does not work with gcr (see: https://github.com/Azure/azure-cli/issues/9557)

docker pull ${baseRegistry}/${baseImage}:${baseTag}

docker image tag ${baseRegistry}/${baseImage}:${baseTag} ${targetRegistry}/${targetImage}:${baseTag}-${baseDigest}

az acr login --name ${acrName}

az acr repository delete --yes -n ${acrName} --image ${targetImage}:${baseTag}-${baseDigest} 2> /dev/null && echo "Removed existing (stale) tag."

docker push ${targetRegistry}/${targetImage}:${baseTag}-${baseDigest}
