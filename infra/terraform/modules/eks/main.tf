# =================================================
# Data sources: query live EKS cluster info
# =================================================
# data "aws_eks_cluster" "main" {
#  name = aws_eks_cluster.gpu_e2e.name
#}

# data "aws_eks_cluster_auth" "main" {
#  name = aws_eks_cluster.gpu_e2e.name
#}

# =================================================
# Helm provider configured against the EKS cluster
# =================================================
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
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

# =================================================
# Kubernetes provider configured against the EKS cluster
# =================================================

#provider "kubernetes" {
#  host                   = data.aws_eks_cluster.main.endpoint
#  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
#  token                  = data.aws_eks_cluster_auth.main.token
#}

# =================================================
# aws-auth ConfigMap: map IAM roles into Kubernetes RBAC
# =================================================
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = "arn:aws:iam::478253497479:role/triton-mlops-github-actions-oidc-role"
        username = "github-actions"
        groups   = ["system:masters"]
      },
      {
        rolearn  = var.nodegroup_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ])
  }
}
