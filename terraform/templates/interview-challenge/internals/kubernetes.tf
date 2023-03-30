locals {
    namespaces = {
        ingress-basic = {}
        logging = {}
    }

}


resource "kubernetes_namespace" "cluster_namespaces" {
  for_each = local.namespaces

  metadata {
    name   = each.key
    labels = each.value
  }
}