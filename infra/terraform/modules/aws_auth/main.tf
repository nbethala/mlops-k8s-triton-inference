terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

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
