✅ Runbook Checklist: Triton Deployment Prep
Pre‑Deployment To‑Do List

Verify EFS setup

[ ] Confirm PV → PVC binding (kubectl get pv,pvc -n inference).

[ ] Note EFS DNS (fs-xxxx.efs.us-east-1.amazonaws.com).

[ ] Mount EFS locally on GPU node:

bash
sudo mkdir -p /mnt/efs
sudo mount -t nfs4 -o nfsvers=4.1 fs-xxxx.efs.us-east-1.amazonaws.com:/ /mnt/efs
Prepare model repository

[ ] Create directory structure:

Code
resnet50/
├── config.pbtxt
└── 1/
    └── model.onnx
[ ] Validate config.pbtxt matches ONNX input/output names.

Copy models into EFS

[ ] Copy repo into PVC path:

bash
cp -r /home/ubuntu/mlops-k8s-triton-inference/services/triton/models/resnet50 /mnt/efs/triton-models-pv/
[ ] Verify inside EFS:

bash
ls -lh /mnt/efs/triton-models-pv/resnet50/1/
Deploy Triton

[ ] Run Helm:

bash
helm upgrade --install triton ./helm -n inference -f helm/values.yaml
[ ] Watch pods:

bash
kubectl get pods -n inference -w
Validate model load

[ ] Check logs:

bash
kubectl logs -n inference deploy/triton -c triton | grep resnet50
[ ] Confirm Model resnet50 loaded successfully.

Smoke test inference

[ ] Health check:

bash
curl http://<triton-service>:8000/v2/health/ready
[ ] Send inference request (JSON input → classification output).

✅ Runbook Checklist: Triton Deployment Prep
Pre‑Deployment To‑Do List

Verify EFS setup

[ ] Confirm PV → PVC binding (kubectl get pv,pvc -n inference).

[ ] Note EFS DNS (fs-xxxx.efs.us-east-1.amazonaws.com).

[ ] Mount EFS locally on GPU node:

bash
sudo mkdir -p /mnt/efs
sudo mount -t nfs4 -o nfsvers=4.1 fs-xxxx.efs.us-east-1.amazonaws.com:/ /mnt/efs
Prepare model repository

[ ] Create directory structure:

Code
resnet50/
├── config.pbtxt
└── 1/
    └── model.onnx
[ ] Validate config.pbtxt matches ONNX input/output names.

Copy models into EFS

[ ] Copy repo into PVC path:

bash
cp -r /home/ubuntu/mlops-k8s-triton-inference/services/triton/models/resnet50 /mnt/efs/triton-models-pv/
[ ] Verify inside EFS:

bash
ls -lh /mnt/efs/triton-models-pv/resnet50/1/
Deploy Triton

[ ] Run Helm:

bash
helm upgrade --install triton ./helm -n inference -f helm/values.yaml
[ ] Watch pods:

bash
kubectl get pods -n inference -w
Validate model load

[ ] Check logs:

bash
kubectl logs -n inference deploy/triton -c triton | grep resnet50
[ ] Confirm Model resnet50 loaded successfully.

Smoke test inference

[ ] Health check:

bash
curl http://<triton-service>:8000/v2/health/ready
[ ] Send inference request (JSON input → classification output).
