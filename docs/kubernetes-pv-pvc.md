# Update PV YAML
cat > triton-models-pv.yaml <<'EOF'
apiVersion: v1
kind: PersistentVolume
metadata:
  name: triton-models-pv
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc
  persistentVolumeReclaimPolicy: Retain
  csi:
    driver: efs.csi.aws.com
    volumeHandle: fs-010c84cb1be15cfd2:/models
EOF

# Apply changes
kubectl delete pvc triton-models-pvc -n inference
kubectl delete pv triton-models-pv
sleep 3
kubectl apply -f triton-models-pv.yaml
kubectl apply -f triton-models-pvc.yaml

# Restart Triton
kubectl rollout restart deployment <triton-deployment-name> -n inference

Verify It Works
bash# Check files in pod
kubectl exec -n inference <triton-pod> -- ls -la /models/
kubectl exec -n inference <triton-pod> -- ls -la /models/resnet50/

# Check Triton logs
kubectl logs -n inference <triton-pod> | grep -i resnet50
You should now see the model loaded successfully! 🚀

EFS Mounted But Files Not Visible in Pods - Troubleshooting Guide
This is a common issue where EFS appears mounted but the expected files aren't visible. Let's systematically troubleshoot this.
Common Root Causes
1. Incorrect Sub-Path or Mount Path
The most common issue - EFS is mounted at the root, but you're looking in the wrong location or the files don't exist at that path in EFS.
Check:
bash# Exec into the pod
kubectl exec -it <pod-name> -- sh

# Check what's actually at the mount point
ls -la /mnt/efs-test/
ls -la /mnt/efs-test/resnet50

# Check mount points
mount | grep efs
df -h | grep efs
Verify in EFS:
bash# From an EC2 instance or bastion with EFS mounted
ls -la /mnt/efs/resnet50
# Are the files actually there in EFS?
2. PV/PVC Configuration Mismatch
Check your PV definition:
yamlapiVersion: v1
kind: PersistentVolume
metadata:
  name: efs-pv
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: efs-sc
  csi:
    driver: efs.csi.aws.com
    volumeHandle: fs-12345678:/resnet50  # <-- Is this path correct?
    # OR
    volumeHandle: fs-12345678  # Root of EFS
Key issue: If volumeHandle includes a subpath (:/resnet50), that directory must exist in EFS at the root level.
3. EFS CSI Driver Subpath Issue
yaml# In your Pod spec
volumeMounts:
  - name: efs-storage
    mountPath: /mnt/efs-test
    subPath: resnet50  # <-- This might be the issue
If you're using subPath, the directory must already exist in the mounted volume.
