# Nodeadm Bootstrapping on GPU Nodes

Directory layout

```
mlops-k8s-triton-inference/
├── infra/
│   └── terraform/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── userdata-nodeadm.yaml        # nodeadm MIME payload (lives with launch template)
│       └── modules/
│           └── gpu_node_group/                     # optional module form (if you use modules)
│               ├── main.tf
│               ├── variables.tf
│               ├── outputs.tf
                |-  launch_template.tf
│               └── userdata-nodeadm.yaml

### Create nodeadm payload file
Create infra/terraform/userdata-nodeadm.yaml with MIME + NodeConfig:

### what this does :? 

Cluster join: Uses cluster_name, cluster_endpoint, and cluster_ca passed from Terraform.

GPU runtime: Installs NVIDIA driver + container toolkit so pods can request nvidia.com/gpu.

Labels/taints: Marks node with accelerator=nvidia and taints it so only GPU workloads land here.

Storage hygiene: Explicitly sets ephemeral storage sizing (≥ 100 Gi).

PVC clarity: Example file shows how to mount your EFS PVC for Triton models.

