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


  curl_command="curl --fail -X $method -H X-Vault-Token:$token"

  if test -n "$body"; then
    tmp_file=$(mktemp /tmp/demo.XXXXXXX)
    TMP_FILES="$TMP_FILES $tmp_file"
    echo "$body" > $tmp_file
    curl_command="$curl_command -d @$tmp_file"
    shift 4
  else
    shift 3
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

for script in $(ls -1 scripts); do
  echo
  source scripts/$script
done

echo
