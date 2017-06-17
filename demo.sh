#!/bin/bash
set -e

COLOR_BOLD=1
COLOR_GREEN=32

TMP_FILES=

cleanup() {
  if test -n "$TMP_FILES"; then
    rm -f $TMP_FILES
  fi
}

echo_color() {
  local color="$1"
  shift
  local message="$@"
  echo -e "\033[${color}m${message}\033[0m"
}

vault_run() {
  docker run -it --rm --net vagrant_default --entrypoint /bin/vault -e VAULT_ADDR=http://vault:8200 vault:0.7.3 $@
}

vault_request() {
  local method="$1"
  local path="$2"
  local token="$3"
  local body="$4"

  shift 4

  curl_command="curl --fail -X $method -H X-Vault-Token:$token"

  if test -n "$body"; then
    tmp_file=$(mktemp /tmp/demo.XXXXXXX)
    TMP_FILES="$TMP_FILES $tmp_file"
    echo "$body" > $tmp_file
    curl_command="$curl_command -d @$tmp_file"
  fi

  $curl_command $@ http://localhost:8200/v1/$path
}

vault_load_policy() {
  local policy_name="$1"
  local policy_file="$2"
  local policy_json=$(jq -n -c -M --arg policy "$(cat "$policy_file")" '{rules:$policy}')
  vault_request PUT sys/policy/$policy_name "$root_token" "$policy_json"
}

trap cleanup INT TERM HUP EXIT

cd /vagrant

echo
echo_color $COLOR_BOLD Cleaning up previous demo...

rm -f init.txt
docker inspect db &>/dev/null && docker rm -f db
docker inspect vault &>/dev/null && docker rm -f vault
docker volume inspect vagrant_db_data &>/dev/null && docker volume rm vagrant_db_data
docker volume inspect vagrant_vault_data &>/dev/null && docker volume rm vagrant_vault_data
echo_color $COLOR_GREEN "done"

echo
echo_color $COLOR_BOLD Creating containers...

docker-compose up --build -d vault

echo
echo_color $COLOR_BOLD Initializing and unsealing vault...

while true; do
  set +e
  curl http://localhost:8200/v1/sys/seal-status &>/dev/null
  [[ $? -eq 0 ]] && break
  set -e
  echo Waiting for vault container to start...
  sleep 1
done

vault_run init -key-shares=1 -key-threshold=1 > init.txt

unseal_key=$(cat init.txt|grep 'Unseal Key'|head -n 1|sed 's/.*Unseal Key.*: //'|sed 's/[^A-Za-z0-9\=\+\-\/]*//g')
root_token=$(cat init.txt|grep 'Root Token'|head -n 1|sed 's/.*Root Token.*: //'|sed 's/[^A-Za-z0-9\-]*//g')

echo Unseal key: $unseal_key
echo Root token: $root_token

while true; do
  set +e
  vault_run status &>/dev/null
  [[ $? -eq 2 ]] && break
  set -e
  echo Waiting for vault initialization...
  sleep 1
done

vault_run unseal $unseal_key >/dev/null

while true; do
  set +e
  vault_run status &>/dev/null
  [[ $? -eq 0 ]] && break
  set -e
  echo Waiting for vault to be unsealed...
  sleep 1
done

echo_color $COLOR_GREEN "done"

echo
echo_color $COLOR_BOLD Generating and storing credentials in a generic backend...

vault_request POST sys/mounts/demo "$root_token" '{"type":"generic","description":"Demo"}' && echo Demo secret backend created

postgres_password=$(uuidgen)
app_db_password=$(uuidgen)

vault_request POST demo/postgres/password "$root_token" "{\"value\":\"$postgres_password\"}" && echo Postgres password stored
vault_request POST demo/app/db/password "$root_token" "{\"value\":\"$app_db_password\"}" && echo Application database password stored

echo
echo_color $COLOR_BOLD Load policies...

vault_load_policy app config/app.policy.hcl && echo Application policy loaded
vault_load_policy db config/db.policy.hcl && echo Database policy loaded

echo
echo_color $COLOR_BOLD Create app roles...

vault_request POST sys/auth/approle "$root_token" '{"type":"approle"}' && echo AppRole authentication enabled
vault_request POST auth/approle/role/app "$root_token" '{"policies":"app"}' && echo Application role created
vault_request POST auth/approle/role/db "$root_token" '{"policies":"db"}' && echo Database role created

APP_ROLE_ID=$(vault_request GET auth/approle/role/app/role-id "$root_token" '' -Ss|jq -r .data.role_id)
DB_ROLE_ID=$(vault_request GET auth/approle/role/db/role-id "$root_token" '' -Ss|jq -r .data.role_id)
