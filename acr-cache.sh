#!/usr/bin/env bash

set -e

echo "Logging into ACR..."
az acr login --name hmctspublic --subscription DCD-CNP-Prod

RULES_CONFIG=$(yq e acr-repositories.yaml -o=json)

for key in $(echo $RULES_CONFIG | jq -r '.rules | keys | .[]'); do
    RULE_NAME=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .ruleName')
    REPO_NAME=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .repoName')
    DESTINATION_NAME=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .destinationRepo')
    TAG_VERSION=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .tagVersion')

    echo "Create ACR Cache"
    az acr cache create -r hmctspublic -n $RULE_NAME -s docker.io/$REPO_NAME -t $DESTINATION_NAME

    echo "Docker Image Pull"
    docker pull hmctspublic.azurecr.io/$DESTINATION_NAME:$TAG_VERSION
done
