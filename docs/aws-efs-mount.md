# Mounting AWS EFS on EC2 with NFS

This guide explains how to mount an Amazon Elastic File System (EFS) on an EC2 instance using NFSv4.



---

## Prerequisites
- An **EFS file system** created in the same VPC as your EC2.
- At least one **mount target** in the same Availability Zone/subnet as your EC2.
- Security group rules allowing **TCP 2049** between EC2 and EFS.

---

## Steps

### 1. Verify mount target
Check that your EFS mount target is `available`:
```bash
aws efs describe-mount-targets --file-system-id <fs-id>
2. Install NFS client
On Ubuntu/Debian:

bash
sudo apt-get update
sudo apt-get install -y nfs-common
On Amazon Linux/RHEL:

bash
sudo yum install -y nfs-utils
3. Create mount directory
bash
sudo mkdir -p /mnt/efs
4. Mount EFS using NFSv4
bash
sudo mount -t nfs4 -o nfsvers=4.1 \
  <fs-id>.efs.<region>.amazonaws.com:/ /mnt/efs
Example:

bash
sudo mount -t nfs4 -o nfsvers=4.1 \
  fs-02441988e987ecd14.efs.us-east-1.amazonaws.com:/ /mnt/efs
5. Verify mount
bash
df -hT | grep efs
ls -lh /mnt/efs
You should see the EFS mounted as nfs4 with large capacity.

Optional: Persist across reboots
Add an entry to /etc/fstab:

bash
<fs-id>.efs.<region>.amazonaws.com:/ /mnt/efs nfs4 defaults,_netdev 0 0
Notes
Ensure security groups allow inbound/outbound TCP 2049.

Use the amazon-efs-utils helper for TLS/IAM features if desired.

Directory structure inside /mnt/efs should follow Triton model repo conventions if used for inference.

```
