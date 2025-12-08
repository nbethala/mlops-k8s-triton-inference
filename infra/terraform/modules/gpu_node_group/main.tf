resource "aws_eks_node_group" "gpu_on_demand" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-gpu-on-demand"
  node_role_arn   = var.node_role_arn

  #use public subnet 
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

# Wire the launch template for bootstrapping cluster 

resource "aws_launch_template" "gpu_nodes" {
  name_prefix            = "gpu-node-"
  update_default_version = true

  user_data = base64encode(file("${path.module}/userdata-nodeadm.yaml"))
}
