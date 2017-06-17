echo_color $COLOR_BOLD Run database...
db_wrap_token=$(vault_request POST auth/approle/role/db/secret-id "$root_token" '' -H 'X-Vault-Wrap-TTL:10'|jq -r .wrap_info.token)
echo Database secret ID created

AUTH_ROLE=$db_role_id AUTH_TOKEN=$db_wrap_token docker-compose up --build -d db
