#!/bin/bash

latest_tag() {
#tag debian latest

TYPE=$1
docker tag custom-code-server:${TYPE} custom-code-server:latest
}

code_server_build() {
NAME=custom-code-server
TYPE=$1

pushd container/base
docker build -t "${NAME}:${TYPE}-base" -f Dockerfile.${TYPE} .

cd ../patch
docker build -t "${NAME}:${TYPE}" -f Dockerfile.${TYPE} .

popd

latest_tag ${TYPE}

}

#build debian
#build centos

echo "usage: code_server_build {debian,ubi8}"
