#!/usr/bin/env bash

set -euo pipefail

targetRegistry=
targetImage=
baseTag=
registryPublicUsername=
registryPublicPassword=
registrySlackWebhook=
scannerUrl=
scannerUsername=
scannerPassword=

usage(){
>&2 cat << EOF
------------------------------------------------
Script to check if AKS cluster is active state
------------------------------------------------
Usage: $0
    [ -tr | --targetRegistry ]
    [ -ti | --targetImage ]
    [ -bt | --baseTag ] 
    [ -ru | --registryPublicUsername ]
    [ -rp | --registryPublicPassword ]
    [ -rw | --registrySlackWebhook ]
    [ -su | --scannerUrl ]
    [ -un | --scannerUsername ]
    [ -sp | --scannerPassword ]
    [ -h | --help ] 
EOF
exit 1
}

args=$(getopt -a -o tr:ti:bt:ru:rp:rw:su:un:sp: --long targetRegistry:,targetImage:,baseTag:,registryPublicUsername:,registryPublicPassword:,registrySlackWebhook:,scannerUrl:,scannerUsername:,scannerPassword:,help -- "$@")
if [[ $? -gt 0 ]]; then
    usage
fi

# Debug commands, uncomment if you are having issues
# >&2 echo [$@] passed to script
# >&2 echo getopt creates [${args}]

eval set -- ${args}
while :
do
    case $1 in
        -h | --help)                    usage                     ; shift   ;;
        -tr | --targetRegistry)         targetRegistry=$2         ; shift 2 ;;
        -ti | --targetImage)            targetImage=$2            ; shift 2 ;;
        -bt | --baseTag)                baseTag=$2                ; shift 2 ;;
        -ru | --registryPublicUsername) registryPublicUsername=$2 ; shift 2 ;;
        -rp | --registryPublicPassword) registryPublicPassword=$2 ; shift 2 ;;
        -rw | --registrySlackWebhook)   registrySlackWebhook=$2   ; shift 2 ;;
        -su | --scannerUrl)             scannerUrl=$2             ; shift 2 ;;
        -un | --scannerUsername)        scannerUsername=$2        ; shift 2 ;;
        -sp | --scannerPassword)        scannerPassword=$2        ; shift 2 ;;
        --) shift; break ;;
        *) >&2 echo Unsupported option: $1
            usage ;;
    esac
done

# Check if all arguments are provided
if [ -z "$targetRegistry" ] || [ -z "$targetImage" ] || [ -z "$baseTag" ] || [ -z "$registryPublicUsername" ] || [ -z "$registryPublicPassword" ] || [ -z "$registrySlackWebhook" ] || [ -z "$scannerUrl" ] || [ -z "$scannerUsername" ] || [ -z "$scannerPassword" ]; then
    echo "------------------------" 
    echo 'Some values are missing, please supply all the required arguments' >&2
    echo "------------------------"
    exit 1
fi

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

if (("$_num_high" > 0 || "$_num_critical" > 0))
then
  _msg_text="Scanned new image ${targetRegistry}/${targetImage}:${baseTag}. *High severity: ${_num_high}*. *Critical severity: ${_num_critical}*."
else
  _msg_text="Scanned new image ${targetRegistry}/${targetImage}:${baseTag}. No high or critical severity vulnerabilities found."
fi
echo "Scan summary: [${_msg_text}]"

curl -X POST --data-urlencode "payload={\"channel\": \"#acr-tasks-monitoring\", \"username\": \"NeuVector\", \"text\": \"${_msg_text}\", \"icon_emoji\": \":tim-webster:\"}" \
  ${registrySlackWebhook}

# Export variables for next stages
echo "##vso[task.setvariable variable=scanPassed]true" 
