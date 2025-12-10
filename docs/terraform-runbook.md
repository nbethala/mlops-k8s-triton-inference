# Terrafrome xecution plan: The layer cake 

 ---------------------------
|        CI/CD Layer         |
 ---------------------------
|       Monitoring           |
 ---------------------------
|    GPU Compute Nodes       |
 ---------------------------
|   Baseline System Nodes    |
 ---------------------------
|      EKS Control Plane     |
 ---------------------------
|   Networking + IAM (VPC)   |
 ---------------------------

# order of execution in production: 

terraform apply -target=module.vpc
terraform apply -target=module.iam

🔵 1. Networking + IAM (Foundation layer)
You create:

VPC / subnets

Route tables

NAT gateways

Control-plane IAM roles

Node IAM roles


🟣 2. EKS Cluster creation

Once networking/IAM exist → create the control plane.

Outputs become:

cluster_endpoint

cluster_ca

cluster_security_group_id

node_role_arn

These are inputs to nodegroups.

NO nodes yet. Just control plane.

🟢 3. Baseline Nodegroup (system nodes, NOT GPU)

This is where most people mess up.

Why baseline nodes FIRST?

Because:

the EKS cluster needs system pods to stabilize
(CoreDNS, VPC CNI, Kube-proxy)

GPU nodegroups are NOT meant to run system pods

GPU AMIs boot slower

GPU nodes must join after cluster is healthy

If you install GPU nodes first, issues occur:

Node never joins

kubelet can’t reach API server

CNI not ready

SSM/SSH fails

Launch templates break

Security groups incomplete

You must first confirm:

kubectl get nodes
kubectl -n kube-system get pods


ALL green.

🟠 4. GPU Nodegroup (Triton, workloads layer)

Now the GPU nodegroup module can be applied independently.

At this stage:

cluster endpoint exists

nodeadm user_data works

CNI is installed

control plane and system nodes are healthy

ONLY NOW does GPU node join normally.

This avoids:

SSM connection problems

kubelet bootstrap failures

failed node joins

EC2 stuck in NotReady

🟡 5. Monitoring (Prometheus, Grafana, DCGM Exporter)

This should NEVER be installed before the cluster + nodes are healthy.

If you try it earlier:

Helm charts fail to install

CRDs missing

GPU metrics exporter crashes

NodeExporter can’t scrape nodes

By doing monitoring after GPU nodes, you guarantee everything binds correctly.

🔴 6. CI/CD (Last layer)

CI/CD depends on:

IAM OIDC correct

ECR repository existing

Cluster reachable

Helm charts functional

If you deploy CI/CD earlier → workflows fail and you end up debugging ghosts.
