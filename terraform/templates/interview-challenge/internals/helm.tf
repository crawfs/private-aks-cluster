locals {
    fluent_bit_config_values = templatefile("./helm/fluentbitconfigmap/values.yaml", {POSTGRES_USER = "${data.terraform_remote_state.azure.postgresql.administrator_login}", POSTGRES_PASSWORD = ${"${data.terraform_remote_state.azure.postgresql.administrator_login_password}"} })
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  chart      = "https://kubernetes.github.io/ingress-nginx"

  values = [
    "${file(./helm/nginx-ingress/values.yaml)}"
  ]
}

resource "helm_release" "ingress_config" {
  name       = "ingress-config"
  chart      = "./helm/ingress-config"
  version    = "1.0"

  values = [
    "${file(./helm/ingress-config/values.yaml)}"
  ]
  depends_on = [
    helm_release.nginx_ingress
  ]
}

resource "helm_release" "hello_world" {
  name       = "hello-world"
  chart      = "./helm/hello-world"
  version    = "1.0"

  values = [
    "${file(./helm/hello-world/values.yaml)}"
  ]
  depends_on = [
    helm_release.ingress_config
  ]
}

resource "helm_release" "fluent_bit_config" {
  name       = "fluent-bit-config"
  chart      = "./helm/fluentbitconfigmap"
  version    = "1.0"

  values = [
    local.fluent_bit_config_values,
    
  ]

    depends_on = [
    helm_release.hello_world,
    azurerm_postgresql_database.postgresql,

  ]
}

resource "helm_release" "fluent_bit_daemon" {
  name       = "fluent-bit-daemon"
  chart      = "./helm/fluentbitdaemon"
  version    = "1.0"

  values = [
    "${file(./helm/fluentbitdaemon/values.yaml)}"
  ]
  depends_on = [
    helm_release.fluent_bit_config,

  ]
}





