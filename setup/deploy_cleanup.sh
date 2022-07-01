#!/bin/sh

# Update the application name to match the value of your deployment
CODE_LABEL='testing=true'

# list the current project and wait for user allow user to bail out
oc project
echo "Preparing to delete the following items:"
oc get deployment,pvc,route,service,secret -l ${CODE_LABEL} --no-headers | awk '{print $1}'
sleep 6

oc delete deployment,pvc,route,service,secret -l ${CODE_LABEL}