#!/bin/bash

set -ex

docker build . -t ai_playground_cpu -f Dockerfile.cpu
