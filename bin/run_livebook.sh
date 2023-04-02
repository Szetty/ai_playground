#!/usr/bin/env sh

set -ex

docker run -it --rm \
    -p 8080:8080 \
    -p 8081:8081 \
    -v $(pwd):/data \
    --network=ai_playground \
    -e PHX_HOST=localhost \
    ghcr.io/livebook-dev/livebook

# -e RELEASE_NODE=livebook@5.2.197.133 \
    # -e RELEASE_DISTRIBUTION=name \
