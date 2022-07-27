#!/bin/bash

LOG_FILE="/usr/games/minecraft.log"

function minecraft_log() {
    echo "${*}" | tee -a "${LOG_FILE}" > /dev/null
}

minecraft_log "Initializing Bedrock server environment at $(date)"

# ---------------------------------------------------------------------------------------

INSTANCE_ID="$(curl "http://169.254.169.254/latest/meta-data/instance-id")"
AWS_REGION="$(curl -q "http://169.254.169.254/latest/dynamic/instance-identity/document" | \
    jq -r '.region')"

minecraft_log "Fetching instance details"
STACK_NAME="$(aws ec2 describe-tags \
    --region "${AWS_REGION}" \
    --filters \
        "Name=resource-id,Values=${INSTANCE_ID}" \
        "Name=key,Values=aws:cloudformation:stack-name" \
        "Name=resource-type,Values=instance" \
    --query 'Tags[0].Value' \
    --output text)"
STACK_UUID="$(aws ec2 describe-tags \
    --region "${AWS_REGION}" \
    --filters \
        "Name=resource-id,Values=${INSTANCE_ID}" \
        "Name=key,Values=uuid" \
        "Name=resource-type,Values=instance" \
    --query 'Tags[0].Value' \
    --output text)"

BEDROCK_ROOT_DIR="/usr/games/minecraft"

# ---------------------------------------------------------------------------------------

# Fetch value from SSM parameter store.
function get_ssm_parameter() {
    aws ssm get-parameter \
        --name "${1}" \
        --region "${AWS_REGION}" \
        --query 'Parameter.Value' \
        --output text
}

# Fetch value from AWS SecretsManager.
function get_secret_value() {
    aws secretsmanager get-secret-value \
        --secret-id "${1}" \
        --region "${AWS_REGION}" \
        --query 'SecretString' \
        --output text
}

minecraft_log "Environment initialization complete at $(date)"