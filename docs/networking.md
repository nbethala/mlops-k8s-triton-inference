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

