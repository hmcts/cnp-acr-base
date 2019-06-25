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

docker push ${targetRegistry}/${targetImage}:${baseTag}-${baseDigest}
