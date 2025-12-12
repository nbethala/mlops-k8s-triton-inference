# GPU Node Issues in MLOps Triton Inference

This document summarizes the challenges encountered while provisioning and running GPU nodes for Triton inference workloads in Kubernetes.

---

## �� Issues Faced

### 1. Pod Scheduling Failures
- **Symptom:** Pods stuck in `Pending` with `FailedScheduling`.
- **Cause:** Resource requests (CPU, memory, ephemeral storage) exceeded node allocatable.
- **Fix:** Reduced ephemeral storage requests to ≤ 18Gi to match node capacity.

### 2. Disk Pressure Taints
- **Symptom:** `node.kubernetes.io/disk-pressure` taint blocked scheduling.
- **Cause:** GPU nodes provisioned with default 20Gi root volumes; containerd ran out of space unpacking Triton images.
- **Fix:** Increased root volume size to 100Gi in AWS Launch Template.

### 3. ImagePullBackOff
- **Symptom:** Triton pod stuck with `ImagePullBackOff`, error: `no space left on device`.
- **Cause:** Large Triton image layers exhausted containerd overlayfs storage.
- **Fixes:**
  - Pruned containerd cache (`ctr -n k8s.io images prune`).
  - Switched to `py3-min` Triton image variant.
  - Resized root volume for permanent resolution.

### 4. PVC Binding
- **Symptom:** Triton pod unable to mount `/models`.
- **Cause:** PVC misconfiguration or missing EFS mount targets.
- **Fix:** Corrected `StorageClass` parameters, ensured PVC status = `Bound`.

### 5. Node Label/Taint Mismatch
- **Symptom:** Scheduler ignored GPU node.
- **Cause:** Missing or incorrect node labels (`accelerator=nvidia`).
- **Fix:** Applied consistent labels and taints during nodeadm bootstrap.

---

## ✅ Lessons Learned

- Always align pod resource requests with node allocatable values.
- GPU nodes require **≥ 100Gi root volumes** to handle Triton image pulls.
- Document bootstrap steps (`nodeadm`) for reproducibility and onboarding.
- Use slim Triton images (`py3-min`) to reduce disk footprint.
- PVCs must be validated (`Bound`) before deploying inference workloads.

---

## 📌 Next Steps

- Bake larger root volumes into Terraform launch templates.
- Automate containerd cache pruning in node lifecycle hooks.
- Maintain onboarding docs for GPU node bootstrap and PVC hygiene.

