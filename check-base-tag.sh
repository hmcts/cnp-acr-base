#!/usr/bin/env bash

set -e

baseImage=$1
baseRegistry=$2
baseTag=$3
targetImage=$4
acrName=$5

_result=$(docker buildx imagetools inspect --raw $baseRegistry/$baseImage:$baseTag)

if echo $_result | grep -q manifests
then
  _digest=$(echo $_result | jq -r '.manifests[] | select (.platform.architecture == "amd64") | .digest')
else
  _digest=$(echo $_result | jq -r .config.digest)
fi

[ "$_digest" == "" ] && echo "Error: cannot get image digest for ${baseImage}:${baseTag}" && exit 1

# Get current digest from target azure registry
echo "Base registry current digest for ${baseImage}:${baseTag}: [${_digest}]"

_acr_digest=$(az acr manifest list-metadata --registry $acrName --name $targetImage \
 --query "[?not_null(tags[])]|[?contains(tags, \`\"${baseTag}\"\`)].digest|[0]" -o tsv || echo "")

echo "Target registry current digest for ${baseImage}:${baseTag}: [${_acr_digest}]"

[[ "$_acr_digest" != "" && "$_acr_digest" == "$_digest" ]] && echo "Nothing to import for ${baseRegistry}/${baseImage}." && exit 0  # Nothing else to do

# Export variables for next stages
echo "##vso[task.setvariable variable=newTagFound]true" 
echo "##vso[task.setvariable variable=acrDigest]$_acr_digest"
echo "##vso[task.setvariable variable=baseDigest]${_digest:7:6}"
