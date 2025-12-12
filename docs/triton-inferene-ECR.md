# Steps to build/push model to AWS-ECR the Triton Inferenc
============================================================

```

🔥 Phase 1: Build & Push Triton Image to ECR
Create ECR repo

bash
aws ecr create-repository \
  --repository-name triton \
  --region us-east-1
→ URI: 478253497479.dkr.ecr.us-east-1.amazonaws.com/triton

Login Docker to ECR

bash
aws ecr get-login-password --region us-east-1 \
  | docker login \
    --username AWS \
    --password-stdin 478253497479.dkr.ecr.us-east-1.amazonaws.com
Build image from your Dockerfile

bash
cd /home/ubuntu/mlops-k8s-triton-inference/services/triton
docker build -t triton:resnet50 .
Tag & push

bash
docker tag triton:resnet50 478253497479.dkr.ecr.us-east-1.amazonaws.com/triton:resnet50
docker push 478253497479.dkr.ecr.us-east-1.amazonaws.com/triton:resnet50
🔥 Phase 2: Update Kubernetes Deployment
Edit helm/templates/deployment.yaml (or your raw manifest):

yaml
image: 478253497479.dkr.ecr.us-east-1.amazonaws.com/triton:resnet50
imagePullPolicy: Always
If needed, add ECR pull secret:

yaml
spec:
  template:
    spec:
      imagePullSecrets:
      - name: ecr-secret
Apply:

bash
helm upgrade --install triton ./helm -n inference
🔥 Phase 3: Model Repository on EFS
Your repo already has:

Code
models/resnet50/1/model.onnx
models/resnet50/config.pbtxt
Mount /models from PVC → Triton auto‑discovers models.

Example config.pbtxt for ResNet50:

protobuf
name: "resnet50"
platform: "onnxruntime_onnx"
max_batch_size: 8
input [
  {
    name: "input"
    data_type: TYPE_FP32
    dims: [3, 224, 224]
  }
]
output [
  {
    name: "output"
    data_type: TYPE_FP32
    dims: [1000]
  }
]
🔥 Phase 4: Test Inference
HTTP inference

bash
curl -v http://<triton-service>:8000/v2/models/resnet50/versions/1/infer \
  -d '{"inputs":[{"name":"input","shape":[1,3,224,224],"datatype":"FP32","data":[...]}]}'
Python client

python
import tritonclient.grpc as grpc
client = grpc.InferenceServerClient("triton.inference.svc.cluster.local:8001")
result = client.infer("resnet50", inputs=[...])
print(result)
Metrics

bash
curl http://<triton-service>:8002/metrics

```

Key Notes About Your Dockerfile

Base image

FROM nvcr.io/nvidia/tritonserver:24.01-py3-min


Minimal Triton server with Python 3 support.

GPU ready.

Smallest image footprint for fast portfolio experimentation.

Working directory

WORKDIR /opt/tritonserver


The Triton server runs here, but it doesn’t affect your /models mount.

No baked models

# Do NOT copy models into the image


✅ Correct for dynamic model loading via EFS.

EntryPoint and CMD

ENTRYPOINT ["tritonserver"]
CMD ["--model-repository=/models","--model-control-mode=poll","--repository-poll-secs=5"]


Mount /models from EFS.

Polls models every 5 seconds, auto-loading new models.

--model-control-mode=poll ensures changes in EFS are automatically detected
