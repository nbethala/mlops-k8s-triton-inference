variable "github_repo" {
  description = "GitHub repository name (e.g. nbethala/triton-mlops-gpu-platform)"
  type        = string
}

variable "github_branch" {
  description = "Branch name to allow OIDC trust (e.g. main)"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL for GitHub Actions"
  type        = string
}

variable "project" {
  description = "Project identifier used in IAM role/policy names"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to resources"
  type        = map(string)
  default     = {}
}

variable "ecr_repo_arns" {
  description = "List of ECR repository ARNs allowed"
  type        = list(string)
  default     = []
}

variable "s3_model_bucket_arns" {
  description = "List of S3 bucket ARNs for model/state access"
  type        = list(string)
  default     = []
}

variable "eks_cluster_arns" {
  description = "List of EKS cluster ARNs for Terraform management"
  type        = list(string)
  default     = []
}

variable "node_role_arns" {
  description = "List of IAM role ARNs for nodegroups"
  type        = list(string)
  default     = []
}
