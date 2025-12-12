##!/bin/bash

# =================================================
# Usage: ./inspect_onnx.sh /path/to/model.onnx
# auto-generate a Triton config.pbtxt for your model
# ===============================================

MODEL_PATH="$1"

if [ -z "$MODEL_PATH" ]; then
  echo "Usage: $0 /path/to/model.onnx"
  exit 1
fi

# 1️⃣ Create virtual environment if it doesn't exist
VENV_DIR="$HOME/onnx-venv"
if [ ! -d "$VENV_DIR" ]; then
  python3 -m venv "$VENV_DIR"
fi

# 2️⃣ Activate the virtual environment
source "$VENV_DIR/bin/activate"

# 3️⃣ Upgrade pip and install onnx
pip install --upgrade pip > /dev/null
pip install --upgrade onnx > /dev/null

# 4️⃣ Run Python script to inspect model
python3 << EOF
import onnx
from onnx import mapping

m = onnx.load("$MODEL_PATH")

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
