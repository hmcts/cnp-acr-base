#!/usr/bin/env bash

set -e

echo "Logging into ACR..."
az acr login --name hmctspublic --subscription DCD-CNP-Prod

RULES_CONFIG=$(yq e acr-repositories.yaml -o=json)

for key in $(echo $RULES_CONFIG | jq -r '.rules | keys | .[]'); do
    RULE_NAME=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .ruleName')
    REPO_NAME=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .repoName')
    DESTINATION_NAME=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .destinationRepo')
    REGISTRY=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | if has("registry") then .registry else "docker.io" end')

    echo "Creating ACR Cache Rule for $key, source: $REGISTRY/$REPO_NAME, destination: $DESTINATION_NAME..."
    az acr cache create -r hmctspublic -n $RULE_NAME -s $REGISTRY/$REPO_NAME -t $DESTINATION_NAME -c bancey
done
