

variable "project" {
  type = string
}

variable "owner" {
  type = string
}


variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

#variable "private_subnet_ids" { 
#   description = "List of private subnet IDs for EKS"
#  type = list(string)
#}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for EKS"
  type        = list(string)
}

variable "node_role_arn" {
  description = "Iam ARN rule for Node group"
  type        = string

}
