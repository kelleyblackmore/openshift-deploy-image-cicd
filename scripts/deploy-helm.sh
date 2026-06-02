#!/usr/bin/env bash
set -euo pipefail

: "${OPENSHIFT_SERVER:?OPENSHIFT_SERVER is required}"
: "${OPENSHIFT_TOKEN:?OPENSHIFT_TOKEN is required}"
: "${OPENSHIFT_PROJECT:?OPENSHIFT_PROJECT is required}"
: "${HELM_RELEASE:?HELM_RELEASE is required}"
: "${HELM_CHART:?HELM_CHART is required}"

HELM_NAMESPACE="${HELM_NAMESPACE:-$OPENSHIFT_PROJECT}"
HELM_VALUES_FILE="${HELM_VALUES_FILE:-values.yaml}"
HELM_TIMEOUT="${HELM_TIMEOUT:-10m}"

echo "Logging into OpenShift..."
oc login "${OPENSHIFT_SERVER}" \
  --token="${OPENSHIFT_TOKEN}" \
  --insecure-skip-tls-verify="${OPENSHIFT_INSECURE_SKIP_TLS_VERIFY:-false}"

echo "Selecting project: ${OPENSHIFT_PROJECT}"
oc project "${OPENSHIFT_PROJECT}"

echo "Deploying Helm release: ${HELM_RELEASE}"
if [[ -f "${HELM_VALUES_FILE}" ]]; then
  helm upgrade --install "${HELM_RELEASE}" "${HELM_CHART}" \
    --namespace "${HELM_NAMESPACE}" \
    --values "${HELM_VALUES_FILE}" \
    --create-namespace \
    --atomic \
    --wait \
    --timeout "${HELM_TIMEOUT}"
else
  helm upgrade --install "${HELM_RELEASE}" "${HELM_CHART}" \
    --namespace "${HELM_NAMESPACE}" \
    --create-namespace \
    --atomic \
    --wait \
    --timeout "${HELM_TIMEOUT}"
fi

echo "Deployment complete."

echo "Current project resources:"
oc get all -n "${OPENSHIFT_PROJECT}"
