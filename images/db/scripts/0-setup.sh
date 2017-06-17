#!/bin/sh
set -e

DATABASE_PASSWORD=$(curl --fail -sS \
  -H "X-Vault-Token:$AUTH_TOKEN" \
  $VAULT_API_URL/demo/app/db/password|jq -r .data.value)

test -n "$DATABASE_PASSWORD" || { >&2 echo Could not get database password && exit 1; }

echo "Creating the database user ${DATABASE_USERNAME}"
psql -U "$POSTGRES_USER" -c "CREATE USER ${DATABASE_USERNAME} PASSWORD '${DATABASE_PASSWORD}'"

echo "Creating the database ${DATABASE_NAME}"
createdb -U "$POSTGRES_USER" -O $DATABASE_USERNAME $DATABASE_NAME

set +e
