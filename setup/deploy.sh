#!/bin/sh

oc project
sleep 3

cd "$(dirname "$0")" || exit 1

# used to deploy
# update the values in the variables below to change your deployment

TEMPLATE=../openshift/deploy-code-server-template.yml
APPLICATION_NAME=custom-code-server
VOLUME_SIZE=5Gi
CODE_SERVER_MEM_LIMIT=750M
CODE_SERVER_CPU_LIMIT=400m
WEBDAV_MEM_LIMIT=128M
WEBDAV_CPU_LIMIT=100m
CODE_SERVER_PASSWORD="thisisfine"
CODE_LABEL='testing=true'

oc process -f "$TEMPLATE" \
    -l ${CODE_LABEL} \
    -p APPLICATION_NAME=${APPLICATION_NAME} \
    -p VOLUME_SIZE=${VOLUME_SIZE} \
    -p CODE_SERVER_MEM_LIMIT=${CODE_SERVER_MEM_LIMIT} \
    -p CODE_SERVER_CPU_LIMIT=${CODE_SERVER_CPU_LIMIT} \
    -p WEBDAV_MEM_LIMIT=${WEBDAV_MEM_LIMIT} \
    -p WEBDAV_CPU_LIMIT=${WEBDAV_CPU_LIMIT} \
    -p CODE_SERVER_PASSWORD=${CODE_SERVER_PASSWORD} \
    | oc apply -f -
sleep 2
