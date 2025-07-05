# resource "kubernetes_cluster_role" "readonly" {
#   metadata {
#     name = "aks-readonly"
#   }

#   rule {
#     api_groups = ["", "apps", "batch", "extensions"]
#     resources  = ["*"]
#     verbs      = ["get", "list", "watch"]
#   }
# }
# resource "kubernetes_role_binding" "readonly_bindings" {
#   for_each = toset(var.readonly_namespaces)

#   metadata {
#     name      = "aks-readonly-users-binding"
#     namespace = each.key
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.readonly.metadata[0].name
#   }

#   subject {
#     kind      = "Group"
#     name      = var.aks_readonly_users_group_id
#     api_group = "rbac.authorization.k8s.io"
#   }
# }
