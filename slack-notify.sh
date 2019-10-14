#!/bin/bash

set -e

slackMessage=$1
slackWebhook=$2
slackIcon=${3:-tim-webster}

curl -X POST --data-urlencode "payload={\"channel\": \"#acr-tasks-monitoring\", \"username\": \"NeuVector\", \"text\": \"${slackMessage}\", \"icon_emoji\": \":${slackIcon}:\"}" \
  ${slackWebhook}

