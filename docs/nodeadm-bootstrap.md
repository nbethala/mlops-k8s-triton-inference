# End-to-end nodeadm bootstrap plan 

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
│           └── eks/                     # optional module form (if you use modules)
│               ├── main.tf
│               ├── variables.tf
│               ├── outputs.tf
│               └── userdata-nodeadm.yaml
├── k8s/                                  # Kubernetes manifests (workloads, not bootstrap)
│   └── ...
└── README.md
Rule: Place userdata-nodeadm.yaml inside the same Terraform module that defines your aws_launch_template and aws_eks_node_group. If those are in root, keep it under infra/terraform/. If you use modules/eks, keep it inside that module.

Phase 1 — Create control plane and capture values
Apply cluster only:

bash
cd mlops-k8s-triton-inference/infra/terraform
terraform apply -target=aws_eks_cluster.this -auto-approve
Fetch cluster details:

bash
aws eks describe-cluster --name triton-gpu-cluster --query "cluster.status"
aws eks describe-cluster --name triton-gpu-cluster --query "cluster.endpoint" --output text
aws eks describe-cluster --name triton-gpu-cluster --query "cluster.certificateAuthority.data" --output text
Status: Must be ACTIVE.

Endpoint: Use as apiServerEndpoint.

CA (base64): Use as certificateAuthority.

Phase 2 — Create nodeadm payload file
Create infra/terraform/userdata-nodeadm.yaml with MIME + NodeConfig:

text
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: application/node.eks.aws

apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: triton-gpu-cluster
    apiServerEndpoint: https://<paste-cluster-endpoint>
    certificateAuthority: <paste-base64-ca>
  kubelet:
    flags:
      - --node-labels=nvidia.com/gpu=true
    config:
      clusterDNS:
        - 10.100.0.10
--//
Content-Type: Must be application/node.eks.aws for nodeadm.

cluster.name: Exact cluster name.

cluster.apiServerEndpoint / certificateAuthority: From Phase 1.

clusterDNS: Adjust if your service CIDR differs; default works for most EKS setups.

Phase 3 — Wire launch template and nodegroup
In infra/terraform/main.tf, define launch template using the payload:

hcl
resource "aws_launch_template" "gpu_nodes" {
  name_prefix             = "gpu-node-"
  update_default_version  = true

  # user_data must be base64-encoded
  user_data = base64encode(file("${path.module}/userdata-nodeadm.yaml"))
}
Define the GPU nodegroup:

hcl
resource "aws_eks_node_group" "gpu_nodes" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "triton-gpu-cluster-gpu-on-demand"
  node_role_arn   = aws_iam_role.eks_gpu_node_role.arn
  subnet_ids      = module.vpc.private_subnets

  ami_type       = "AL2023_x86_64_NVIDIA"
  instance_types = ["g4dn.xlarge"]
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 0
  }

  launch_template {
    id      = aws_launch_template.gpu_nodes.id
    version = "$Latest"
  }

  labels = {
    "nvidia.com/gpu" = "true"
  }
}
ami_type: Enforces AL2023 GPU AMI with nodeadm support.

launch_template.user_data: Supplies NodeConfig to nodeadm at boot.

scaling_config: Keep small to control cost.

Ensure node IAM role policies (once):

AmazonEKSWorkerNodePolicy

AmazonEKS_CNI_Policy

AmazonEC2ContainerRegistryReadOnly

Phase 4 — Apply and verify
Apply nodegroup:

bash
terraform apply -target=aws_eks_node_group.gpu_nodes -auto-approve
Update kubeconfig and check nodes:

bash
aws eks update-kubeconfig --name triton-gpu-cluster --region us-east-1
kubectl get nodes -o wide
kubectl get pods -n kube-system
Expected: Nodes show Ready; coredns, aws-node, kube-proxy are Running.

GPU smoke test (optional):

yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-test
spec:
  containers:
  - name: cuda-vector-add
    image: nvidia/samples:vectoradd-cuda11.6
    resources:
      limits:
        nvidia.com/gpu: 1
bash
kubectl apply -f gpu-test.yaml
kubectl logs gpu-test
Phase 5 — Teardown hygiene (cost control)
Destroy cleanly when done:

bash
terraform destroy -auto-approve
```

Goal: No leftovers, no state drift, no surprise costs.

Notes on module placement:1

Root-managed EKS: Keep userdata-nodeadm.yaml under infra/terraform/ and reference with ${path.module}.

Module-managed EKS: Place userdata-nodeadm.yaml inside infra/terraform/modules/eks/ and reference with ${path.module} inside that module.

Principle: The payload lives next to the Terraform code that owns the launch template and nodegroup.

Quick checklist (copy/paste)
Create cluster only: terraform apply -target=aws_eks_cluster.this

Fetch endpoint + CA: aws eks describe-cluster …

Create userdata-nodeadm.yaml: MIME + NodeConfig with endpoint/CA

Define launch template: user_data = base64encode(file("${path.module}/userdata-nodeadm.yaml"))

Define nodegroup: ami_type AL2023_x86_64_NVIDIA, instance g4dn.xlarge, use launch template

Apply nodegroup: terraform apply -target=aws_eks_node_group.gpu_nodes

Verify: kubectl get nodes; kube-system pods Running

Teardown (optional): terraform destroy
