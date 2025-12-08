output "eks_operator_role_arn" {
  value = aws_iam_role.eks_operator.arn
}

output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller.arn
}

output "cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

output "eks_node_role_name" {
  value = aws_iam_role.eks_node_role.name
}

output "eks_cluster_role_arn" {
  value       = aws_iam_role.eks_cluster_role.arn
  description = "IAM role ARN for the EKS cluster"
}

output "eks_nodegroup_role_arn" {
  value       = aws_iam_role.eks_nodegroup_role.arn
  description = "IAM role ARN for the EKS nodegroup"
}
