# Find your EFS mount point

```

Check your PVC → PV mapping You already saw:

Code
triton-models-pvc   Bound    triton-models-pv   20Gi   RWX   efs-sc-manual
That means your PersistentVolume (triton-models-pv) is backed by an EFS filesystem.

Inspect the PV definition Run:

bash
kubectl get pv triton-models-pv -o yaml
Look for:

yaml
spec:
  csi:
    driver: efs.csi.aws.com
    volumeHandle: fs-xxxxxxxx
→ fs-xxxxxxxx is your EFS FileSystem ID.

Find the DNS name for that EFS In AWS console or CLI:

bash
aws efs describe-file-systems --file-system-id fs-xxxxxxxx
aws efs describe-mount-targets --file-system-id fs-xxxxxxxx
The mount target DNS looks like:

Code
fs-xxxxxxxx.efs.us-east-1.amazonaws.com
Check your EC2 mounts On the node:

bash
df -hT | grep efs
mount | grep efs
→ This shows the actual mount point path (often /mnt/efs, /efs, or /var/lib/kubelet/pods/.../volumes/kubernetes.io~csi/...).

✅ What to do next
Once you know the mount path (say /mnt/efs), copy your model repo into it:

bash
cp -r /home/ubuntu/mlops-k8s-triton-inference/services/triton/models/resnet50 /mnt/efs/triton-models-pv/
Verify inside the pod with a debug container:

bash
kubectl run pvc-debug -n inference --rm -it --image=amazon/aws-cli:latest -- \
  ls /models/resnet50/1
🚩 Hygiene
Always confirm the EFS mount path on the node before copying.

Document the PV → PVC → EFS mapping so onboarding engineers know where to place models.

Keep models versioned and configs at the root.
```

PV spec tells us exactly what your EFS mount point is:

🔎 Key fields in your PV
yaml
spec:
  nfs:
    path: /
    server: fs-0e6fc666b970325a9.efs.us-east-1.amazonaws.com
server → fs-0e6fc666b970325a9.efs.us-east-1.amazonaws.com That’s the DNS name of your EFS file system.

path → / Means the root of the EFS file system is being mounted.

storageClassName → efs-sc-manual Confirms this PV is manually bound to EFS via NFS.
