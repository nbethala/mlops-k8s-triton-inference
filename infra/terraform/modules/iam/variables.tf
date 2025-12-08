variable "owner" {
  description = "Owner tag for resources"
  type        = string
}

variable "project" {
  description = "Project tag for resources"
  type        = string
}

variable "account_id" {
  description = "account ID tag for resources"
  type        = string
}

variable "cluster_name" {
  description = "cluster name tag for resources"
  type        = string
}

variable "github_org" {
  description = "github_org tag for resources"
  type        = string
}

variable "github_repo" {
  description = "github_repo tag for resources"
  type        = string
}

variable "github_branch" {
  type        = string
  description = "Branch allowed to assume role (e.g. main/feat)"
  default     = "main"
}

variable "oidc_provider_url" {
  type        = string
  description = "OIDC provider host (token.actions.githubusercontent.com)"
  default     = "token.actions.githubusercontent.com"
}

variable "oidc_provider_arn" {
  description = "github_oidc tag for resources"
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

variable "ecr_repo_arns" {
  type        = list(string)
  default     = []
  description = "Optional list of ARNs for ECR repos to restrict to; leave empty to allow all"
}

variable "s3_model_bucket_arns" {
  type        = list(string)
  default     = []
  description = "S3 bucket ARNs (e.g. arn:aws:s3:::my-model-bucket) to restrict model sync"
}

variable "eks_cluster_arns" {
  type        = list(string)
  default     = []
  description = "EKS cluster ARNs for restricting cluster operations"
}

variable "node_role_arns" {
  type        = list(string)
  default     = []
  description = "Optional list of Node Role ARNs for iam:PassRole restriction"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "eks_oidc_provider" {
  type        = string
  description = "OIDC provider ID string (issuer URL without https://)"
}

variable "alb_controller_sub" {
  description = "alb_oidc_provider_sub tag for resources"
  type        = string
}
