locals {
  repo_subject      = "repo:${var.github_repo}:*"
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

# GitHub Actions OIDC Role
resource "aws_iam_role" "github_actions_oidc" {
  name               = "${var.project}-github-actions-oidc-role"
  assume_role_policy = data.template_file.ci_trust.rendered

  tags = merge({
    "created_by" = "terraform"
    "project"    = var.project
  }, var.common_tags)
}

# -----------------------------
# ECR Policy (Full access for repos)
# -----------------------------
resource "aws_iam_policy" "ecr_policy" {
  name        = "${var.project}-github-ecr-policy"
  description = "Allow pushing/pulling images to ECR repos used by GitHub Actions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ECRFullAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:CreateRepository",
          "ecr:TagResource"
        ],
        Resource = "*"
      }
    ]
  })
}

# -----------------------------
# Attach policies to OIDC role
# -----------------------------
resource "aws_iam_role_policy_attachment" "admin_attach" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
