#!/bin/bash
set -e

export VAULT_API_URL=http://vault:8200/v1

AUTH_SECRET=$(curl --fail -sS \
  -X POST \
  -H "X-Vault-Token:$AUTH_TOKEN" \
  $VAULT_API_URL/sys/wrapping/unwrap|jq -r .data.secret_id)

export AUTH_TOKEN=$(curl --fail -sS \
  -X POST \
  -d "{\"role_id\":\"${AUTH_ROLE}\",\"secret_id\":\"${AUTH_SECRET}\"}" \
  $VAULT_API_URL/auth/approle/login|jq -r .auth.client_token)

export POSTGRES_PASSWORD=$(curl --fail -sS \
  -H "X-Vault-Token:$AUTH_TOKEN" \
  $VAULT_API_URL/demo/postgres/password|jq -r .data.value)

set +e
. /usr/local/bin/docker-entrypoint.sh
