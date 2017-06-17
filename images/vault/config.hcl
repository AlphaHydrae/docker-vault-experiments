storage "file" {
  path = "/vault/data/file"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 1
}
