#!/usr/bin/env sh

set -ex

docker run \
     -it --rm -p 7860:7860 \
     -e SECRET_KEY_BASE=2btsCppTrcK6uVfgbsSDOoxNE9CKyDMTBfMI85cBD4/4AwMPxSvVmfY+lAzI8aas \
     -e RELEASE_COOKIE=cookie \
     -e RELEASE_NODE=container \
     --network=ai_playground \
     -e PHX_SERVER=true \
     -e PORT=7860 \
     -e PHX_HOST=localhost \
     -e OPEN_AI_API_KEY=$OPEN_AI_API_KEY \
     -e OPEN_AI_ORGANIZATION_ID=$OPEN_AI_ORGANIZATION_ID \
     ai_playground_cpu
