#!/bin/bash

# import container image streams
oc import-image code-server:3.12.0 \
  --from=docker.io/codercom/code-server:3.12.0 \
  --scheduled \
  --confirm

# create image stream - custom-code-server
oc create is custom-code-server

# build configs - base
oc new-build \
  --binary \
  --name=custom-code-server-debian-base \
  --image-stream=code-server:3.12.0 \
  --to=custom-code-server:debian-base

oc patch bc custom-code-server-debian-base \
  --type='json' \
  --patch='[{"op": "add", "path": "/spec/strategy/dockerStrategy/dockerfilePath", "value": "Dockerfile.debian"}]'

# build configs - patch
oc new-build \
  --binary \
  --name=custom-code-server-debian-patch \
  --image-stream=custom-code-server:debian-base \
  --to custom-code-server:debian \
  --allow-missing-imagestream-tags

oc patch bc custom-code-server-debian-patch \
  --type='json' \
  --patch='[{"op": "add", "path": "/spec/strategy/dockerStrategy/dockerfilePath", "value": "Dockerfile.debian"}]'

# binary / local source builds
oc start-build \
  custom-code-server-debian-base \
  --from-dir container/base

oc start-build \
  custom-code-server-debian-patch \
  --from-dir container/patch
