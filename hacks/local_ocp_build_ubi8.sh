#!/bin/bash

VERSION_TAG=8.6

# import container image streams
init_image_stream(){
oc import-image ubi8:${VERSION_TAG} \
  --from=registry.access.redhat.com/ubi8/ubi:${VERSION_TAG} \
  --scheduled \
  --confirm

# create image stream - custom-code-server
oc create is custom-code-server
}

# build - base
build_base(){
oc new-build \
  --binary \
  --name=custom-code-server-ubi8-base \
  --image-stream=ubi8:${VERSION_TAG} \
  --to=custom-code-server:ubi8-base

oc patch bc custom-code-server-ubi8-base \
  --type='json' \
  --patch='[{"op": "add", "path": "/spec/strategy/dockerStrategy/dockerfilePath", "value": "Dockerfile.ubi8"}]'

oc start-build \
  custom-code-server-ubi8-base \
  --from-dir container/base
}

# build - patch
build_patch(){
oc new-build \
  --binary \
  --name=custom-code-server-ubi8-patch \
  --image-stream=custom-code-server:ubi8-base \
  --to custom-code-server:ubi8 \
  --allow-missing-imagestream-tags

oc patch bc custom-code-server-ubi8-patch \
  --type='json' \
  --patch='[{"op": "add", "path": "/spec/strategy/dockerStrategy/dockerfilePath", "value": "Dockerfile.ubi8"}]'

oc start-build \
  custom-code-server-ubi8-patch \
  --from-dir container/patch
}

init_image_stream
build_base
build_patch