#!/bin/bash

## BEGIN EDIT
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/legacy_credentials/REPLACE-YOUR-PATH/adc.json"
export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="$GOOGLE_APPLICATION_CREDENTIALS"
export CLOUDSDK_CORE_PROJECT=REPLACE-YOUR-PROJECT-ID
export CLOUDSDK_COMPUTE_REGION=us-west2
# Only known after initial terraform and needs to be hard-coded here
# Get from:
#   gcloud container clusters list --project xyz
gke_name="REPLACE-YOUR-GKE-CLUSTER"
context_name="gke_${CLOUDSDK_CORE_PROJECT}_${CLOUDSDK_COMPUTE_REGION}_${gke_name}"
## END EDIT

fmt() {
  terraform fmt -recursive -diff ../
}

case "$1" in
'fmt')
  fmt
  ;;
'terraform')
  shift
  fmt
  terraform $@
  ;;
'plan')
  shift
  fmt
  terraform plan $@
  ;;
'apply')
  shift
  fmt
  terraform apply $@
  ;;
'output')
  shift
  terraform output -json $@
  ;;
'kubeconfig')
  gcloud container clusters get-credentials $gke_name
  ;;
'k9s')
  k9s --context $context_name --command dp
  ;;
*)
  echo "Invalid input.  fmt, plan, apply, output, kubeconfig, k9s"
  exit 1
  ;;
esac
