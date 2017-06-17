echo_color $COLOR_BOLD Generating and storing credentials in a generic backend...

vault_request POST sys/mounts/demo "$root_token" '{"type":"generic","description":"Demo"}' && echo Demo secret backend created

postgres_password=$(uuidgen)
app_db_password=$(uuidgen)

vault_request POST demo/postgres/password "$root_token" "{\"value\":\"$postgres_password\"}" && echo Postgres password stored
vault_request POST demo/app/db/password "$root_token" "{\"value\":\"$app_db_password\"}" && echo Application database password stored
