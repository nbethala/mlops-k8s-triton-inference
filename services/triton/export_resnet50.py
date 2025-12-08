import torch
import torchvision.models as models
from torchvision.models import ResNet50_Weights
import os

# Define output path
output_dir = "services/triton/models/resnet50/1"
os.makedirs(output_dir, exist_ok=True)   # create dirs if missing
output_path = os.path.join(output_dir, "model.onnx")

# Load pretrained ResNet50
model = models.resnet50(weights=ResNet50_Weights.DEFAULT).eval()
dummy_input = torch.randn(1, 3, 224, 224)

# Export to ONNX
torch.onnx.export(
    model,
    dummy_input,
    output_path,
    input_names=["input_tensor"],
    output_names=["output_tensor"],
    opset_version=17,   # modern opset, Triton supports it
    do_constant_folding=True
)

print(f"✅ Exported model to {output_path}")
