#!/bin/bash
# shellcheck disable=SC1004

# Try and work out the correct version of the command line tools to use
# if not explicitly specified in environment. This assumes you will be
# using the same cluster the deployment is to.

KUBERNETES_SERVER=$KUBERNETES_PORT_443_TCP_ADDR:$KUBERNETES_PORT_443_TCP_PORT

export no_proxy=$no_proxy,$KUBERNETES_PORT_443_TCP_ADDR

if [ x"$KUBERNETES_SERVER" != x":" ]; then
    if [ -z "$KUBECTL_VERSION" ]; then
        KUBECTL_VERSION=$( (curl -s -k https://"$KUBERNETES_SERVER"/version | \
            python -c 'from __future__ import print_function; import sys, json; \
            info = json.loads(sys.stdin.read()); \
            info and print("%s.%s" % (info["major"], info["minor"]))' ) || true )
    fi
fi

if [ -z "$OC_VERSION" ]; then
    case "$KUBECTL_VERSION" in
        1.11|1.11+)
            OC_VERSION=${OC3_VERSION%.*}
            ;;
        *)
            OC_VERSION=${OC4_VERSION%.*}
            ;;
    esac
fi

export OC_VERSION
export KUBECTL_VERSION


if [ -e /usr/local/bin/oc-$OC_VERSION ]; then
    exec /usr/local/bin/oc-$OC_VERSION "$@"
else
    /bin/true
fi
