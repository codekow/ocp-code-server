#!/bin/bash
set -e

# Correct issue for some storage classes
# where sticky bit in /coder/home modifies
# .ssh folder on pod restarts
if [ -f ${HOME}/.ssh/id_rsa ]; then
    chmod 700 ${HOME}/.ssh
    chmod 600 ${HOME}/.ssh/id_rsa*

    if [ -f ${HOME}/.ssh/known_hosts ]; then
        chmod 600 ${HOME}/.ssh/known_hosts
    fi
fi

# fix: node CA trust defaults for requests / node
if [ -e /etc/pki/tls/certs/ca-bundle.crt ]; then
    export REQUESTS_CA_BUNDLE=/etc/pki/tls/certs/ca-bundle.crt
    #export NODE_EXTRA_CA_CERTS=/etc/pki/tls/certs/ca-bundle.crt
else
    export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
fi

# fix: path for local bin
export PATH=$PATH:/home/coder/.local/bin

# kludge: initalize /home/coder
cp -an /etc/skel/.{bash,profile}* ${HOME} 2>/dev/null || true

# fix: setup npm defaults if the script exists
if [ -f /usr/local/bin/npm-setup.sh ]; then
     /usr/local/bin/npm-setup.sh
fi

# kludge: opinionated defaults
if [ ! -e ${HOME}/.local/share/code-server/User/settings.json ]; then
mkdir -p ${HOME}/.local/share/code-server/User
echo '{
    "workbench.colorTheme": "Abyss",
    "terminal.integrated.defaultProfile.linux": "bash",
    "terminal.integrated.shell.linux": "/bin/bash",
    "telemetry.enableTelemetry": false
}' > ${HOME}/.local/share/code-server/User/settings.json
fi

exec "$@"
