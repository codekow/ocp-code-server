#!/bin/bash

VERSION_TAG=4.5.0
CODE_LABEL='testing=true'

# import container image streams
init_image_stream(){
oc import-image code-server:${VERSION_TAG} \
  --from=docker.io/codercom/code-server:${VERSION_TAG} \
  --scheduled \
  --confirm

# create image stream - custom-code-server
oc create is custom-code-server
}

# build - base
build_base(){
oc new-build \
  --binary \
  --name=custom-code-server-codercom-base \
  --image-stream=code-server:${VERSION_TAG} \
  --to=custom-code-server:codercom-base

oc patch bc custom-code-server-codercom-base \
  --type='json' \
  --patch='[{"op": "add", "path": "/spec/strategy/dockerStrategy/dockerfilePath", "value": "Dockerfile.codercom"}]'

oc start-build \
  custom-code-server-codercom-base \
  --from-dir container/base \
  --follow
}

# build - patch
build_patch(){
oc new-build \
  --binary \
  --name=custom-code-server-codercom-patch \
  --image-stream=custom-code-server:codercom-base \
  --to custom-code-server:codercom \
  --allow-missing-imagestream-tags

oc patch bc custom-code-server-codercom-patch \
  --type='json' \
  --patch='[{"op": "add", "path": "/spec/strategy/dockerStrategy/dockerfilePath", "value": "Dockerfile.codercom"}]'

oc start-build \
  custom-code-server-codercom-patch \
  --from-dir container/patch
}

init_image_stream
build_base
build_patch