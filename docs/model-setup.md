# ResNet50 Model Repository for Triton Inference Server

This directory contains the ResNet50 model and configuration files required by
[NVIDIA Triton Inference Server](https://github.com/triton-inference-server/server).

## Directory Structure

Triton expects each model to follow a specific layout:

```
resnet50/ ├── config.pbtxt # Model configuration └── 1/ # Versioned subdirectory └── model.onnx # Actual model file
```


- `config.pbtxt` must be placed at the **root of the model directory**.
- Model binaries (`model.onnx`, `model.plan`, etc.) must be placed inside **numbered version folders** (`1/`, `2/`, …).

---

## Step 1: Download the ResNet50 ONNX Model

You can obtain a validated ResNet50 ONNX model from the official ONNX Model Zoo:

```bash
wget https://github.com/onnx/models/raw/main/validated/vision/classification/resnet/model/resnet50-v2-7.onnx -O model.onnx

Move the file into the versioned folder:

bash
mkdir -p resnet50/1
mv model.onnx resnet50/1/

Step 2: Create the config.pbtxt
The configuration file describes the model’s inputs, outputs, and runtime settings. For ResNet50 ONNX, the typical configuration looks like this:

name: "resnet50"
platform: "onnxruntime_onnx"
max_batch_size: 8

input [
  {
    name: "data"              # Must match ONNX input tensor name
    data_type: TYPE_FP32
    format: FORMAT_NCHW
    dims: [3, 224, 224]
  }
]

output [
  {
    name: "prob"              # Must match ONNX output tensor name
    data_type: TYPE_FP32
    dims: [1000]
  }
]

instance_group [
  {
    kind: KIND_GPU
    count: 1
  }
]

How to determine input/output names
Inspect the ONNX file to confirm tensor names:

python -c "import onnx; m=onnx.load('resnet50/1/model.onnx'); \
print('Inputs:', [i.name for i in m.graph.input]); \
print('Outputs:', [o.name for o in m.graph.output])"

Update config.pbtxt so the input.name and output.name match exactly.

Step 3: Deploy with Triton
Once the directory is populated:

bash
resnet50/
├── config.pbtxt
└── 1/
    └── model.onnx
Mount this directory into your Triton container (e.g., via PVC at /models). Triton will automatically load the model at startup.

otes
Always keep config.pbtxt at the model root, not inside version folders.

Use numbered subdirectories (1/, 2/, …) for versioning.

If you add new versions, Triton can serve multiple versions simultaneously.

Ensure tensor names in config.pbtxt match the ONNX graph exactly, or Triton will log errors.


ONNX is the Open Neural Network Exchange format — a standardized, open‑source way to represent machine learning and deep learning models so they can run across different frameworks and hardware.

🔎 What ONNX actually is
Definition: ONNX is a common language for ML models. It encodes the computational graph (layers, operations, weights) in a portable format based on Protocol Buffers.

Purpose: It was created by Microsoft and Facebook in 2017 to avoid vendor lock‑in and make models interoperable across frameworks like PyTorch, TensorFlow, MXNet, and deployment engines like Triton.

File extension: Models are stored in .onnx files. These files contain:

GraphProto: the computation graph (operators like convolution, ReLU, pooling).

TensorProto: the weights and parameters.

Metadata: opset version, producer framework, etc.

✅ Why ONNX matters for you
Portability: Train a model in PyTorch, export to ONNX, then run it in Triton or TensorRT without rewriting.

Standardization: ONNX defines ~200+ operators (Conv, MatMul, Add, etc.) so inference engines know exactly how to execute them.

Deployment: Triton Inference Server natively supports ONNX models (platform: "onnxruntime_onnx" in config.pbtxt). That’s why your ResNet50 model must be in .onnx format.

📊 Comparison: ONNX vs other formats
Format	Typical Source	Use Case	Portability
.pth	PyTorch	Training checkpoint	Low
.pb / SavedModel	TensorFlow	Training + serving	Medium
.onnx	PyTorch, TF, others	Cross‑framework inference (Triton, TensorRT, ONNX Runtime)	High
.plan	TensorRT	Optimized GPU inference	Low (engine‑specific)
🚩 Risks & considerations
Operator mismatch: If your model uses ops not supported in ONNX, export may fail.

Tensor names: ONNX preserves input/output names from the training framework. Your config.pbtxt must match them exactly.

Opset versioning: ONNX evolves; newer opsets may not be supported by older runtimes. Always check compatibility.


#### ===================================================================
## Python script to generate your config inputs/outputs for your model
#### ====================================================================
python3 - << 'EOF'
import onnx
from onnx import mapping

m = onnx.load("resnet50.onnx")

print("\n=== MODEL INPUTS ===")
for inp in m.graph.input:
    dims = [d.dim_value for d in inp.type.tensor_type.shape.dim]
    dtype = mapping.TENSOR_TYPE_TO_NP_TYPE[inp.type.tensor_type.elem_type]
    print(f" • {inp.name:25s} shape={dims} dtype={dtype}")

print("\n=== MODEL OUTPUTS ===")
for out in m.graph.output:
    dims = [d.dim_value for d in out.type.tensor_type.shape.dim]
    dtype = mapping.TENSOR_TYPE_TO_NP_TYPE[out.type.tensor_type.elem_type]
    print(f" • {out.name:25s} shape={dims} dtype={dtype}")
EOF

