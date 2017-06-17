echo_color $COLOR_BOLD Create app roles...

vault_request POST sys/auth/approle "$root_token" '{"type":"approle"}' && echo AppRole authentication enabled

vault_request POST auth/approle/role/app "$root_token" '{"policies":"app"}' && echo Application role created
vault_request POST auth/approle/role/db "$root_token" '{"policies":"db"}' && echo Database role created

app_role_id=$(vault_request GET auth/approle/role/app/role-id "$root_token" '' -Ss|jq -r .data.role_id)
db_role_id=$(vault_request GET auth/approle/role/db/role-id "$root_token" '' -Ss|jq -r .data.role_id)
