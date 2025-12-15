# Triton Inference Environment – Technical Snapshot

## System Context
- **Environment**: Amazon Linux EC2 (single GPU node)
- **Model**: ResNet50 (ONNX backend)
- **Deployment**: Triton Inference Server on Kubernetes
- **Storage**: Amazon EFS mounted to `/mnt/efs`
- **Batch Size Tested**: 32
- **Concurrency Range Tested**: 32

---

## Perf Analyzer Results (Batch=32, Concurrency=32)

- **Throughput**: ~416 inferences/sec
- **Client Latency**:
  - Average: ~2,454,927 µs (≈ 2.45 sec)
  - p50: ~2,448,110 µs
  - p90: ~2,603,333 µs
  - p95: ~2,694,142 µs
  - p99: ~2,919,564 µs
- **Server Latency Breakdown**:
  - Average request latency: ~2,145,196 µs
    - Overhead: ~208 µs
    - Queue: ~2,068,746 µs
    - Compute Input: ~4,918 µs
    - Compute Infer: ~71,173 µs
    - Compute Output: ~150 µs

---

## Prometheus / Grafana Metrics

- **GPU Utilization**  
  - Query: `DCGM_FI_DEV_GPU_UTIL{gpu="0"}`
  - Shows % of GPU cores active during inference.

- **GPU Memory Usage**  
  - Query: `DCGM_FI_DEV_FB_USED{gpu="0"}`
  - Shows MB of GPU memory allocated.

- **Throughput**  
  - Query: `rate(nv_inference_count[1m])`
  - Matches Perf Analyzer throughput (~416 infer/sec).

- **Average Latency**  
  - Query: `nv_inference_request_duration_us / nv_inference_count`
  - Aligns with Perf Analyzer averages (~2.4 sec at batch=32).

---

## Observations

- **Queue Time Dominates**: Most latency comes from waiting for batch accumulation, not GPU compute.
- **GPU Compute Efficient**: Actual infer time per batch is ~71 ms, showing GPU is fast once requests are batched.
- **Recruiter Snapshot Ready**: Metrics demonstrate end-to-end GPU inference pipeline with throughput, latency, utilization, and memory panels populated.
- **Scaling Limit**: With one GPU and one model, this is the ceiling of observable performance.

---

## Future Scope – Parallelism

- **Multi-Model Parallelism**  
  - Add ResNet18, EfficientNet, or other ONNX models alongside ResNet50.  
  - Demonstrates Triton’s ability to schedule multiple models concurrently on the same GPU.  
  - Provides richer Grafana panels showing per-model throughput and latency.

- **Multi-GPU Parallelism**  
  - Provision additional GPU nodes in the cluster.  
  - Triton can distribute inference requests across GPUs (`instance_group { kind: KIND_GPU count: N }`).  
  - Enables horizontal scaling, higher throughput, and balanced utilization.

- **Dynamic Batching Across Models**  
  - Configure `preferred_batch_size` for each model.  
  - Triton merges requests opportunistically, reducing queue time while keeping GPUs busy.

---

## Bottom Line
This setup provides a **complete, reproducible tech spec**:
- Single ResNet50 model on Triton
- Batch size 32, concurrency 32
- Throughput ~416 infer/sec
- Latency ~2.4 sec (queue-heavy)
- GPU utilization and memory metrics visible in Grafana

**Future scope**: Parallelism via multi-model and multi-GPU deployments will unlock higher throughput, balanced utilization  evidence of scalable AI/ML infrastructure.
