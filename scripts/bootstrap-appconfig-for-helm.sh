#!/usr/bin/env bash
# Create (idempotently) the AWS AppConfig resources the hack Helm path expects:
# application = SERVICE_NAME, environment "hack", hosted profiles "in-hack-helm-configs"
# and "in-hack-app-config", plus a custom deployment strategy "AllAtOnce" (0m / 0m) if missing.
#
# Uploads helm/config.yml as a new hosted version on profile "in-hack-app-config" (no deployment).
# You must deploy that version (and your helm values profile) from the console when ready.
#
# Prerequisites: aws CLI v2, jq.
# Auth: AWS_PROFILE (and optionally AWS_REGION; defaults to ap-south-1).
#
# Optional env:
#   APPCONFIG_APP_CONFIG_YML  path to YAML for profile in-hack-app-config (default: helm/config.yml)
#
# Usage:
#   export AWS_PROFILE=your-profile
#   export AWS_REGION=ap-south-1   # optional
#   ./scripts/bootstrap-appconfig-for-helm.sh SERVICE_NAME

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

readonly CONFIG_PROFILE_HELM="in-hack-helm-configs"
readonly CONFIG_PROFILE_APP="in-hack-app-config"
readonly ENVIRONMENT_NAME="hack"
readonly DEPLOY_STRATEGY_NAME="AllAtOnce"
readonly DEFAULT_CONFIG_YML="${REPO_ROOT}/helm/config.yml"

usage() {
  echo "Usage: AWS_PROFILE=... $0 SERVICE_NAME" >&2
  echo "  Creates AppConfig app, env, both hosted profiles, AllAtOnce strategy (if missing)," >&2
  echo "  and uploads ${DEFAULT_CONFIG_YML} to profile \"${CONFIG_PROFILE_APP}\"." >&2
  echo "  Deploy hosted versions from the AWS console when ready." >&2
  echo "Env: AWS_PROFILE (required), AWS_REGION (optional, default ap-south-1)" >&2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ -z "${AWS_PROFILE:-}" ]]; then
  echo "error: AWS_PROFILE is not set" >&2
  usage
  exit 1
fi

SERVICE_NAME="${1:?SERVICE_NAME is required}"
REGION="${AWS_REGION:-ap-south-1}"
CONFIG_YML="${APPCONFIG_APP_CONFIG_YML:-${DEFAULT_CONFIG_YML}}"

if [[ ! -f "${CONFIG_YML}" ]]; then
  echo "error: app config file not found: ${CONFIG_YML}" >&2
  echo "  Set APPCONFIG_APP_CONFIG_YML to override path." >&2
  exit 1
fi

command -v aws >/dev/null 2>&1 || {
  echo "error: aws CLI not found" >&2
  exit 1
}
command -v jq >/dev/null 2>&1 || {
  echo "error: jq not found" >&2
  exit 1
}

aws_cli() {
  aws --profile "${AWS_PROFILE}" --region "${REGION}" "$@"
}

find_application_id() {
  local name="$1"
  aws_cli appconfig list-applications --output json |
    jq -r --arg n "${name}" '.Items[]? | select(.Name == $n) | .Id' |
    head -1
}

find_environment_id() {
  local app_id="$1"
  aws_cli appconfig list-environments --application-id "${app_id}" --output json |
    jq -r --arg n "${ENVIRONMENT_NAME}" '.Items[]? | select(.Name == $n) | .Id' |
    head -1
}

find_configuration_profile_id() {
  local app_id="$1"
  local profile_name="$2"
  aws_cli appconfig list-configuration-profiles --application-id "${app_id}" --output json |
    jq -r --arg n "${profile_name}" '.Items[]? | select(.Name == $n) | .Id' |
    head -1
}

lookup_deployment_strategy_id() {
  aws_cli appconfig list-deployment-strategies --max-results 50 --output json |
    jq -r --arg n "${DEPLOY_STRATEGY_NAME}" '.Items[]? | select(.Name == $n) | .Id' |
    head -1
}

ensure_deployment_strategy() {
  local id=""
  id="$(lookup_deployment_strategy_id)"
  if [[ -n "${id}" ]]; then
    echo "Using existing deployment strategy: ${DEPLOY_STRATEGY_NAME} (${id})" >&2
    echo "${id}"
    return 0
  fi
  echo "Creating deployment strategy: ${DEPLOY_STRATEGY_NAME} (0m deployment, 0m final bake)" >&2
  id="$(
    aws_cli appconfig create-deployment-strategy \
      --name "${DEPLOY_STRATEGY_NAME}" \
      --description "Immediate rollout for hackathon Helm values (avoid AppConfig.AllAtOnce 10m bake)" \
      --deployment-duration-in-minutes 0 \
      --final-bake-time-in-minutes 0 \
      --growth-factor 100 \
      --replicate-to NONE \
      --query Id \
      --output text
  )"
  echo "${id}"
}

