terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.0"
    }
  }
}

# -----------------------------------------------------
# 0. Remove internal provider blocks
# -----------------------------------------------------
# Providers will be passed from the root module

# -----------------------------------------------------
# 1. Namespace: monitoring
# -----------------------------------------------------
resource "kubernetes_namespace" "monitoring_ns" {
  metadata {
    name = var.namespace
  }
}

# -----------------------------------------------------
# 2. Prometheus Helm Chart
# -----------------------------------------------------
resource "helm_release" "prometheus" {
  provider = helm
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "61.2.0"
  namespace        = var.namespace
  create_namespace = false
  wait             = true
  timeout          = 600

  set = [
    { name = "nodeSelector.accelerator", value = "nvidia" },
    { name = "tolerations[0].key", value = "gpu" },
    { name = "tolerations[0].operator", value = "Exists" },
    { name = "tolerations[0].effect", value = "NoSchedule" },

    # ✅ Use emptyDir instead of PVC
    { name = "prometheus.prometheusSpec.storageSpec.emptyDir.sizeLimit", value = "2Gi" }

  ]

  values = [
    local.prometheus_values
  ]
}

# -----------------------------------------------------
# 3. Grafana Helm Chart
# -----------------------------------------------------
resource "helm_release" "grafana" {
  provider = helm
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.57.4"
  namespace  = var.namespace

  set = [
    { name = "nodeSelector.accelerator", value = "nvidia" },
    { name = "tolerations[0].key", value = "gpu" },
    { name = "tolerations[0].operator", value = "Exists" },
    { name = "tolerations[0].effect", value = "NoSchedule" }
  ]

  values = [
    local.grafana_values
  ]

  depends_on = [helm_release.prometheus]
}

# -----------------------------------------------------
# 4. Alertmanager Slack Secret
# -----------------------------------------------------
resource "kubernetes_secret" "alertmanager" {
  provider = kubernetes
  metadata {
    name      = "alertmanager-slack"
    namespace = var.namespace
  }

  data = {
    "alertmanager.yaml" = base64encode(var.alertmanager_config)
  }

  type       = "Opaque"
  depends_on = [helm_release.prometheus]
}

# -----------------------------------------------------
# 5. Grafana dashboards via ConfigMaps
# -----------------------------------------------------
resource "kubernetes_config_map" "grafana_dashboards" {
  provider = kubernetes
  for_each = local.dashboard_paths

  metadata {
    name      = trimsuffix(each.key, ".json")
    namespace = var.namespace
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    dashboard = file(each.value)
  }

  depends_on = [helm_release.grafana]
}

# -----------------------------------------------------
# 6. NVIDIA DCGM GPU Exporter
# -----------------------------------------------------
resource "helm_release" "nvidia_dcgm" {
  provider   = helm
  name       = "dcgm-exporter"
  repository = "https://nvidia.github.io/dcgm-exporter/helm-charts"
  chart      = "dcgm-exporter"
  version    = "4.6.0"
  namespace  = var.namespace

  set = [
    { name = "serviceMonitor.enabled", value = "true" },
    { name = "nodeSelector.accelerator", value = "nvidia" },
    { name = "tolerations[0].key", value = "gpu" },
    { name = "tolerations[0].operator", value = "Exists" },
    { name = "tolerations[0].effect", value = "NoSchedule" }
  ]

  depends_on = [
    helm_release.prometheus,
    helm_release.grafana
  ]
}
