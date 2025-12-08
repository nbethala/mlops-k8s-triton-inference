#python script to run real inference request
from tritonclient.http import InferenceServerClient, InferInput
import numpy as np

client = InferenceServerClient("localhost:8000")

# Fake image data (batch=1, 3x224x224)
input_data = np.random.random((1,3,224,224)).astype(np.float32)

inp = InferInput("data", input_data.shape, "FP32")
inp.set_data_from_numpy(input_data)

output = client.infer("resnet50", inputs=[inp])
print(output.get_response())

