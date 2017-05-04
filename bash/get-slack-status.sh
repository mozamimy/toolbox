#!/bin/bash

# Get Slack status

set -Cue +H

: ${SLACK_TOKEN:?variable is required}

curl -sS \
     -X POST \
     --data-urlencode "token=$SLACK_TOKEN" \
     https://slack.com/api/users.profile.get?pretty=1 | \
     jq -r -c '.profile.status_emoji, .profile.status_text' | \
     tr '\n' ' '
