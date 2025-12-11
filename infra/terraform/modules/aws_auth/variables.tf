variable "github_actions_role_arn" {
  type        = string
  description = "IAM role ARN for GitHub Actions OIDC integration"
}

variable "nodegroup_role_arn" {
  type        = string
  description = "IAM role ARN for the EKS nodegroup"
}

variable "namespace" {
  type        = string
  description = "Namespace where aws-auth ConfigMap is applied"
  default     = "kube-system"
}
