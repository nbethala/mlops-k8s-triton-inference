variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project tag"
  type        = string
  default     = "gpu-e2e"
}

variable "owner" {
  description = "Owner tag"
  type        = string
  default     = "Nancy"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "gpu-e2e-cluster"
}

variable "account_id" {
  description = "account ID tag for resources"
  type        = string
}

variable "github_org" {
  description = "github_org tag for resources"
  type        = string
}

variable "github_branch" {
  type        = string
  description = "GitHub branch used for CI/CD workflows"
}

variable "github_repo" {
  description = "github_repo tag for resources"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider for federation"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "eks_oidc_provider_arn tag for resources"
  type        = string
}

variable "eks_oidc_provider_sub" {
  description = "eks_oidc_provider_sub tag for resources"
  type        = string
}

variable "model_bucket_name" {
  description = "Name of the S3 bucket for models"
  type        = string
}


variable "ecr_repo_arns" {
  type        = list(string)
  description = "List of ECR repository ARNs used by GitHub Actions"
}

variable "oidc_provider_url" {
  type        = string
  description = "OIDC provider URL for GitHub Actions federation"
}

variable "node_role_arns" {
  type        = list(string)
  description = "List of IAM role ARNs for EKS worker nodes"
}

variable "s3_model_bucket_arns" {
  type        = list(string)
  description = "List of S3 bucket ARNs for model storage"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  default = {
    owner   = "nancy"
    project = "triton-mlops"
    env     = "dev"
  }
}

variable "eks_cluster_arns" {
  type        = list(string)
  description = "List of EKS cluster ARNs"
}

variable "prometheus_chart_version" {
  description = "Version of the Prometheus Helm chart"
  type        = string
  default     = "58.3.0" # or whatever stable version you want
}

variable "grafana_chart_version" {
  description = "Version of the Grafana Helm chart"
  type        = string
  default     = "7.3.0" # example stable version
}

variable "alb_controller_sub" {
  description = "OIDC sub for ALB controller service account"
  type        = string
}

variable "eks_oidc_provider" {
  description = "Issuer string (without https://) for IRSA condition keys"
  type        = string
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "namespace" {
  type        = string
  description = "Namespace for monitoring resources"
  default     = "monitoring"
}

variable "nodegroup_role_arn" {
   type       = string

} 
