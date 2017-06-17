echo_color $COLOR_BOLD Load policies...

for role in app db; do
  vault_load_policy $role policies/$role.hcl && echo $role policy loaded
  vault_load_policy $role-transit policies/$role.transit.hcl && echo $role transit policy loaded
done
