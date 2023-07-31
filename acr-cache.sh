#!/usr/bin/env bash

set -e

# ruleName=$1
# repoName=$2
# destinationRepo=$3
# tagVersion=$4

yq '.rules.[].ruleName' acr-repositories.yaml
yq '.rules.[].repoName' acr-repositories.yaml
yq '.rules.[].destinationRepo' acr-repositories.yaml
yq '.rules.[].tagVersion' acr-repositories.yaml

echo $ruleName
echo $repoName
echo $destinationRepo
echo $tagVersion

# systemctl start docker

echo "Logging into ACR..."
az acr login --name hmctspublic --subscription 8999dec3-0104-4a27-94ee-6588559729d1 --expose-token

echo "Setup Subscription"
az account set --subscription DCD-CNP-Prod

echo "Create ACR Credentials"
az acr credential-set create -r hmctspublic.azurecr.io -n credentials -l docker.io -u https://cftptl-intsvc.vault.azure.net/secrets/docker-hub-username -p https://cftptl-intsvc.vault.azure.net/secrets/docker-hub-password

echo "Create ACR Cache"
az acr cache create -r hmctspublic.azurecr.io -n $ruleName -s docker.io/$repoName -t $destinationRepo -c credentials

PRINCIPAL_ID=$(az acr credential-set show -n credentials  -r hmctspublic.azurecr.io  --query 'identity.principalId'  -o tsv)

echo "Setup Subscription"
az account set --subscription DTS-CFTPTL-INTSVC

echo "Create KV Policy"
az keyvault set-policy --name cftptl-intsvc --object-id $PRINCIPAL_ID --secret-permissions get

echo "Docker Image Pull"
docker pull hmctspublic.azurecr.io/$destinationRepo:$tagVersion