variable "owner" {
  description = "Owner tag for resources"
  type        = string
}

variable "project" {
  description = "Project tag for resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster for tagging subnets"
  type        = string
}
