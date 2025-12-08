variable "region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "IAM role ARN for EKS control plane"
  type        = string
}

variable "project" {
  type = string
}

variable "owner" {
  type = string
}

variable "nodegroup_role_arn" {
  type        = string
  description = "IAM role ARN for EKS nodegroup"
}
