#!/bin/bash

oc project
sleep 6

APPLICATION_NAME=${1:-code-server}

for NUM in {01..75}
  do

  oc delete all,deploymentconfig,pvc,imagestream,route -l app="${APPLICATION_NAME}-${NUM}"

done