#!/bin/bash -ex

export GOOGLE_APPLICATION_CREDENTIALS=/keyconfig.json
deployment=$1

codeship_google authenticate
gcloud config set compute/zone us-central1-a
gcloud container clusters get-credentials "$deployment"

# Deploy the last sha256 deployed against the deployment tag
docker inspect --format='{{index .RepoDigests 0}}' "smartcontract/chainlink:$deployment" \
  | awk -F'@' '{print$2}' \
  | xargs -I'%' kubectl set image \
      deployment.apps/chainlink-deploy \
      "chainlink=smartcontract/chainlink:$deployment@%"
