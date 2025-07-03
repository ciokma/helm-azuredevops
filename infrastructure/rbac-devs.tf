# resource "kubernetes_cluster_role" "dev" {
#   metadata {
#     name = "aks-dev"
#   }

#   rule {
#     api_groups = ["*"]
#     resources  = ["*"]
#     verbs      = ["*"]
#   }
# }

# resource "kubernetes_role_binding" "dev_bindings" {
#   for_each = toset(var.dev_namespaces)

#   metadata {
#     name      = "aks-dev-users-binding"
#     namespace = each.key
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.dev.metadata[0].name
#   }

#   subject {
#     kind      = "Group"
#     name      = var.aks_dev_users_group_id
#     api_group = "rbac.authorization.k8s.io"
#   }
# }
