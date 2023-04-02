#!/bin/bash

set -ex

IP=$1
TAR_NAME="ai_playground_docker_image.tar"
TAG="ai_playground"

# docker save -o $TAR_NAME $TAG
scp -i "priv_key.pem" $TAR_NAME admin@$IP:/home/admin/
ssh -i "priv_key.pem" admin@$IP sudo docker load -i /home/admin/$TAR_NAME
rm $TAR_NAME
