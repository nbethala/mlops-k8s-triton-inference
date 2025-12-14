    # Networking Key Points:

GPU Nodes in Public Subnet

Launch template must associate public IP.

Security group allows SSH from your dev EC2.

Can directly reach EKS control plane (HTTPS).

Private Nodes

Launch in private subnets.

Use NAT Gateway to access the internet.

No public IP; can’t be SSH-ed directly.

Terraform Order

Apply VPC → Subnets → IGW/NAT → Route Tables → EKS → Node Groups in one apply.

This avoids issues like your GPU nodes being created before the subnets/route tables exist.




                 +-----------------------+
                 |      Internet         |
                 +-----------------------+
                          |
                          | 0.0.0.0/0
                          v
                 +-----------------------+
                 |   Internet Gateway    |  <-- module.vpc.aws_internet_gateway.gw
                 +-----------------------+
                          |
          +---------------+-----------------+
          |                                 |
+--------------------+            +--------------------+
|  Public Subnet A   |            |  Private Subnet A  |
|  10.0.1.0/24       |            |  10.0.2.0/24       |
|  map_public_ip=true |            |  map_public_ip=false|
|  RT -> IGW          |            |  RT -> NAT Gateway |
+--------------------+            +--------------------+
          |                                 |
          |                                 |
  +----------------+                +----------------+
  | GPU Node(s)    |                | Private Node(s)|
  | EKS Worker     |                | EKS Worker     |
  | Public IP      |                | No Public IP   |
  +----------------+                +----------------+

                 +-----------------------+
                 | NAT Gateway (Public)  |  <-- module.vpc.aws_nat_gateway.nat_gw_a
                 +-----------------------+
                          |
          +---------------+----------------+
          | Private Subnets outbound only |
          +-------------------------------+


### 
Networking Setup and Troubleshooting Guide
This README provides a concise reference for setting up and troubleshooting VPC peering, Amazon EFS, and NFS mounts in AWS environments.

1. VPC Peering Setup
Steps
Create peering connection between two VPCs (Requester and Accepter).

Accept the peering request in the Accepter VPC.

Update route tables in both VPCs:

Add routes pointing to the peered VPC CIDR.

Check DNS resolution:

Enable enableDnsHostnames and enableDnsSupport in both VPCs.

Troubleshooting
Verify routes exist in both VPCs.

Confirm SGs/NACLs allow traffic between peered VPCs.

Use ping or telnet to test connectivity across VPCs.

2. Amazon EFS Setup
Regional vs One Zone
Regional EFS: Can create mount targets in every AZ of the region.

One Zone EFS: Restricted to a single AZ; mount targets only allowed in that AZ.

Steps
Create EFS file system (default is Regional).

Create mount targets:

One per AZ where EC2/Kubernetes nodes run.

Subnet and SG must belong to the same VPC.

Security group rules:

Inbound: Allow TCP/2049 from node SG.

Outbound: Usually open by default.

Troubleshooting
Run:

aws efs describe-mount-targets --file-system-id <fs-id> --region us-east-1 --output table
Ensure mount targets exist in the same AZ as your nodes.

If AvailabilityZonesMismatch error occurs → file system is One Zone, restricted to one AZ.

If SecurityGroupNotFound error occurs → SG and subnet are in different VPCs.

3. NFS Mount Verification
Steps on EC2/K8s Node
Check DNS resolution:

nslookup <fs-id>.efs.<region>.amazonaws.com
Test NFS exports:

showmount -e <fs-id>.efs.<region>.amazonaws.com
Manual mount:

sudo mkdir -p /mnt/efs-test
sudo mount -t nfs4 -o nfsvers=4.1 <fs-id>.efs.<region>.amazonaws.com:/ /mnt/efs-test
Verify mount:

df -h | grep efs
mount | grep efs
File test:

echo "hello" | sudo tee /mnt/efs-test/verify.txt
cat /mnt/efs-test/verify.txt
Troubleshooting
NXDOMAIN → No mount target in node’s AZ.

Permission denied → SG ingress missing TCP/2049 from node SG.

Timeout → NACLs or routes blocking traffic.

4. Quick Checklist
[ ] VPC peering accepted and routes updated.

[ ] DNS support enabled in both VPCs.

[ ] Mount targets created in each AZ where nodes run.

[ ] SG inbound rule: TCP/2049 from node SG.

[ ] NACLs allow traffic.

[ ] DNS resolves and manual mount succeeds.

This guide ensures reproducible setup and rapid troubleshooting for AWS networking with VPC peering, EFS, and NFS.


