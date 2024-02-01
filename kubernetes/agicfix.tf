resource "kubernetes_cluster_role" "fixrole" {
  metadata {
    name = "fix-agic-role"
  }
  rule {
    api_groups = ["appgw.ingress.azure.io"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "fixrolebinding" {
  metadata {
    name = "fix-agic-role-binding"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "ingress-appgw-sa"
    namespace = "kube-system"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "fix-agic-role"
  }
  depends_on = [kubernetes_cluster_role.fixrole]
}

data "http" "appgw" {
  url = "https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/helm/ingress-azure/crds/azureapplicationgatewayrewrite.yaml"
}

resource "kubernetes_manifest" "crds" {
  for_each = {
    for value in [
      for yaml in split(
        "\n---\n",
        "\n${replace(data.http.appgw.response_body, "/(?m)^---[[:blank:]]*(#.*)?$/", "---")}\n"
      ) :
      yamldecode(yaml)
      if trimspace(replace(yaml, "/(?m)(^[[:blank:]]*(#.*)?$)+/", "")) != ""
    ] : "${value["kind"]}--${value["metadata"]["name"]}" => value
  }
  manifest   = each.value
  depends_on = [kubernetes_cluster_role_binding.fixrolebinding]
}