#!/bin/sh

BUILD_REF=$(git rev-parse --abbrev-ref HEAD)
LABEL=${LABEL:-"testing=true"}

cd "$(dirname "$0")" || exit 1

build_codercom(){
TEMPLATE=../openshift/build/build-code-server-codercom-template.yml
oc process -f ${TEMPLATE} -p BUILD_REF="${BUILD_REF:-main}" -l "${LABEL}" | oc apply -f -
}

build_ubi(){
TEMPLATE=../openshift/build/build-code-server-ubi-template.yml
oc process -f ${TEMPLATE} -p BUILD_REF="${BUILD_REF:-main}" -l "${LABEL}" | oc apply -f -
}

build_webdev(){
WEBDAV_GIT_URL=https://raw.githubusercontent.com/codekow/webdav/main/node/openshift/build
WEBDAV_IMAGE=${WEBDAV_GIT_URL}/imagestream-webdav.yml
WEBDAV_BUILD=${WEBDAV_GIT_URL}/buildconfig-webdav.yml

curl -sL ${WEBDAV_IMAGE} | oc apply -f -
curl -sL ${WEBDAV_BUILD} | oc apply -f -
}

build_codercom
build_ubi
build_webdev