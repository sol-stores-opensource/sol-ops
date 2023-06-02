#!/bin/bash
if [ -f "./run.secret.sh" ]; then
  . "./run.secret.sh"
fi
## BEGIN EDIT
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
'gcloud')
  shift
  gcloud $@
  ;;
'kubeconfig')
  gcloud container clusters get-credentials $gke_name
  ;;
'k9s')
  k9s --context $context_name --command dp
  ;;
'cloud_sql_proxy')
  echo "Starting cloud_sql_proxy.  Connect on localhost:18642 from psql or other clients.  Be sure to ctrl-c it when done."
  set -x
  cloud_sql_proxy -instances=$CLOUDSDK_CORE_PROJECT:us-west2:REPLACE-YOUR-POSTGRES-INSTANCE-NAME=tcp:18642
  ;;
'exec')
  shift
  $@
  ;;
*)
  echo "Invalid input.  fmt, plan, apply, output, kubeconfig, k9s"
  exit 1
  ;;
esac
