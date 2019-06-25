#!/bin/bash

set -e

baseImage=$1
baseRegistry=$2
baseTag=$3
baseImageType=$4
targetImage=$5

# Get digest for tag from base registry (e.g. docker)
if [ ${baseImageType} == "docker" ]
then
  # docker registry
  _token=$(curl --silent "https://auth.docker.io/token?scope=repository:${baseImage}:pull&service=registry.docker.io" | jq -r '.token')
  _digest=$(curl -i --silent --header "Accept: application/vnd.docker.distribution.manifest.v2+json" --header "Authorization: Bearer $_token" \
    "https://registry-1.docker.io/v2/${baseImage}/manifests/${baseTag}" |grep -i '[Dd]ocker-[Cc]ontent-[Dd]igest:' \
    |sed 's/[Dd]ocker-[Cc]ontent-[Dd]igest: *\(sha256:[a-zA-Z0-9]*\)/\1/' |tr -d '\r\n')
else
  # google registry (gcr)
  _digest=$(curl -i --silent "https://gcr.io/v2/${baseImage}/manifests/${baseTag}" |grep -i '[Dd]ocker-[Cc]ontent-[Dd]igest:' \
    |sed 's/[Dd]ocker-[Cc]ontent-[Dd]igest: *\(sha256:[a-zA-Z0-9]*\)/\1/' |tr -d '\r\n')
fi

[ "$_digest" == "" ] && echo "Error: cannot get image digest for ${baseImage}:${baseTag}" && exit 1

# Get current digest from target azure registry
echo "Base registry current digest for ${baseImage}:${baseTag}: [${_digest}]"
_acr_digest=$(az acr repository show-manifests -n ${acrName} --repository ${targetImage} \
  --query "[?not_null(tags[])]|[?contains(tags, `${baseTag}`)].digest|[0]" |tr -d '"[:blank:]' |xargs echo -n)
echo "Target registry current digest for ${baseImage}:${baseTag}: [${_acr_digest}]"

[[ "$_acr_digest" != "" && "$_acr_digest" == "$_digest" ]] && echo "Nothing to import for ${baseRegistry}/${baseImage}." && exit 0  # Nothing else to do

# Export variables for next stages
echo "##vso[task.setvariable variable=newTagFound]true" 
echo "##vso[task.setvariable variable=acrDigest]$_acr_digest"
echo "##vso[task.setvariable variable=baseDigest]${_digest:7:6}"
