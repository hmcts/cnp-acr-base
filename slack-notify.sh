#!/bin/bash

set -e

slackMessage=$1
slackWebhook=$2

curl -X POST --data-urlencode "payload={\"channel\": \"#acr-tasks-monitoring\", \"username\": \"NeuVector\", \"text\": \"${slackMessage}\", \"icon_emoji\": \":tim-webster:\"}" \
  ${slackWebhook}

