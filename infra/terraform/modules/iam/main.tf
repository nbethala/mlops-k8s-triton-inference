##############################################
# Operator Role
# WHY: Dedicated role for cluster administration (kubectl, Terraform).
# HOW: Trusts your IAM user (nancy-devops) to assume it.
##############################################

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "eks_operator" {
  name = "EKSOperatorRole"

  # Trust policy: only your IAM user can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${var.account_id}:user/nancy-devops"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    project = var.project
    owner   = var.owner
  }
}

# Attach AWS-managed EKS admin policies
resource "aws_iam_role_policy_attachment" "eks_operator_cluster" {
  role       = aws_iam_role.eks_operator.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_operator_service" {
  role       = aws_iam_role.eks_operator.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# Attach your custom operator policy (fine-grained permissions)
resource "aws_iam_policy" "operator_policy" {
  name   = "ProjectGPU-E2E-Operator"
  policy = file("${path.root}/policies/operator.json")
}

resource "aws_iam_role_policy_attachment" "operator_attach" {
  role       = aws_iam_role.eks_operator.name
  policy_arn = aws_iam_policy.operator_policy.arn
}


# -----------------------------
# ALB Controller Role (IRSA)
# -----------------------------
resource "aws_iam_role" "alb_controller" {
  name = "ALBControllerIRSA"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
         Federated = var.eks_oidc_provider_arn
      }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
             "${var.eks_oidc_provider}:sub"  = var.alb_controller_sub
        }
      }
    }]
  })

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_iam_policy" "alb_controller_policy" {
  name        = "ALBControllerIAMPolicy"
  description = "Permissions for AWS Load Balancer Controller"
  policy      = file("${path.root}/policies/alb-controller.json")
}

resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

# -----------------------------
# EKS Controller Role (ARN)
# -----------------------------
resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.cluster_name}-eks-cluster-role"
  assume_role_policy = file("${path.root}/policies/eks.json")

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# -----------------------------
# EKS GPU node group (ARN)
# -----------------------------
resource "aws_iam_role" "eks_node_role" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = file("${path.root}/policies/node-trust-policy.json")

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

##############################################
# ECR Access Role for GitHub Actions (OIDC)
# WHY: CI/CD pipeline pushes images to ECR.
# HOW: Trusts GitHub OIDC provider.
##############################################

resource "aws_iam_role" "github_actions_ecr" {
  name = "GitHubActionsECRRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${var.account_id}:oidc-provider/token.actions.githubusercontent.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
        }
      }
    }]
  })

  tags = {
    project = var.project
    owner   = var.owner
  }
}

# Attach AWS-managed ECR push policy
resource "aws_iam_role_policy_attachment" "github_actions_ecr_attach" {
  role       = aws_iam_role.github_actions_ecr.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

##############################################
# Node Group Role ECR Pull
# WHY: Worker nodes need to pull images from ECR.
##############################################
# Trust policy for GPU nodegroup role
data "aws_iam_policy_document" "eks_gpu_nodegroup" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_gpu_nodegroup" {
  name               = "eks-gpu-nodegroup-role"
 assume_role_policy = data.aws_iam_policy_document.eks_gpu_nodegroup.json
}

resource "aws_iam_role_policy_attachment" "gpu_nodegroup_ecr_pull" {
  role       = aws_iam_role.eks_gpu_nodegroup.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

##############################################
# Cluster Autoscaler Role (IRSA)
# WHY: Allows Kubernetes Cluster Autoscaler to scale node groups.
##############################################

resource "aws_iam_role" "cluster_autoscaler" {
  name = "ClusterAutoscalerIRSA"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${var.eks_oidc_provider}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.eks_oidc_provider}:sub" = var.eks_oidc_provider_sub
        }
      }
    }]
  })

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name   = "ProjectGPU-ClusterAutoscaler"
  policy = file("${path.root}/policies/cluster-autoscaler.json")
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_attach" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
}

##############################################
# ExternalDNS Role (IRSA)
# WHY: Allows Kubernetes ExternalDNS to manage Route53 records.
##############################################

resource "aws_iam_role" "external_dns" {
  name = "ExternalDNSIRSA"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${var.eks_oidc_provider}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.eks_oidc_provider}:sub" = "system:serviceaccount:kube-system:external-dns"
        }
      }
    }]
  })

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_iam_policy" "external_dns_policy" {
  name   = "ProjectGPU-ExternalDNS"
  policy = file("${path.root}/policies/external-dns.json")
}

resource "aws_iam_role_policy_attachment" "external_dns_attach" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns_policy.arn
}

##############################################
# S3 Access Role (IRSA)
# WHY: Allows Kubernetes pods to access S3 buckets.
##############################################

resource "aws_iam_role" "s3_access" {
  name = "S3AccessIRSA"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${var.eks_oidc_provider}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.eks_oidc_provider}:sub" = "system:serviceaccount:default:s3-access"
        }
      }
    }]
  })

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name   = "ProjectGPU-S3Access"
  policy = file("${path.root}/policies/s3-access.json")
}

resource "aws_iam_role_policy_attachment" "s3_access_attach" {
  role       = aws_iam_role.s3_access.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

#############################################################
# GitHub Actions OIDC role to allow EKS operations
# calls policy: policies/eks-ci-cd.json
############################################################
resource "aws_iam_role" "github_actions_role" {
  name = "triton-mlops-github-actions-oidc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::478253497479:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
           StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
            StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:nbethala/triton-mlops-gpu-platform:*"
          }
        }
      }
    ]
  })
}
resource "aws_iam_policy" "eks_ci_cd_policy" {
  name        = "triton-mlops-github-eks-ci-cd-policy"
  description = "Permissions for GitHub Actions to manage EKS"
  policy      =  file("${path.root}/policies/eks-ci-cd.json")
}

resource "aws_iam_role_policy_attachment" "eks_ci_cd_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.eks_ci_cd_policy.arn
}
resource "aws_iam_role_policy_attachment" "github_actions_role_ecr" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}


# ##########################################################################
#  IAM Role for EKS Nodegroup (Worker Nodes)
# Provides permissions for EC2 instances to join the cluster,
# pull images from ECR, and use the CNI plugin.
############################################################################
# IAM role for EKS nodegroup
resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${var.project}-${var.owner}-eks-nodegroup-role"

  assume_role_policy = data.aws_iam_policy_document.eks_node_assume.json
}

data "aws_iam_policy_document" "eks_node_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Attach required policies for worker nodes
resource "aws_iam_role_policy_attachment" "eks_nodegroup_worker" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_cni" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_ecr" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