ensure_configuration_profile() {
  local app_id="$1"
  local profile_name="$2"
  local id=""
  id="$(find_configuration_profile_id "${app_id}" "${profile_name}")"
  if [[ -n "${id}" ]]; then
    echo "Using existing configuration profile: ${profile_name} (${id})" >&2
    echo "${id}"
    return 0
  fi
  echo "Creating configuration profile: ${profile_name}" >&2
  id="$(
    aws_cli appconfig create-configuration-profile \
      --application-id "${app_id}" \
      --name "${profile_name}" \
      --location-uri "hosted" \
      --type "AWS.Freeform" \
      --query Id \
      --output text
  )"
  echo "${id}"
}

APP_ID="$(find_application_id "${SERVICE_NAME}")"
if [[ -z "${APP_ID}" ]]; then
  echo "Creating AppConfig application: ${SERVICE_NAME}"
  APP_ID="$(aws_cli appconfig create-application --name "${SERVICE_NAME}" --query Id --output text)"
else
  echo "Using existing AppConfig application: ${SERVICE_NAME} (${APP_ID})"
fi

ENV_ID="$(find_environment_id "${APP_ID}")"
if [[ -z "${ENV_ID}" ]]; then
  echo "Creating AppConfig environment: ${ENVIRONMENT_NAME}"
  ENV_ID="$(aws_cli appconfig create-environment \
    --application-id "${APP_ID}" \
    --name "${ENVIRONMENT_NAME}" \
    --query Id --output text)"
else
  echo "Using existing AppConfig environment: ${ENVIRONMENT_NAME} (${ENV_ID})"
fi

PROFILE_HELM_ID="$(ensure_configuration_profile "${APP_ID}" "${CONFIG_PROFILE_HELM}")"
PROFILE_APP_ID="$(ensure_configuration_profile "${APP_ID}" "${CONFIG_PROFILE_APP}")"

STRATEGY_ID="$(ensure_deployment_strategy)"

echo "Uploading hosted configuration version for \"${CONFIG_PROFILE_APP}\" from ${CONFIG_YML}"
# AWS CLI v2 requires a positional outfile; JSON metadata is on stdout.
APP_CFG_VERSION_OUT="$(
  aws_cli appconfig create-hosted-configuration-version \
    --application-id "${APP_ID}" \
    --configuration-profile-id "${PROFILE_APP_ID}" \
    --content "fileb://${CONFIG_YML}" \
    --content-type "application/x-yaml" \
    --output json \
    /dev/null
)"

APP_CFG_VERSION="$(echo "${APP_CFG_VERSION_OUT}" | jq -r '.VersionNumber')"
if [[ -z "${APP_CFG_VERSION}" || "${APP_CFG_VERSION}" == "null" ]]; then
  echo "error: could not read VersionNumber from create-hosted-configuration-version output" >&2
  echo "${APP_CFG_VERSION_OUT}" >&2
  exit 1
fi

echo ""
echo "Bootstrap complete (hosted upload for \"${CONFIG_PROFILE_APP}\" only; no deployment started)."
echo "  application_id=${APP_ID}"
echo "  environment_id=${ENV_ID}"
echo "  configuration_profile_id_helm=${PROFILE_HELM_ID} (name=${CONFIG_PROFILE_HELM})"
echo "  configuration_profile_id_app=${PROFILE_APP_ID} (name=${CONFIG_PROFILE_APP})"
echo "  app_config_uploaded_version=${APP_CFG_VERSION}"
echo "  deployment_strategy_id=${STRATEGY_ID} (name=${DEPLOY_STRATEGY_NAME})"
echo ""
echo "You must push (deploy) hosted versions to environment \"${ENVIRONMENT_NAME}\" in the console:"
echo "  1. Profile \"${CONFIG_PROFILE_APP}\" → version ${APP_CFG_VERSION} (just uploaded from helm/config.yml)."
echo "  2. Profile \"${CONFIG_PROFILE_HELM}\" → create a version from helm/values.yaml, then deploy it."
echo ""
echo "Use strategy \"${DEPLOY_STRATEGY_NAME}\" for each deployment. Region: ${REGION}."
