resource "aws_ecr_repository" "triton" {
  name = "triton-infer"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "AES256" }
  tags = {
    project = var.project
    owner   = var.owner

  }
}
