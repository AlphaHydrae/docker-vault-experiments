echo_color $COLOR_BOLD Cleaning up previous demo...

mkdir -p /var/lib
rm -rf /var/lib/demo

set +e
docker inspect db &>/dev/null && docker rm -f db
docker inspect vault &>/dev/null && docker rm -f vault
docker volume inspect vagrant_db_data &>/dev/null && docker volume rm vagrant_db_data
docker volume inspect vagrant_vault_data &>/dev/null && docker volume rm vagrant_vault_data
set -e

echo_color $COLOR_GREEN "done"
