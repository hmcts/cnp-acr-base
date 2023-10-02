#!/usr/bin/env bash

set -e

echo "Logging into ACR..."
az acr login --name hmctspublic --subscription DCD-CNP-Prod

RULES_CONFIG=$(yq e acr-repositories.yaml -o=json)

for key in $(echo $RULES_CONFIG | jq -r '.rules | keys | .[]'); do
    RULE_NAME=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .ruleName')
    REPO_NAME=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .repoName')
    DESTINATION_NAME=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .destinationRepo')

    echo "Creating ACR Cache Rule for $key"
    az acr cache create -r hmctspublic -n $RULE_NAME -s $REPO_NAME -t $DESTINATION_NAME
done
