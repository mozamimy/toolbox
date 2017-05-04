#!/bin/bash

# Change Slack status

set -Cue +H

: ${SLACK_TOKEN:?variable is required}

curl -X POST \
     --data-urlencode "token=$SLACK_TOKEN" \
     --data-urlencode "profile={\"status_emoji\":\"$1\", \"status_text\": \"$2\"}" \
     https://slack.com/api/users.profile.set?pretty=1
