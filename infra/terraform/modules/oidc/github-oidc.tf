data "aws_iam_openid_connect_provider" "eks_oidc" {
  # If you manage provider in cluster/eks module, reference it; else create new provider for GH:
  arn = var.oidc_provider_arn # if using existing
}

resource "aws_iam_role" "github_actions_ecr" {
  name = "github-actions-ecr-push"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com" },
      Action    = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
      }
    }]
  })
}

resource "aws_iam_policy" "ecr_push_policy" {
  name = "github-ecr-push-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["ecr:GetAuthorizationToken"], Resource = "*" },
      { Effect = "Allow", Action = [
        "ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer", "ecr:PutImage",
        "ecr:InitiateLayerUpload", "ecr:UploadLayerPart", "ecr:CompleteLayerUpload",
        "ecr:CreateRepository", "ecr:DescribeRepositories"
      ], Resource = aws_ecr_repository.triton.arn }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ecr" {
  role       = aws_iam_role.github_actions_ecr.name
  policy_arn = aws_iam_policy.ecr_push_policy.arn
}

