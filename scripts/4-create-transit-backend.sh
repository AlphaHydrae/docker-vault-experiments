echo_color $COLOR_BOLD Creating transit backend with encryption keys...

vault_request POST sys/mounts/transit "$root_token" '{"type":"transit","description":"Transit"}' && echo Transit secret backend created
vault_request POST transit/keys/demo-app "$root_token" '{}' && echo Application transit key created
vault_request POST transit/keys/demo-db "$root_token" '{}' && echo Database transit key created
