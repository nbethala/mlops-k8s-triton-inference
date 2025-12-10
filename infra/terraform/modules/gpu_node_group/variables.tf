

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

variable "cluster_endpoint" { 
   type = string 
}

variable "cluster_ca" { 
   type = string 
}

variable "node_sg_id" {
  type = string
}

variable "ssh_key_name" {
  description = "EC2 Key Pair name for SSH access to GPU nodes"
  type        = string
}

variable "node_instance_profile" {
  description = "IAM instance profile name attached to GPU nodes"
  type        = string
}

