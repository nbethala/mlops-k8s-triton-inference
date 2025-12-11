##############################################
# VPC Module
# WHY: Provides networking foundation (subnets, NAT, routing).
# HOW: Outputs subnet IDs used by EKS and node groups.
##############################################
module "vpc" {
  source  = "./modules/vpc"
  region  = var.region
  project = var.project
  owner   = var.owner
  cluster_name = var.cluster_name
}

##############################################
# IAM Module
# WHY: Central place to define IAM roles (Operator, Node, IRSA, CI/CD).
# HOW: Outputs ARNs consumed by EKS and node groups.
##############################################
module "iam" {
  source       = "./modules/iam"
  project      = var.project
  owner        = var.owner
  cluster_name = var.cluster_name

  # WHY: Needed for trust policies and OIDC wiring.
  account_id        = var.account_id
  github_org        = var.github_org
  github_repo       = var.github_repo
  oidc_provider_arn = var.oidc_provider_arn # HOW: For CI/CD role trust
  #eks_oidc_provider_arn = module.eks.oidc_provider_arn # HOW: For IRSA trust
  eks_oidc_provider_sub = module.eks.oidc_provider_sub # HOW: For IRSA subject matching
  alb_controller_sub    = var.alb_controller_sub       # HOW: ALB Controller Role (IRSA)


  #eks_oidc_provider = replace(module.eks.oidc_provider_arn, "https://", "")

  eks_oidc_provider_arn = var.eks_oidc_provider_arn
  eks_oidc_provider     = var.eks_oidc_provider
}

##############################################
# EKS Cluster Module
# WHY: Creates the control plane (API server, etcd).
# HOW: Needs VPC subnets + cluster IAM role.
##############################################
module "eks" {
  source       = "./modules/eks"
  project      = var.project
  owner        = var.owner
  region       = var.region
  cluster_name = var.cluster_name

  private_subnet_ids = module.vpc.private_subnet_ids # HOW: Cluster control plane runs in private subnets
  cluster_role_arn   = module.iam.cluster_role_arn   # HOW: IAM role for EKS control plane

  # Pass the nodegroup role ARN from IAM module
  nodegroup_role_arn = module.iam.eks_nodegroup_role_arn

    providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }
}

##############################################
# GPU Node Group Module
# WHY: Provides GPU worker nodes (ON_DEMAND + SPOT).
# HOW: Needs node IAM role + subnets.
##############################################
module "gpu_node_group" {
  source            = "./modules/gpu_node_group"
  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_ca        = module.eks.cluster_ca_certificate
  node_sg_id        = module.eks.cluster_security_group_id
  node_role_arn     = module.iam.eks_node_role_arn # HOW: IAM role for EC2 nodes
  public_subnet_ids = module.vpc.public_subnet_ids # HOW: Nodes in public subnets for GPU workloads
  #private_subnet_ids = module.vpc.private_subnet_ids
  project           = var.project
  owner             = var.owner

  ssh_key_name          = "ml-pemfile"
  node_instance_profile = "gpu-node-IAM-role"
}

##############################################
# NVIDIA Plugin Module
# WHY: Installs device plugin so Kubernetes can schedule GPU workloads.
# HOW: Uses Helm provider to deploy DaemonSet.
##############################################
module "nvidia_plugin" {
  source = "./modules/nvidia_plugin"

  providers = {
    helm = helm.eks
  }

  depends_on = [
    module.eks,
    module.gpu_node_group
  ]
}

################################################
# Github Actions 
# use for CI
#################################################
data "aws_caller_identity" "current" {}

module "github_actions_oidc" {
  source = "./modules/github_actions_oidc"

  project           = "triton-mlops"
  github_repo       = var.github_repo #"nbethala/triton-mlops-gpu-platform"
  github_branch     = "main"
  oidc_provider_url = "token.actions.githubusercontent.com"

  ecr_repo_arns = [
    "arn:aws:ecr:us-east-1:${data.aws_caller_identity.current.account_id}:repository/triton-infer"
  ]

  s3_model_bucket_arns = [
    "arn:aws:s3:::${var.model_bucket_name}"
  ]

  eks_cluster_arns = [
    "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
  ]

  node_role_arns = [] # list node role ARNs if you want iam:PassRole to be scoped
  common_tags = {
    project = var.project
    owner   = var.owner
  }
}

#=======================================================
# Triton image ECR
#======================================================
module "ecr" {
  source  = "./modules/ecr"
  project = var.project
  owner   = var.owner
}


# ======================================================
# EKS cluster data sources
# ======================================================
data "aws_eks_cluster" "main" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "main" {
  name = module.eks.cluster_name
}


# ======================================================
# Prometheus + Grafana provisioning
# ======================================================
  module "monitoring" {
  source       = "./modules/monitoring"
  eks_cluster_name = module.eks.cluster_name
  namespace    = "monitoring"

  prometheus_chart_version = "61.2.0"  # or override here
  grafana_chart_version    = "6.57.4"  # or override here

   
  providers = {
    kubernetes = kubernetes.eks # from provider.tf
    helm       = helm.eks       # from provider.tf
  }
    depends_on = [
    module.eks,
    module.gpu_node_group,        # ensures GPU nodes exist
    module.nvidia_plugin          # GPU device plugin
  ]
}

# ======================================================
# AWS Auth for RBAC 
# =======================================================
module "aws_auth" {
  source = "./modules/aws_auth"

  providers = {
    kubernetes = kubernetes.eks
  }

  github_actions_role_arn = "arn:aws:iam::478253497479:role/triton-mlops-github-actions-oidc-role"
  nodegroup_role_arn      = var.nodegroup_role_arn
}
