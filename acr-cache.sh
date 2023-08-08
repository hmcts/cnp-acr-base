#!/usr/bin/env bash

set -e

echo "Logging into ACR..."
az acr login --name hmctspublic --subscription 8999dec3-0104-4a27-94ee-6588559729d1 --expose-token

RULES_CONFIG=$(yq e acr-repositories.yaml -o=json)
# echo $RULES_CONFIG

for key in $(echo $RULES_CONFIG | jq -r '.rules | keys | .[]'); do
    # echo "key is $key"
    RULE_NAME=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .ruleName')
    # echo "ruleName is $RULE_NAME"
    REPO_NAME=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .repoName')
    # echo "repoName is $REPO_NAME"
    DESTINATION_NAME=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .destinationRepo')
    # echo "destinationRepo is $DESTINATION_NAME"
    TAG_VERSION=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .tagVersion')
    # echo "tagVersion is $TAG_VERSION"

    echo "Create ACR Cache"
    az acr cache create -r hmctspublic -n $RULE_NAME -s docker.io/$REPO_NAME -t $DESTINATION_NAME

    echo "Docker Image Pull"
    docker pull hmctspublic.azurecr.io/$DESTINATION_NAME:$TAG_VERSION
done
