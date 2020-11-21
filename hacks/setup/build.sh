#!/bin/sh

cd "$(dirname "$0")" || exit 1

WEBDAV_GIT_URL=https://raw.githubusercontent.com/happykow/webdav/main/node/openshift/build
WEBDAV_IMAGE=${WEBDAV_GIT_URL}/imagestream-webdav.yml
WEBDAV_BUILD=${WEBDAV_GIT_URL}/buildconfig-webdav.yml

CODE_SERVER_BUILD=../../openshift/build/build-code-server-base-centos.yml
oc process -f ${CODE_SERVER_BUILD} -p BUILD_REF=dev | oc apply -f -

CODE_SERVER_BUILD=../../openshift/build/build-code-server-docker-centos-patch.yml
oc apply -f ${CODE_SERVER_BUILD}

CODE_SERVER_BUILD=../../openshift/build/build-code-server-base-debian.yml
oc process -f ${CODE_SERVER_BUILD} -p BUILD_REF=dev | oc apply -f -

CODE_SERVER_BUILD=../../openshift/build/build-code-server-docker-debian-patch.yml
oc apply -f ${CODE_SERVER_BUILD}


curl -sL ${WEBDAV_IMAGE} | oc apply -f -
curl -sL ${WEBDAV_BUILD} | oc apply -f -