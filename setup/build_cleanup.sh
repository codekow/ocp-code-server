#!/bin/sh

# Update the application name to match the value of your deployment
CODE_LABEL='testing=true'
WEBDEV_LABEL='build=webdav-node'

# list the current project and wait for user allow user to bail out
oc project
echo "Preparing to delete the following items:"
oc get all,imagestream,buildconfig -l ${CODE_LABEL} --no-headers | awk '{print $1}'
oc get all,imagestream,buildconfig -l ${WEBDEV_LABEL} --no-headers | awk '{print $1}'
sleep 6

oc delete all,imagestream,buildconfig -l ${CODE_LABEL}
oc delete all,imagestream,buildconfig -l ${WEBDEV_LABEL}