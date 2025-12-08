locals {
  prometheus_values = file("${path.module}/values/prometheus-values.yaml")
  grafana_values    = file("${path.module}/values/grafana-values.yaml")

  # Define Grafana dashboards you want to load
  # Key = filename, Value = path to JSON file
  dashboard_paths = {
    "node-dashboard.json" = "${path.module}/dashboards/node-dashboard.json"
    "gpu-dashboard.json"  = "${path.module}/dashboards/gpu-dashboard.json"
  }
}
