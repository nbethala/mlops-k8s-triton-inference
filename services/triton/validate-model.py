import onnx
import onnxruntime as ort
import numpy as np
import os

# Path to the ONNX model inside Triton repo layout
MODEL_PATH = "services/triton/models/resnet50/1/model.onnx"

# Ensure the file exists
if not os.path.exists(MODEL_PATH):
    raise FileNotFoundError(f"Model file not found at {MODEL_PATH}")

# Load and validate the ONNX model
onnx_model = onnx.load(MODEL_PATH)
onnx.checker.check_model(onnx_model)
print("✅ ONNX model structure is valid")

# Create ONNX Runtime inference session
ort_session = ort.InferenceSession(MODEL_PATH)

# Print available execution providers (CPU/GPU)
print("Execution providers:", ort_session.get_providers())

# Run dummy inference
dummy_input = np.random.randn(1, 3, 224, 224).astype(np.float32)
outputs = ort_session.run(None, {"input_tensor": dummy_input})

# Inspect results
print("ONNX inference output shape:", outputs[0].shape)
print("Sample logits (first 10):", outputs[0][0][:10])
