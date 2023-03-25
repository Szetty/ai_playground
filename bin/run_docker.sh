#!/usr/bin/env sh

set -ex

docker run \
     -it --rm -p 4000:4000 \
     -e SECRET_KEY_BASE=2btsCppTrcK6uVfgbsSDOoxNE9CKyDMTBfMI85cBD4/4AwMPxSvVmfY+lAzI8aas \
     -e PHX_SERVER=true \
     ai_playground
