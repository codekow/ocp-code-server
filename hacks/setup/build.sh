#!/bin/sh

cd "$(dirname "$0")" || exit 1

CODE_SERVER_BUILD=../build-code-server.yml

WEBDAV_GIT_URL=
WEBDAV_IMAGE=${WEBDAV_GIT_URL}/imageStream-webdav.yml
WEBDAV_BUILD=${WEBDAV_GIT_URL}/buildConfig-webdav.yml

oc apply -f ${CODE_SERVER_BUILD}
curl -s ${WEBDAV_IMAGE} | oc apply -f -
curl -s ${WEBDAV_BUILD} | oc apply -f -