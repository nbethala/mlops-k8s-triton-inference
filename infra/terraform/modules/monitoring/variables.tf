variable "namespace" {
  description = "Namespace to install monitoring into"
  type        = string
  default     = "monitoring"
}

#variable "cluster_name" {
#  description = "EKS cluster name (for kubeconfig references if needed)"
#  type        = string
#}

variable "prometheus_chart_version" {
  description = "Optional pinned chart version for kube-prometheus-stack"
  type        = string
  default     = "47.7.0" # adjust if you want a different stable version
}

variable "grafana_chart_version" {
  description = "Optional pinned chart version for grafana"
  type        = string
  default     = "9.5.1" # adjust to a compatible chart
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
}

# -----------------------------------------------------
# Input: Dashboard filenames
# -----------------------------------------------------
variable "dashboards" {
  description = "List of dashboard filenames to load into Grafana ConfigMap"
  type        = list(string)
  default = [
    "gpu-triton-dashboard.json",
    "triton-metrics.json",
    "latency-dashboard.json",
    "gpu.json",
  ]
}

variable "slack_webhook_secret_name" {
  description = "Kubernetes secret name to hold Slack webhook (created by CI or manually)"
  type        = string
  default     = "alertmanager-slack"
}

variable "alertmanager_config" {
  description = "Name of the alertmanager secret to create"
  type        = string
  default     = "alertmanager-config"
}

