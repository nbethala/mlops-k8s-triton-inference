output "aws_auth_configmap_name" {
  description = "Name of the aws-auth ConfigMap"
  value       = kubernetes_config_map.aws_auth.metadata[0].name
}

output "aws_auth_namespace" {
  description = "Namespace where aws-auth ConfigMap is applied"
  value       = kubernetes_config_map.aws_auth.metadata[0].namespace
}
