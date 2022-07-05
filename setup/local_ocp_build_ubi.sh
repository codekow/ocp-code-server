#!/bin/bash

VERSION_TAG=latest
CODE_LABEL='testing=true'

# import container image streams
init_image_stream(){
oc import-image ubi:${VERSION_TAG} \
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
  --name=custom-code-server-ubi-base \
  --image-stream=ubi:${VERSION_TAG} \
  --to=custom-code-server:ubi-base

oc patch bc custom-code-server-ubi-base \
  --type='json' \
  --patch='[{"op": "add", "path": "/spec/strategy/dockerStrategy/dockerfilePath", "value": "Dockerfile.ubi8"}]'

oc start-build \
  custom-code-server-ubi-base \
  --from-dir container/base \
  --follow
}

# build - patch
build_patch(){
oc new-build \
  --binary \
  --name=custom-code-server-ubi-patch \
  --image-stream=custom-code-server:ubi-base \
  --to custom-code-server:ubi \
  --allow-missing-imagestream-tags

oc patch bc custom-code-server-ubi-patch \
  --type='json' \
  --patch='[{"op": "add", "path": "/spec/strategy/dockerStrategy/dockerfilePath", "value": "Dockerfile.ubi8"}]'

oc start-build \
  custom-code-server-ubi-patch \
  --from-dir container/patch
}

init_image_stream
build_base
build_patch