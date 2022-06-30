#!/bin/sh

# Update the application name to match the value of your deployment
CODE_SERVER_BUILD=custom-code-server
WEBDAV_BUILD=webdav-node

# list the current project and wait for user allow user to bail out
oc project
echo "Preparing to delete the following items:"
oc get all,ImageStream,BuildConfig -l build=${CODE_SERVER_BUILD} --no-headers | awk '{print $1}'
oc get all,ImageStream,BuildConfig -l build=${WEBDAV_BUILD} --no-headers | awk '{print $1}'
sleep 6

oc delete all,ImageStream,BuildConfig -l build=${CODE_SERVER_BUILD}
oc delete all,ImageStream,BuildConfig -l build=${WEBDAV_BUILD}