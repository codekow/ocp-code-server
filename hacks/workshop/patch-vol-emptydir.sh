#!/bin/bash

APPLICATION_NAME=${1:-custom-code-server}

oc get dc "$APPLICATION_NAME" -o yaml | sed -e 's/persistentVolumeClaim:.*$/emptyDir: {}/g; /claimName/d' | oc replace -f -
oc delete pvc "${APPLICATION_NAME}-data"