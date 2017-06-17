echo_color $COLOR_BOLD Creating, initializing and unsealing vault...

docker-compose up --build -d vault

while true; do
  set +e
  curl http://localhost:8200/v1/sys/seal-status &>/dev/null
  [[ $? -eq 0 ]] && break
  set -e
  echo Waiting for vault container to start...
  sleep 1
done

mkdir -p /var/lib/demo
vault_run init -key-shares=1 -key-threshold=1 > /var/lib/demo/init.txt

unseal_key=$(cat /var/lib/demo/init.txt|grep 'Unseal Key'|head -n 1|sed 's/.*Unseal Key.*: //'|sed 's/[^A-Za-z0-9\=\+\-\/]*//g')
root_token=$(cat /var/lib/demo/init.txt|grep 'Root Token'|head -n 1|sed 's/.*Root Token.*: //'|sed 's/[^A-Za-z0-9\-]*//g')

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
