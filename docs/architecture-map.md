Architecture Mental Map: 

AWS, Kubernetes, and Triton connect together. 
The image is ready now — it shows AWS EFS storage, Kubernetes cluster orchestration, GPU nodes, PVCs, and the Triton Inference Server pod consuming models.


🧠 Textual Mental Map (Checklist + Flow)
1. AWS Layer
ECR → stores Triton container images.

EFS → shared model repository (resnet50/config.pbtxt + 1/model.onnx).

EC2 GPU Nodes → run Kubernetes worker nodes with GPU acceleration.

2. Kubernetes Layer
PersistentVolume (PV) → points to EFS (fs-xxxx.efs.us-east-1.amazonaws.com:/).

PersistentVolumeClaim (PVC) → bound to PV, mounted into pods at /models.

Helm Chart → defines Deployment, Service, HPA, etc. for Triton.

3. Pod Layer
Triton Pod → runs tritonserver container.

Mounts PVC → /models inside pod = EFS repo.

Init/Sidecar (optional) → sync models or monitor health.

Service → exposes Triton endpoints (HTTP:8000, gRPC:8001, Metrics:8002).

4. Client Layer
Inference Requests → flow through Kubernetes Service → Triton Pod → GPU inference.

Monitoring → Prometheus + Grafana dashboards for observability.
