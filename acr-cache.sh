#!/usr/bin/env bash

set -e

dockerHubUsername=$1
dockerHubPassword=$2

echo "Logging into ACR..."
az acr login --name hmctspublic --subscription 8999dec3-0104-4a27-94ee-6588559729d1 --expose-token

echo "Create ACR Credentials"
az acr credential-set create -r hmctspublic -n credentials1 -l docker.io -u https://cftptl-intsvc.vault.azure.net/secrets/docker-hub-username -p https://cftptl-intsvc.vault.azure.net/secrets/docker-hub-password

PRINCIPAL_ID=$(az acr credential-set show -n credentials1  -r hmctspublic  --query 'identity.principalId'  -o tsv)

echo "Setup Subscription DTS-CFTPTL-INTSVC"
az account set --subscription DTS-CFTPTL-INTSVC

echo "Create KV Policy"
az keyvault set-policy --name "cftptl-intsvc" --object-id $PRINCIPAL_ID --secret-permissions get

echo "Setup Subscription DCD-CNP-Prod"
az account set --subscription DCD-CNP-Prod

RULES_CONFIG=$(yq e acr-repositories.yaml -o=json)
# echo $RULES_CONFIG

for key in $(echo $RULES_CONFIG | jq -r '.rules | keys | .[]'); do
    echo "key is $key"
    RULE_NAME=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .ruleName')
    echo "ruleName is $RULE_NAME"
    REPO_NAME=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .repoName')
    echo "repoName is $REPO_NAME"
    DESTINATION_NAME=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .destinationRepo')
    echo "destinationRepo is $DESTINATION_NAME"
    TAG_VERSION=$(echo $RULES_CONFIG | jq -r '.rules | ."'$key'" | .tagVersion')
    echo "tagVersion is $TAG_VERSION"

    echo "Create ACR Cache"
    az acr cache create -r hmctspublic -n $RULE_NAME -s docker.io/$REPO_NAME -t $DESTINATION_NAME -c credentials1

    az login --service-principal --username ${dockerHubUsername} --password ${dockerHubPassword}

    echo "Docker Image Pull"
    docker pull hmctspublic.azurecr.io/$DESTINATION_NAME:$TAG_VERSION
done
