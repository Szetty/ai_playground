#!/bin/bash

set -ex

docker build . -t ai_playground_gpu -f Dockerfile.gpu
