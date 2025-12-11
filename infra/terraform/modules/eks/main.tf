terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.0"
    }
  }
}

# =================================================
# Data sources: query live EKS cluster info
# =================================================
 data "aws_eks_cluster" "main" {
  name = aws_eks_cluster.gpu_e2e.name
}

 data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.gpu_e2e.name
}

# =================================================
# Create EKS cluster
# =================================================
resource "aws_eks_cluster" "gpu_e2e" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }

  tags = {
    project = var.project
    owner   = var.owner
    Name    = var.cluster_name
  }
}
