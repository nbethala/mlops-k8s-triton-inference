dev-ec2-->docker run -it --rm 478253497479.dkr.ecr.us-east-1.amazonaws.com/triton:24.01-py3 bash
which tritonserver

=============================
== Triton Inference Server ==
=============================

NVIDIA Release 24.01 (build 80100513)
Triton Server Version 2.42.0

Copyright (c) 2018-2023, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

Various files include modifications (c) NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

This container image and its contents are governed by the NVIDIA Deep Learning Container License.
By pulling and using the container, you accept the terms and conditions of this license:
https://developer.nvidia.com/ngc/nvidia-deep-learning-container-license

WARNING: The NVIDIA Driver was not detected.  GPU functionality will not be available.
   Use the NVIDIA Container Toolkit to start this container with GPU support; see
   https://docs.nvidia.com/datacenter/cloud-native/ .

root@618457c7aaa8:/opt/tritonserver# ls -l
total 2984
-rw-rw-rw-  1 triton-server triton-server    1485 Jan 18  2024 LICENSE
-rw-rw-r--  1 triton-server triton-server 3012640 Jan 18  2024 NVIDIA_Deep_Learning_Container_License.pdf
-rw-rw-rw-  1 triton-server triton-server       7 Jan 18  2024 TRITON_VERSION
drwxrwxrwx 13 triton-server triton-server    4096 Jan 18  2024 backends
drwxrwxrwx  2 triton-server triton-server    4096 Jan 18  2024 bin
drwxrwxrwx  4 triton-server triton-server    4096 Jan 18  2024 caches
drwxrwxrwx  3 triton-server triton-server    4096 Jan 18  2024 include
drwxrwxrwx  2 triton-server triton-server    4096 Jan 18  2024 lib
drwxrwxrwx  2 triton-server triton-server    4096 Jan 18  2024 python
drwxrwxrwx  3 triton-server triton-server    4096 Jan 18  2024 repoagents
drwxrwxrwx  2 triton-server triton-server    4096 Jan 18  2024 third-party-src
root@618457c7aaa8:/opt/tritonserver# pwd
/opt/tritonserver
root@618457c7aaa8:/opt/tritonserver# 

nside the container:

/opt/tritonserver


Contains:

backends/ → all model backends (onnxruntime, pytorch, tensorflow)

bin/ → contains tritonserver binary
(run /opt/tritonserver/bin/tritonserver)

python/ → Python backend

No models/ directory — correct.

This means your Triton container is fully intact.

⚠️ The warning “NVIDIA Driver was not detected” is expected because you didn’t run with GPUs.

You must start Triton on your GPU EC2 node like:
docker run -it --rm --gpus all \
  -p8000:8000 -p8001:8001 -p8002:8002 \
  -v /mnt/nfs/models:/models \
  nvcr.io/nvidia/tritonserver:24.01-py3 \
  tritonserver --model-repository=/models

