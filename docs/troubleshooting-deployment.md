markdown
# Triton Helm Deployment – Troubleshooting Log

This document summarizes the issues encountered and fixes applied while deploying Triton Inference Server on EKS with Helm.

---

## Issues & Fixes

### 1. Schema Validation Failure
- **Error:** `values don't meet the specifications of the schema(s)... missing property 'port'`
- **Cause:** `service:` block in `values.yaml` used `ports:` array, but schema required a single `port` integer.
- **Fix:** Updated `values.yaml` to:
  ```yaml
  service:
    type: ClusterIP
    port: 8000
2. Service Ports Misalignment
Error: spec.ports[1].port: Invalid value: 0

Cause: service.yaml template referenced .Values.service.grpc_port and .Values.service.metrics_port, which didn’t exist.

Fix: Corrected template to use .Values.ports.http, .Values.ports.grpc, .Values.ports.metrics.

3. VolumeMount Name Mismatch
Error: volumeMounts[0].name: Not found: "model-repo"

Cause: Deployment template defined volumeMounts with model-repo but volumes used PVC claim name directly.

Fix: Standardized both to use .Values.persistence.mountName.

4. Missing ServiceAccount
Error: pods ... forbidden: error looking up service account inference/triton-sa

Cause: Deployment referenced serviceAccountName: triton-sa but ServiceAccount wasn’t created.

Fix: Added serviceaccount.yaml template:

yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ .Values.serviceAccount.name }}
  namespace: {{ .Release.Namespace }}
5. InitContainer Image Not Found
Error: ImagePullBackOff: amazon/aws-cli:2.16.19 not found

Cause: Non-existent tag on Docker Hub.

Fix: Switched to amazon/aws-cli:latest.

6. Resource Scheduling Failure
Error: FailedScheduling: Insufficient cpu, memory, nvidia.com/gpu

Cause: Requests/limits maxed out node capacity (g4dn.xlarge).

Fix: Reduced resource limits in values.yaml:

yaml
limits:
  cpu: "3"
  memory: 12Gi
  nvidia.com/gpu: 1
requests:
  cpu: "2"
  memory: 8Gi
Lessons Learned
Align schema, values, and templates carefully.

Always verify image tags exist before pinning.

Ensure ServiceAccounts are created when referenced.

Size resource requests to leave headroom for system pods.

Document every fix for reproducibility and onboarding.
