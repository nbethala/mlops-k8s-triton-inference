High-Level: What GFD Does
Purpose: GFD runs as a DaemonSet on every GPU node.

Job: It detects GPU hardware and drivers (e.g., NVIDIA cards, MIG partitions) and applies node labels like nvidia.com/gpu.count=1 or nvidia.com/mig-1g.5gb=2.

Impact: These labels are what Kubernetes uses for scheduling GPU workloads. Without GFD, pods can’t reliably request GPUs.

🔑 The 20% You Need
Install: Deploy the official NVIDIA GFD DaemonSet YAML (usually from NVIDIA/k8s-device-plugin repo).

Labels: Verify nodes get GPU-related labels (kubectl get nodes --show-labels | grep nvidia).

Scheduling: Pods request GPUs via resources.requests: nvidia.com/gpu: 1.

Lifecycle: GFD updates labels dynamically if GPUs change (e.g., MIG reconfig).

Dependency: GFD complements the NVIDIA device plugin (which actually allocates GPUs to pods). GFD just labels.

📊 80% Results Checklist
DaemonSet running: kubectl get ds -n kube-system | grep gpu-feature-discovery

Labels present: kubectl describe node | grep nvidia.com

Pod manifest GPU request:

yaml
resources:
  limits:
    nvidia.com/gpu: 1
Scheduler matches labels → Pod lands on GPU node.

🚀 Bottom Line
Think of GFD as the “GPU inventory clerk”:

It tags nodes with what GPUs they have.

The scheduler uses those tags to place GPU workloads.

Without it, GPU requests are blind.

### ===============================================
# Nvidia device plugin MPS control daemon
# ==================================================
The NVIDIA device plugin MPS control daemon is a Kubernetes component that manages CUDA Multi-Process Service (MPS), enabling multiple containers to share a single GPU more efficiently. Think of it as the traffic controller that partitions GPU compute and memory resources so workloads can run side-by-side without stepping on each other.

🎯 20% You Need to Learn
MPS = Multi-Process Service: A CUDA feature that allows multiple processes to share one GPU concurrently.

Control Daemon: Runs inside Kubernetes as part of the NVIDIA device plugin, managing GPU sharing policies.

Difference from Time-Slicing: Instead of alternating workloads (time-slicing), MPS partitions GPU resources explicitly, giving each workload a slice of compute/memory.

Deployment: Comes bundled with the NVIDIA device plugin DaemonSet; you don’t usually install it separately.

📊 80% of Practical Info
Why it matters:

Enables GPU sharing across pods, improving utilization.

Useful for small inference workloads that don’t need a full GPU.

Reduces idle GPU time by running multiple jobs simultaneously.

How it works in Kubernetes:

The daemon runs alongside the device plugin.

It exposes environment variables (CUDA_MPS_*) to containers.

It enforces resource limits per workload (e.g., memory slices).

Scheduler still uses node labels (from GFD), but MPS ensures fair GPU usage inside the node.

Operational Notes:

You’ll see it as nvidia-device-plugin-mps-control-daemon in kube-system.

It manages the nvidia-cuda-mps-server process under the hood.

You can check status with ps -ef | grep mps or via logs.

Shutting it down stops GPU sharing; pods then require full GPU allocation.

⚠️ Trade-offs & Risks
Performance isolation: MPS partitions resources but doesn’t guarantee strict isolation — workloads can still contend.

Compatibility: Best for CUDA-based inference; not ideal for heavy training jobs.

Complexity: Adds another moving part; debugging GPU scheduling can be trickier.

🚀 Bottom Line
The MPS control daemon is the GPU sharing manager in Kubernetes. It’s what lets you run multiple lightweight GPU workloads on the same node efficiently, instead of wasting a full GPU per pod.

Nancy, since you’re architecting teardown-ready GPU clusters, this daemon is key if you want multi-tenant GPU scheduling without overprovisioning.
