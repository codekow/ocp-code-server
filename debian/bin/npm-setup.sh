#!/bin/bash
set -e

if [ -n "${HTTP_PROXY:-}" ]; then
    echo "---> Setting npm http proxy to $HTTP_PROXY"
	npm config set proxy "$HTTP_PROXY"
fi

if [ -n "${http_proxy:-}" ]; then
    echo "---> Setting npm http proxy to $http_proxy"
	npm config set proxy "$http_proxy"
fi

if [ -n "${HTTPS_PROXY:-}" ]; then
    echo "---> Setting npm https proxy to $HTTPS_PROXY"
	npm config set https-proxy "$HTTPS_PROXY"
fi

if [ -n "${https_proxy:-}" ]; then
    echo "---> Setting npm https proxy to $https_proxy"
	npm config set https-proxy "$https_proxy"
fi

# Change the npm registry mirror if provided
if [ -n "${NPM_MIRROR:-}" ]; then
	echo "---> Setting npm mirror to $NPM_MIRROR"
    npm config set registry "$NPM_MIRROR"
    npm config set cafile /etc/ssl/certs/ca-certificates.crt
fi

# Check if NPM_AUTH is not set and Nexus variables are provided
if [[ -z "${NPM_AUTH:-}" && -n "${NEXUS_USER:-}" && -n "${NEXUS_PASSWORD:-}" ]]; then
    echo "---> Using NEXUS_USER and NEXUS_PASSWORD to set NPM_AUTH"
    NPM_AUTH=$(echo -n "${NEXUS_USER}:${NEXUS_PASSWORD}" | base64)
fi

if [ -n "${NPM_AUTH:-}" ]; then
    echo "---> Setting npm _auth to provided NPM_AUTH variable"
    npm config set always-auth true
    npm config set _auth "$NPM_AUTH"
fi
