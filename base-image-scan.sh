#!/bin/bash

set -e
set -x

targetRegistry=$1
targetImage=$2
baseTag=$3
registryPublicUsername=$4
registryPublicPassword=$5
registrySlackWebhook=$6
scannerUrl=$7
scannerUsername=$8
scannerPassword=$9


echo "Getting auth token ..."
_token=$(curl -s -k -H "Content-Type: application/json" -d "{\"password\": {\"username\": \"${scannerUsername}\", \"password\": \"${scannerPassword}\"}}" \
  "${scannerUrl}/v1/auth" | jq .token.token |sed 's/"//g')

[[ "${_token}" == "" ]] && echo "Authentication to image scanner failed." && exit 1

echo "Scanning image ${targetImage} ..."
_scan_results=$(curl -s -k -H 'Content-Type: application/json' -H "X-Auth-Token: $_token" \
  -d "{\"request\":{\"registry\":\"https://${targetRegistry}\",\"repository\":\"${targetImage}\",\"tag\":\"${baseTag}\",\"username\":\"${registryPublicUsername}\",\"password\":\"${registryPublicPassword}\"}}" \
  "${scannerUrl}/v1/scan/repository") 

echo $_scan_results

_high_severity=$(echo $_scan_results | jq '[.report.vulnerabilities[] | select(.severity == "High") | {"Name": .name, "Severity": .severity}]')
_critical_severity=$(echo $_scan_results | jq '[.report.vulnerabilities[] | select(.severity == "Critical") | {"Name": .name, "Severity": .severity}]')

_num_high=$(echo $_high_severity |jq '. | length')
_num_critical=$(echo $_critical_severity |jq '. | length')

if (("$_num_high" > 0 or "$_num_critical" > 0))
then
  _msg_text="Scanned new image ${targetRegistry}/${targetImage}:${baseTag}. *High severity: ${_num_high}*. *Critical severity: ${_num_critical}*."
else
  _msg_text="Scanned new image ${targetRegistry}/${targetImage}:${baseTag}. No high or critical severity vulnerabilities found."
fi
echo "Scan summary: [${_msg_text}]"

curl -X POST --data-urlencode "payload={\"channel\": \"#acr-tasks-monitoring\", \"username\": \"NeuVector\", \"text\": \"${_msg_text}\", \"icon_emoji\": \":liam_is_watching:\"}" \
  ${registrySlackWebhook}

# Export variables for next stages
echo "##vso[task.setvariable variable=scanPassed]true" 
