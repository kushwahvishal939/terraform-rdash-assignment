resource "kubernetes_namespace" "rbac_a" {
  metadata {
    name = var.namespace_a
  }
}

resource "kubernetes_namespace" "rbac_b" {
  metadata {
    name = var.namespace_b
  }
}

resource "kubernetes_service_account" "rbac_test_sa" {
  metadata {
    name      = var.service_account_name
    namespace = "default" # SA is created in default, but can be used across namespaces
    annotations = {
      "eks.amazonaws.com/role-arn" = var.iam_role_arn
    }
  }
}

resource "kubernetes_cluster_role" "namespace_lister" {
  metadata {
    name = "namespace-lister"
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "sa_namespace_lister" {
  metadata {
    name = "rbac-test-sa-namespace-lister"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.rbac_test_sa.metadata[0].name
    namespace = kubernetes_service_account.rbac_test_sa.metadata[0].namespace
  }
  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.namespace_lister.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_role" "read_only_a" {
  metadata {
    name      = "read-only-access"
    namespace = kubernetes_namespace.rbac_a.metadata[0].name
  }
  rule {
    api_groups = ["", "apps", "batch", "extensions"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "sa_read_only_a" {
  metadata {
    name      = "rbac-test-sa-read-only"
    namespace = kubernetes_namespace.rbac_a.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.rbac_test_sa.metadata[0].name
    namespace = kubernetes_service_account.rbac_test_sa.metadata[0].namespace
  }
  role_ref {
    kind      = "Role"
    name      = kubernetes_role.read_only_a.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_role_binding" "sa_full_access_b" {
  metadata {
    name      = "rbac-test-sa-full-access"
    namespace = kubernetes_namespace.rbac_b.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.rbac_test_sa.metadata[0].name
    namespace = kubernetes_service_account.rbac_test_sa.metadata[0].namespace
  }
  role_ref {
    kind      = "ClusterRole"
    name      = "admin" # Built-in cluster role
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_pod" "test_pod" {
  metadata {
    name      = "rbac-test-pod"
    namespace = "default"
  }

  spec {
    service_account_name = kubernetes_service_account.rbac_test_sa.metadata[0].name

    container {
      name  = "test-container"
      image = "${var.ecr_repo_url}:${var.app_image_tag}"
      # Keep the container running
      command = ["/bin/sh", "-c", "sleep 3600"]
    }

    restart_policy = "OnFailure"
  }
  depends_on = [
    kubernetes_cluster_role_binding.sa_namespace_lister
    # var.node_group_arn is not a resource, but passing it here ensures the module waits
  ]
}