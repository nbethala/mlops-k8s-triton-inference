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
# 1. Namespace: monitoring
# -----------------------------------------------------
resource "kubernetes_namespace" "monitoring_ns" {
  metadata {
    name = var.namespace
  }
}

# -----------------------------------------------------
# 2. Install Prometheus via Helm (including CRDs)
# -----------------------------------------------------
resource "helm_release" "prometheus" {
  #depends_on = [kubernetes_namespace.monitoring_ns]

  name       = "kube-prometheus-stack"
  #namespace  = kubernetes_namespace.monitoring_ns.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "61.2.0"
   
  namespace  = var.namespace

  create_namespace = false
  wait             = true
  timeout          = 600

  values = [
    local.prometheus_values
  ]
}

# -----------------------------------------------------
# 3. Grafana Helm Chart
# -----------------------------------------------------
resource "helm_release" "grafana" {
  name       = "grafana"
  #namespace  = kubernetes_namespace.monitoring_ns.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.57.4"
   
  namespace  = var.namespace

  values = [
    local.grafana_values
  ]

  depends_on = [helm_release.prometheus]
}

# -----------------------------------------------------
# 4. Create Alertmanager Slack secret from CICD pipeline
# -----------------------------------------------------
resource "kubernetes_secret" "alertmanager" {
provider = kubernetes
  metadata {
    name      = "alertmanager-slack"
    #namespace = kubernetes_namespace.monitoring_ns.metadata[0].name
    namespace = var.namespace
  }

  data = {
    "alertmanager.yaml" = base64encode(var.alertmanager_config)
  }

  type = "Opaque"

  depends_on = [helm_release.prometheus]
}

# -----------------------------------------------------
# 5. Load dashboards into Grafana via ConfigMaps
# -----------------------------------------------------
resource "kubernetes_config_map" "grafana_dashboards" {
provider = kubernetes
  for_each = local.dashboard_paths

  metadata {
    name      = trimsuffix(each.key, ".json")
    #namespace = kubernetes_namespace.monitoring_ns.metadata[0].name
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
  name       = "dcgm-exporter"
  #namespace  = kubernetes_namespace.monitoring_ns.metadata[0].name
  repository = "https://nvidia.github.io/dcgm-exporter/helm-charts/"
  chart      = "dcgm-exporter"
  version    = "4.6.0"

  set = [
    {
      name  = "serviceMonitor.enabled"
      value = "true"
    }
  ]

  depends_on = [
    helm_release.prometheus,
    helm_release.grafana
  ]
}
