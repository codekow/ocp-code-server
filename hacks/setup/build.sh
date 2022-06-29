#!/bin/sh

cd "$(dirname "$0")" || exit 1

WEBDAV_GIT_URL=https://raw.githubusercontent.com/codekow/webdav/main/node/openshift/build
WEBDAV_IMAGE=${WEBDAV_GIT_URL}/imagestream-webdav.yml
WEBDAV_BUILD=${WEBDAV_GIT_URL}/buildconfig-webdav.yml

CODE_SERVER_BUILD=../../openshift/build/build-code-server-ubi-template.yml
oc process -f ${CODE_SERVER_BUILD} -p BUILD_REF=main | oc apply -f -

CODE_SERVER_BUILD=../../openshift/build/build-code-server-base-codercom-template.yml
oc process -f ${CODE_SERVER_BUILD} -p BUILD_REF=main | oc apply -f -

CODE_SERVER_BUILD=../../openshift/build/build-code-server-dockerfile-codercom-patch.yml
oc apply -f ${CODE_SERVER_BUILD}


curl -sL ${WEBDAV_IMAGE} | oc apply -f -
curl -sL ${WEBDAV_BUILD} | oc apply -f -