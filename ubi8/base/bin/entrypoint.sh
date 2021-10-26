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
    chmod 600 ${HOME}/.ssh/id_rsa*

    if [ -f ${HOME}/.ssh/known_hosts ]; then
        chmod 600 ${HOME}/.ssh/known_hosts
    fi
fi

NSS_WRAPPER_PASSWD=/tmp/passwd.nss_wrapper

if ! whoami &> /dev/null; then
    if [ -w /etc/passwd ]; then
        grep -v -e ^${USER_NAME:-coder} -e ^"${USER_ID}" /etc/passwd > $NSS_WRAPPER_PASSWD
        echo "${USER_NAME:-coder}:x:${USER_ID}:0:${USER_NAME:-coder} user:${HOME}:/bin/bash" >> $NSS_WRAPPER_PASSWD
        cat $NSS_WRAPPER_PASSWD > /etc/passwd
    fi
fi

if [ ! -w /etc/passwd -a x"${USER_ID}" != x"0" -a x"${USER_ID}" != x"1001" ]; then
    cp /etc/passwd $NSS_WRAPPER_PASSWD

    echo "${USER_NAME:-coder}:x:$(id -u):0:${USER_NAME:-coder} user:${HOME}:/bin/bash" >> $NSS_WRAPPER_PASSWD

    export NSS_WRAPPER_PASSWD
    export LD_PRELOAD=/usr/lib64/libnss_wrapper.so

fi

# Initalize /home/coder (quickfix)
cp -an /etc/skel/.{bash,profile,screenrc}* /home/coder

# setup the npm defaults if the script exists
if [ -f /usr/local/bin/npm-setup.sh ]; then
     /usr/local/bin/npm-setup.sh
fi

exec "$@"
