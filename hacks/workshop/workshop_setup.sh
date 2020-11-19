#!/bin/bash

cd "$(dirname "$0")" || exit 1

# used to setup workshop

APPLICATION_NAME=${1:-code-server}
DEPLOY_TOKEN='random'

for NUM in {01..75}
  do

  POD=$(oc get pod -l app="${APPLICATION_NAME}-${NUM}" --no-headers | grep Running | cut -f1 -d' ')
  echo "$POD"

  oc exec -c custom-code-server "$POD" -- bash -c "git clone https://${DEPLOY_TOKEN}@github.com/python-101.git /home/coder/python-101"
  oc exec -c custom-code-server "$POD" -- bash -c "pip install pandas plotly numpy"
  oc exec -c custom-code-server "$POD" -- bash -c "code-server --install-extension ms-python.python"
  oc exec -c custom-code-server "$POD" -- bash -c "code-server --install-extension jithurjacob.nbpreviewer"
  
done