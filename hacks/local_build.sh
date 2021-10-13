#!/bin/bash

latest_tag() {
#tag debian latest
docker tag custom-code-server:debian custom-code-server:latest
}

code_server_build() {
NAME=custom-code-server
TYPE=$1

pushd ${TYPE}/base
docker build -t "${NAME}:${TYPE}-base" .

cd ../patch
docker build -t "${NAME}:${TYPE}" .

popd
}

#build debian
#build centos

echo "usage: code_server_build debian && latest_tag"
