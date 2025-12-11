# -------------------------
# GitHub Actions OIDC (CI/CD)
# -------------------------
github_org        = "my-org"
github_repo       = "nbethala/triton-mlops-gpu-platform"
github_branch     = "main"
oidc_provider_url = "token.actions.githubusercontent.com"
project           = "triton-mlops"
oidc_provider_arn = "arn:aws:iam::478253497479:oidc-provider/token.actions.githubusercontent.com"


# -------------------------
# EKS OIDC (IRSA for pods)
# -------------------------
eks_oidc_provider_arn = "arn:aws:iam::478253497479:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/0EF15E7DCFEC9A40A61BB505FBF0BD65"
eks_oidc_provider_sub = "system:serviceaccount:default:triton-sa"
eks_oidc_provider     = "oidc.eks.us-east-1.amazonaws.com/id/0EF15E7DCFEC9A40A61BB505FBF0BD65"


# -------------------------
# AWS Account & Region
# -------------------------
account_id = "478253497479"
region     = "us-east-1"

# -----------------------------
# ALB Controller Role (IRSA)
# -----------------------------
alb_controller_sub = "system:serviceaccount:kube-system:aws-load-balancer-controller"

# -------------------------
# Resources
# -------------------------
model_bucket_name    = "triton-models"
s3_model_bucket_arns = ["arn:aws:s3:::triton-models"]

ecr_repo_arns    = ["arn:aws:ecr:us-east-1:478253497479:repository/triton-infer"]
cluster_name     = "triton-gpu-cluster"
eks_cluster_arns = ["arn:aws:eks:us-east-1:478253497479:cluster/mlops-gpu-eks"]

node_role_arns = []

nodegroup_role_arn = "arn:aws:iam::478253497479:role/triton-gpu-cluster-node-role"


# -------------------------
# Tags
# -------------------------
common_tags = {
  owner   = "nancy"
  project = "triton-mlops"
  env     = "dev"
}

eks_cluster_name = "triton-gpu-cluster"
namespace        = "monitoring"
