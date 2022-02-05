#!/bin/bash

# import container image streams
oc import-image ubi8:8.5 \
  --from=registry.access.redhat.com/ubi8/ubi:8.5 \
  --scheduled \
  --confirm

# create image stream - custom-code-server
oc create is custom-code-server

# build configs - base
oc new-build \
  --binary \
  --name=custom-code-server-ubi8-base \
  --image-stream=ubi8:8.5 \
  --to=custom-code-server:ubi8-base

oc patch bc custom-code-server-ubi8-base \
  --type='json' \
  --patch='[{"op": "add", "path": "/spec/strategy/dockerStrategy/dockerfilePath", "value": "Dockerfile.ubi8"}]'

# build configs - patch
oc new-build \
  --binary \
  --name=custom-code-server-ubi8-patch \
  --image-stream=custom-code-server:ubi8-base \
  --to custom-code-server:ubi8 \
  --allow-missing-imagestream-tags

oc patch bc custom-code-server-ubi8-base \
  --type='json' \
  --patch='[{"op": "add", "path": "/spec/strategy/dockerStrategy/dockerfilePath", "value": "Dockerfile.ubi8"}]'

# binary / local source builds
oc start-build \
  custom-code-server-ubi8-base \
  --from-dir container/base \
  --follow

oc start-build \
  custom-code-server-ubi8-patch \
  --from-dir container/patch
