resource "aws_eks_node_group" "gpu_on_demand" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-gpu-on-demand"
  node_role_arn   = var.node_role_arn

  #use public subnet 
  # Use the public subnet(s)
    subnet_ids = var.public_subnet_ids

  instance_types = ["g4dn.xlarge"]
  capacity_type  = "ON_DEMAND"
  ami_type       = "AL2023_x86_64_NVIDIA"

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.gpu_nodes.id
    version = "$Latest"
 }

  labels = {
    accelerator = "nvidia"
  }

  tags = {
    project = var.project
    owner   = var.owner
  }
}

# =================================================================
# launch template for bootstrapping cluster using nodeadm 
# =============================================================
resource "aws_launch_template" "gpu_nodes" {
  name_prefix            = "gpu-node-"
  update_default_version = true

   key_name = var.ssh_key_name  


   metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Nodeadm + cluster bootstrap config
  user_data = base64encode(
    templatefile("${path.module}/userdata-nodeadm.yaml", {
      cluster_name     = var.cluster_name
      cluster_endpoint = var.cluster_endpoint
      cluster_ca       = var.cluster_ca
    })
  )
}
