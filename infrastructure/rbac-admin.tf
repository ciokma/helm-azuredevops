resource "kubernetes_cluster_role" "admin" {
  metadata {
    name = "aks-admin"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "admin_binding" {
  metadata {
    name = "aks-admin-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.admin.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = var.aks_admins_group_id
    api_group = "rbac.authorization.k8s.io"
  }
}
