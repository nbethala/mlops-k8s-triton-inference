resource "aws_launch_template" "gpu_nodes" {
  name_prefix            = "gpu-node-"
  update_default_version = true
  key_name               = var.ssh_key_name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Root volume mapping
  block_device_mappings {
    device_name = "/dev/xvda"   # root disk
    ebs {
      volume_size = 100         # 100 GiB
      volume_type = "gp3"       # gp3 recommended
      delete_on_termination = true
    }
  }

  # Nodeadm bootstrap config
  user_data = base64encode(
    templatefile("${path.module}/userdata-nodeadm.yaml", {
      cluster_name     = var.cluster_name
      cluster_endpoint = var.cluster_endpoint
      cluster_ca       = var.cluster_ca
    })
  )
}
