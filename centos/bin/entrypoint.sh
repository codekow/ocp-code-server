#!/bin/bash
set -e

# OCP 4.2+ UID handling
# Set current user in nss_wrapper
# Generate passwd file based on current uid and use NSS_WRAPPER to set it
USER_ID=$(id -u)
GROUP_ID=$(id -g)
HOME=/home/coder

# Correct issue for some storage classes 
# where sticky bit in /coder/home modifies
# .ssh folder on pod restarts
if [ -f ${HOME}/.ssh/id_rsa ]; then
    chmod 700 ${HOME}/.ssh
    chmod 644 ${HOME}/.ssh/*pub
    chmod 600 ${HOME}/.ssh/id_rsa*

    if [ -f ${HOME}/.ssh/known_hosts ]; then
        chmod 600 ${HOME}/.ssh/known_hosts
    fi
fi

grep -v -e ^coder -e ^"$USER_ID" /etc/passwd > "/tmp/.uid-kludge"

echo "coder:x:${USER_ID}:${GROUP_ID}:Coder User:${HOME}:/sbin/nologin" >> "/tmp/.uid-kludge"

export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/.uid-kludge
export NSS_WRAPPER_GROUP=/etc/group


# Initalize /home/coder (quickfix)
cp -an /etc/skel/.{bash,zsh}* /home/coder

# setup the npm defaults if the script exists
if [ -f /usr/local/bin/npm-setup.sh ]; then
     /usr/local/bin/npm-setup.sh
fi

exec "$@"
