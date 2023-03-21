#! /bin/sh

set -e

# We expect the caller to set these environment variables:
: "${VAULT_ADDR?Need to set this environment variable}"
: "${VAULT_DEV_ROOT_TOKEN_ID?Need to set this environment variable}"
: "${MINIO_ADDR?Need to set this environment variable}"
: "${MINIO_REGION_NAME?Need to set this environment variable}"
: "${MINIO_ACCESS_KEY?Need to set this environment variable}"
: "${MINIO_SECRET_KEY?Need to set this environment variable}"

# FIXME This should be replaced by a more robust healthcheck, see
# https://docs.docker.com/compose/compose-file/compose-file-v3/#healthcheck
# https://docs.docker.com/engine/reference/builder/#healthcheck
echo
echo "***** Sleeping a few seconds to allow Vault to startup"
sleep 5

echo
echo "***** Logging in to Vault"
vault login token="$VAULT_DEV_ROOT_TOKEN_ID"

echo
echo "***** Checking if the /concourse path is already enabled"
if vault secrets list | grep concourse; then
    echo "***** already enabled"
else
    echo "***** to be enabled"
    echo "***** Enabling the /concourse path"
    vault secrets enable -path=/concourse kv
fi

echo
echo "***** Adding secrets"
vault kv put /concourse/main/s3-endpoint   value="$MINIO_ADDR"
vault kv put /concourse/main/s3-region     value="$MINIO_REGION_NAME"
vault kv put /concourse/main/s3-access-key value="$MINIO_ACCESS_KEY"
vault kv put /concourse/main/s3-secret-key value="$MINIO_SECRET_KEY"

# custom secrets...

vault kv put /concourse/main/github private_key="$(cat $CI_GITHUB_PRIVATE_KEY)" private_key_passphrase="$LOCAL_GITHUB_PRIVATE_KEY_PASSPHRASE"
vault kv put /concourse/main/sonarqube token="$CI_SONARQUBE_TOKEN"
vault kv put /concourse/main/nexus npm_token="$CI_NEXUS_NPM_TOKEN"
vault kv put /concourse/main/harbor username="$CI_HARBOR_USERNAME"
vault kv put /concourse/main/harbor token="$CI_HARBOR_TOKEN"
