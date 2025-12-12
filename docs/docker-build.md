# Build and deploy Triton

🔧 Step 1: Fix Dockerfile
Use the NVIDIA base image directly, no overrides:

dockerfile
# services/triton/Dockerfile
FROM nvcr.io/nvidia/tritonserver:24.01-py3-min

# Do NOT copy models into the image
# Keep default entrypoint provided by NVIDIA
🔧 Step 2: Build & Push to ECR
From your services/triton directory:

bash
# Authenticate to ECR
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS \
  --password-stdin {ACCTOUNT_NUMBER}.dkr.ecr.us-east-1.amazonaws.com

# Build the image
docker build -t triton:24.01-py3-min .

# Tag for ECR
docker tag triton:24.01-py3-min \
  {ACCOUNT_NUMBER}.dkr.ecr.us-east-1.amazonaws.com/triton:24.01-py3-min

# Push to ECR
docker push {ACCOUNT_NUMBER}.dkr.ecr.us-east-1.amazonaws.com/triton:24.01-py3-min
🔧 Step 3: Update Helm values
In helm/values.yaml, set:

yaml
image:
  repository: {ACCOUNT_NUMBER}.dkr.ecr.us-east-1.amazonaws.com/triton
  tag: 24.01-py3-min

args:
  - "--model-repository=/models"
  - "--model-control-mode=poll"
  - "--repository-poll-secs=5"
🔧 Step 4: Redeploy Triton
bash
helm upgrade --install triton ./helm -n inference -f helm/values.yaml
kubectl get pods -n inference -w
🔧 Step 5: Verify
bash
kubectl logs -n inference deploy/triton -c triton | grep "Server started"
kubectl get svc -n inference triton-service
