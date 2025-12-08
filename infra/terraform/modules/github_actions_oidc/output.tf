output "github_actions_role_arn" {
  description = "ARN of the IAM role assumed by GitHub Actions"
  value       = aws_iam_role.github_actions_oidc.arn
}

output "ecr_policy_arn" {
  description = "ARN of the ECR policy attached to the role"
  value       = aws_iam_policy.ecr_policy.arn
}

#output "s3_policy_arn" {
#  description = "ARN of the S3 policy attached to the role"
#  value       = aws_iam_policy.s3_policy.arn
#}

#output "eks_terraform_policy_arn" {
#  description = "ARN of the EKS Terraform policy attached to the role"
#  value       = aws_iam_policy.eks_terraform_policy.arn
#}

#output "misc_policy_arn" {
#  description = "ARN of the misc CloudWatch/ELB policy attached to the role"
#  value       = aws_iam_policy.misc_policy.arn
#}
