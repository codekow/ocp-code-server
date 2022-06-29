#!/bin/bash
set -e

# OCP 4.2+ UID handling
# Set current user in nss_wrapper
# Generate passwd file based on current uid and use NSS_WRAPPER to set it
# This is required for ssh to work.  
USER_NAME=coder
USER_ID=$(id -u)
GROUP_ID=$(id -g)
HOME=/home/coder

# fix: ssh perms
# address issue for some storage classes
# where sticky bit in /coder/home modifies
# .ssh folder on pod restarts
if [ -f ${HOME}/.ssh/id_rsa ]; then
    chmod 700 ${HOME}/.ssh
    chmod 600 ${HOME}/.ssh/id_rsa*

    if [ -f ${HOME}/.ssh/known_hosts ]; then
        chmod 600 ${HOME}/.ssh/known_hosts
    fi
fi

#fix: uid issues
if ! whoami &> /dev/null; then
    echo "fix: uid"
    NSS_WRAPPER_PASSWD=/tmp/passwd.nss_wrapper

    grep -v -e ^"${USER_NAME:-coder}" -e ^"${USER_ID:-coder}" /etc/passwd > $NSS_WRAPPER_PASSWD
    echo "${USER_NAME:-coder}:x:${USER_ID}:0:${USER_NAME:-coder} user:${HOME}:/bin/bash" >> $NSS_WRAPPER_PASSWD

    if [ -w /etc/passwd ]; then
        cat $NSS_WRAPPER_PASSWD > /etc/passwd
    else
        echo "fix: nss_wrapper"
        if [ -e /usr/lib/x86_64-linux-gnu/libnss_wrapper.so ]; then
            LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libnss_wrapper.so
        else
            LD_PRELOAD=/usr/lib64/libnss_wrapper.so
        fi
        
        # use nss passwd
        if [ x"${USER_ID}" != x"0" -a x"${USER_ID}" != x"1001" ]; then
            export LD_PRELOAD
            export NSS_WRAPPER_PASSWD
        fi
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
