# Issue : GFD ( GPU Feature discovery ) 
Pods Not scheduing for GPU workloads

Solution : Via helm update/add the GFD. 

Test a Pod :  The pod should show scheduled - nvidia.com/gpu     1           1

```        

dev-ec2-->kubectl run nvidia-test --rm -it --restart=Never   --image=nvidia/cuda:13.0-base   --overrides='
{
  "apiVersion": "v1",
  "spec": {
    "containers": [{
      "name": "nvidia-test",
      "image": "nvidia/cuda:13.0-base",
      "command": ["nvidia-smi"],
      "resources": {
        "limits": {
          "nvidia.com/gpu": 1
        }
      }
    }]
  }
}' 
Error from server (AlreadyExists): pods "nvidia-test" already exists
dev-ec2-->kubectl describe node ip-10-0-1-199.ec2.internal | grep -A10 "Allocated resources:"
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests    Limits
  --------           --------    ------
  cpu                465m (11%)  0 (0%)
  memory             660Mi (4%)  5972Mi (39%)
  ephemeral-storage  0 (0%)      0 (0%)
  hugepages-1Gi      0 (0%)      0 (0%)
  hugepages-2Mi      0 (0%)      0 (0%)
  nvidia.com/gpu     1           1

```

1. Wrong / Missing GPU Node AMI

→ Caused GFD (GPU Feature Discovery) errors
→ Caused NVIDIA drivers mismatch
→ Caused DCGM exporter crash

📌 Fix:
Use official AWS Bottlerocket GPU or NVIDIA EKS-Optimized GPU AMI.

I can add this block to your nodegroup.

2. Missing IAM Permissions for Nodegroup

→ Caused nodes not joining
→ Caused CNI to fail
→ Caused EBS CSI driver to fail (PVC issues)

�� Fix:
Add minimum required IAM:

AmazonEKSWorkerNodePolicy

AmazonEKS_CNI_Policy

AmazonEC2ContainerRegistryReadOnly

AmazonEBSCSIDriverPolicy

I can generate the exact IAM roles for you.

3. Missing EBS CSI Addon in EKS module

→ Caused PVC stuck in Pending

Fix by adding:

eks_addons = {
  "aws-ebs-csi-driver" = {
    most_recent = true
  }
}

4. Monitoring Modules Applied Too Soon

→ PrometheusRule CRDs missing
→ DCGM exporter CRDs missing

Fix: Only install monitoring after EKS is 100% ready and nodes are Healthy.

5. Cluster Security Group Too Restrictive

→ Caused container runtime endpoint not listening
→ Caused GFD unable to talk to kubelet

Fix: Allow internal SG traffic between nodes + control plane.

6. Not Waiting for EKS Nodegroup to Stabilize

→ You applied monitoring too early
→ GFD & DCGM rely on GPU node labels which appear AFTER GFD runs

Fix: Built-in waiters or manual steps:

kubectl wait --for=condition=ready nodes --all --timeout=300s

🟢 After Fixing These — YES, Safe to Destroy & Rebuild

Destroy:

terraform destroy


Then rebuild in this order:

VPC → EKS → Validate nodes → Monitoring → Triton


Your nodes will come up stable because:

AMIs correct

IAM correct

CSI driver installed

GFD works

GPU recognized

Nodegroups healthy

Monitoring CRDs exist
===================================
# Prometheus pod pending :
==================================

Why Prometheus is Pending
A pod stays in Pending when the scheduler can’t place it. Common causes:

No available GPU/CPU/memory on nodes.

Missing PersistentVolumeClaims (PVCs) if the chart requests storage.

Taints on nodes (e.g. GPU nodes tainted, Prometheus not tolerating them).

Affinity rules in the chart that don’t match your node labels.

# Troubleshooting Log – EC2/EKS/Triton Monitoring

## 1. Terraform prompting for `var.nodegroup_role_arn`
**Issue:** `terraform plan` asked interactively for `nodegroup_role_arn`.  
**Solution:** Fetch ARN via AWS CLI (`aws eks describe-nodegroup ... --query "nodegroup.nodeRole"`) and set it in `terraform.tfvars` or export as `TF_VAR_nodegroup_role_arn`.

---

## 2. Dependency cycle with `aws_auth`
**Issue:** `Cycle: module.eks.kubernetes_config_map.aws_auth ...` error.  
**Solution:** Move `aws_auth` ConfigMap into a separate module, remove stale state (`terraform state rm`), then re‑import into the new module.

---

## 3. Helm release error – "Kubernetes cluster unreachable"
**Issue:** `helm_release` tried to use default provider → `no configuration provided`.  
**Solution:** Pass aliased providers (`helm.eks`, `kubernetes.eks`) from root into child modules. Do not define providers inside modules.

---

## 4. Helm release error – "cannot re-use a name that is still in use"
**Issue:** Helm release `nvidia-device-plugin` already existed in cluster.  
**Solution:** Import existing release into Terraform state:  
`terraform import module.nvidia_plugin.helm_release.nvidia_device_plugin kube-system/nvidia-device-plugin`.

---

## 5. Prometheus pod stuck in `Pending`
**Issue:** Pod events showed `unbound immediate PersistentVolumeClaims`.  
**Solution:** Override Helm values to use `emptyDir` instead of PVC:  
`prometheus.prometheusSpec.storageSpec.emptyDir.sizeLimit = "2Gi"`.

---

## 6. Monitoring verification
**Steps:**  
- Confirm Prometheus, Grafana, DCGM exporter pods are `Running`.  
- Port‑forward services to validate UIs and metrics.  
- Ensure NVIDIA device plugin advertises `nvidia.com/gpu` resources.  
- Deploy Triton inference server with GPU resource requests and test readiness (`curl localhost:8000/v2/health/ready`).


## Replicaset not creating pods : 
Conditions:
  Type             Status  Reason
  ----             ------  ------
  ReplicaFailure   True    FailedCreate
Events:
  Type     Reason        Age                   From                   Message
  ----     ------        ----                  ----                   -------
  Warning  FailedCreate  6m32s (x19 over 28m)  replicaset-controller  Error creating: pods "triton-5fc797b8f8-" is forbidden: error looking up service account inference/triton-sa: serviceaccount "triton-sa" not found

solution : check service account 
