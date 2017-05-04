#!/bin/bash

# Post to Slack

set -Cue +H

: ${WEBHOOK_URL:?variable is required}

curl -H "Accept: application/json" \
     -H "Content-type: application/json" \
     -X POST \
     -d "{\"text\": \"$2\", \"channel\": \"$1\"}" \
     $WEBHOOK_URL
