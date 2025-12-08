output "grafana_release" {
  description = "Grafana helm release name"
  value       = helm_release.grafana.name
}

output "prometheus_release" {
  description = "Prometheus helm release name (kube-prometheus-stack)"
  value       = helm_release.prometheus.name
}

#output "monitoring_namespace" {
#  description = "Namespace where monitoring is installed"
#  value       = kubernetes_namespace.monitoring_ns.metadata[0].name
#}

output "monitoring_namespace" {
  value = var.namespace
}

