locals {
  #repo_subject      = "repo:${var.github_repo}:ref:refs/heads/${var.github_branch}"
  repo_subject      = "repo:${var.github_repo}:*}"
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider_url}"
}

data "aws_caller_identity" "current" {}

# Render the trust policy from the template
data "template_file" "ci_trust" {
  template = file("${path.root}/policies/ci.json.tpl")
  vars = {
    oidc_provider_arn = local.oidc_provider_arn
    repo_subject      = local.repo_subject
  }
}

resource "aws_iam_role" "github_actions_oidc" {
  name               = "${var.project}-github-actions-oidc-role"
  assume_role_policy = data.template_file.ci_trust.rendered

  tags = merge({
    "created_by" = "terraform"
    "project"    = var.project
  }, var.common_tags)
}

# Policy: ECR (push/pull) limited to a specific repository ARN (or *
resource "aws_iam_policy" "ecr_policy" {
  name        = "${var.project}-github-ecr-policy"
  description = "Allow pushing/pulling images to ECR repo(s) used by GitHub Actions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ECRPullPush"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:CreateRepository",
          "ecr:DescribeRepositories"
        ]
        Resource = var.ecr_repo_arns == [] ? ["*"] : var.ecr_repo_arns
      },
      {
        Sid    = "ECRList"
        Effect = "Allow"
        Action = [
          "ecr:DescribeImages",
          "ecr:ListImages"
        ]
        Resource = var.ecr_repo_arns == [] ? ["*"] : var.ecr_repo_arns
      }
    ]
  })
}

# Policy: S3 model & state access (sync models + optional backend)
resource "aws_iam_policy" "s3_policy" {
  name        = "${var.project}-github-s3-policy"
  description = "Allow GitHub Actions to sync model files and read/write Terraform state"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "S3ModelAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:PutObjectAcl",
          "s3:GetObjectAcl"
        ]
        Resource = concat(
          var.s3_model_bucket_arns,
          [for arn in var.s3_model_bucket_arns : "${arn}/*"]
        )
      }
    ]
  })
}

# Policy: Minimal EKS/EC2 permissions to manage cluster/nodegroups for Terraform
resource "aws_iam_policy" "eks_terraform_policy" {
  name        = "${var.project}-github-eks-terraform-policy"
  description = "Permissions to allow Terraform (via GitHub Actions) to describe and manage EKS & nodegroups"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "EksDescribe"
        Effect = "Allow"
        Action = [
          "eks:CreateCluster",
          "eks:DeleteCluster",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:CreateNodegroup",
          "eks:DeleteNodegroup",
          "eks:UpdateNodegroupConfig",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups"
        ]
        Resource = var.eks_cluster_arns == [] ? ["*"] : var.eks_cluster_arns
      },
      {
        Sid    = "EC2ForNodes"
        Effect = "Allow"
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:DescribeInstances",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeKeyPairs"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMPermissions"
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "iam:GetRole",
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
      }
    ]
  })
}

# Policy: CloudWatch + ALB basic permissions
resource "aws_iam_policy" "misc_policy" {
  name        = "${var.project}-github-misc-policy"
  description = "CloudWatch, ELB, and supporting actions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "CloudWatch"
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      },
      {
        Sid    = "ELB"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach all policies to the role
resource "aws_iam_role_policy_attachment" "attach_ecr" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}
resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = aws_iam_policy.s3_policy.arn
}
resource "aws_iam_role_policy_attachment" "attach_eks_tf" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = aws_iam_policy.eks_terraform_policy.arn
}
resource "aws_iam_role_policy_attachment" "attach_misc" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = aws_iam_policy.misc_policy.arn
}

# Optionally attach AmazonEC2ContainerRegistryPowerUser managed policy if you prefer AWS-managed
#resource "aws_iam_role_policy_attachment" "attach_ecr_managed" {
#  role       = aws_iam_role.github_actions_oidc.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
# optional: comment out if using custom ecr_policy only
#}
