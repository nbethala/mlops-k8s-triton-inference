output "vpc_id" {
  value = aws_vpc.gpu_e2e.id
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_a.id
  ]
}

