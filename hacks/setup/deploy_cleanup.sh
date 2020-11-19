#!/bin/sh

# Update the application name to match the value of your deployment
APPLICATION_NAME=custom-code-server

# list the current project and wait for user allow user to bail out
oc project
echo "Preparing to delete the following items:"
oc get all,deploymentconfig,pvc,route,service,secret -l app=${APPLICATION_NAME} --no-headers | awk '{print $1}'
sleep 6

oc delete all,deploymentconfig,pvc,route,service,secret -l app=${APPLICATION_NAME}