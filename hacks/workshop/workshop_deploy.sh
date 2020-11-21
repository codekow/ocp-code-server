#!/bin/bash

oc project
sleep 3

cd "$(dirname "$0")" || exit 1

# used to deploy
# update the values in the variables below to change your deployment

TEMPLATE=${1:-../../deploy-code-server-template.yml}
APPLICATION_NAME=code-server
VOLUME_SIZE=5Gi
CODE_SERVER_MEM_LIMIT=2Gi
CODE_SERVER_CPU_LIMIT=1700m
WEBDAV_MEM_LIMIT=256M
WEBDAV_CPU_LIMIT=300m
CODE_SERVER_PASSWORD="codetime"


for NUM in {01..75}
  do

  oc process -f "$TEMPLATE" \
    -p APPLICATION_NAME="${APPLICATION_NAME}-${NUM}" \
    -p VOLUME_SIZE=${VOLUME_SIZE} \
    -p CODE_SERVER_MEM_LIMIT=${CODE_SERVER_MEM_LIMIT} \
    -p CODE_SERVER_CPU_LIMIT=${CODE_SERVER_CPU_LIMIT} \
    -p WEBDAV_MEM_LIMIT=${WEBDAV_MEM_LIMIT} \
    -p WEBDAV_CPU_LIMIT=${WEBDAV_CPU_LIMIT} \
    -p CODE_SERVER_PASSWORD="${CODE_SERVER_PASSWORD}${NUM}" \
    | oc apply -f -

  sleep 1
  oc patch dc "$APPLICATION_NAME-$NUM" -p "$(cat patch-gpu-node-taint.yml)"
  sleep 1
  ./patch-vol-emptydir.sh "${APPLICATION_NAME}-${NUM}"

done

