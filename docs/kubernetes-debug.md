# Comprehensive Kubernetes Debug - commands used in the project for Triton Server Deployment
==============================================================================================

kubectl commands for diagnosing Triton pods, PVCs, mounts, permissions, device visibility, and node events. Each command is followed by a short explanation of what it does and what to look for.

```
Pod logs and exit reason
Get pod names for Triton

bash
kubectl get pods -n inference -l app=triton -o wide
What it does: Lists all Triton pods with status, node, restarts, and IP so you can pick the pod to inspect.

Show last run logs from a crashed container

bash
kubectl logs -n inference <pod-name> -c triton --previous --tail=200
What it does: Retrieves the stderr/stdout from the container’s previous run; look for error lines, stack traces, or immediate exit messages.

Show current logs from a pod

bash
kubectl logs -n inference <pod-name> -c triton --tail=200
What it does: Streams the most recent logs from the container; useful if the pod is still running or to compare with --previous.

Show container lastState and current state JSON

bash
kubectl get pod -n inference <pod-name> -o jsonpath='{.status.containerStatuses[?(@.name=="triton")].lastState}' | jq .
What it does: Prints the container lastState JSON including exitCode, reason, and message to identify why it exited.

Pod description and events
Describe pod to see events and lifecycle

bash
kubectl describe pod -n inference <pod-name> | sed -n '1,240p'
What it does: Shows pod spec, mounts, env, probes, and Events; check Events for scheduling, OOM, or probe failures.

Show recent namespace events sorted by time

bash
kubectl get events -n inference --sort-by='.lastTimestamp' | tail -n 50
What it does: Lists recent cluster events in the namespace; look for device plugin, PVC, or scheduling errors tied to pod timestamps.

PVC and volume checks
Show PVC status and basic info

bash
kubectl get pvc -n inference triton-models-pvc -o wide
What it does: Confirms whether the PVC is Bound and shows storage class, capacity, and access modes.

Describe PVC for detailed status and events

bash
kubectl describe pvc -n inference triton-models-pvc | sed -n '1,120p'
What it does: Shows PV binding, events, and any mount or access errors that would prevent the pod from seeing files.

List PVs and their claims

bash
kubectl get pv -o wide
What it does: Shows underlying PVs and reclaim policies; useful if PVC is not bound or is bound to an unexpected PV.

Inspect model files and permissions without exec into Triton
Create a debug pod manifest that mounts the same PVC

bash
cat <<'EOF' | kubectl apply -n inference -f -; kubectl wait --for=condition=Ready pod/triton-debug -n inference --timeout=60s
apiVersion: v1
kind: Pod
metadata:
  name: triton-debug
spec:
  restartPolicy: Never
  nodeSelector:
    accelerator: nvidia
  containers:
  - name: debug
    image: alpine
    command: ["/bin/sh","-c","sleep 1d"]
    volumeMounts:
    - name: model-repo
      mountPath: /models
  volumes:
  - name: model-repo
    persistentVolumeClaim:
      claimName: triton-models-pvc
EOF
What it does: Creates a stable debug pod on a GPU node that mounts the same PVC so you can inspect /models safely.

List files in the mounted model directory from the debug pod

bash
kubectl exec -n inference -it triton-debug -- sh -c "ls -la /models; find /models -maxdepth 3 -type d -print | head -n 50"
What it does: Shows directory listing and model directory structure; verify /models/<model>/1/... and presence of config.pbtxt.

Show ownership and permissions for models

bash
kubectl exec -n inference -it triton-debug -- sh -c "stat -c '%U:%G %a %n' /models /models/* 2>/dev/null || true; getfacl /models 2>/dev/null || true"
What it does: Prints owner, group, and mode for /models and model dirs; check that Triton’s runtime user can read and traverse directories.

GPU device and driver checks
Check for NVIDIA device nodes from debug pod

bash
kubectl exec -n inference -it triton-debug -- sh -c "ls -l /dev | grep nvidia || true"
What it does: Verifies /dev/nvidia* devices are visible inside a pod on the GPU node.

Check for nvidia-smi binary inside debug pod

bash
kubectl exec -n inference -it triton-debug -- sh -c "which nvidia-smi || ls -l /usr/bin/nvidia-smi /usr/local/bin/nvidia-smi 2>/dev/null || true"
What it does: Confirms whether nvidia-smi is present in the container image or mounted into the pod.

Check device plugin daemonset status

bash
kubectl get ds -n kube-system -o wide | grep -i nvidia || kubectl get pods -n kube-system -l 'app in (nvidia-device-plugin)' -o wide
What it does: Shows whether the NVIDIA device plugin daemonset is running on nodes; if missing, GPUs won’t be advertised.

View device plugin logs

bash
kubectl logs -n kube-system daemonset/nvidia-device-plugin-daemonset --tail=200 || kubectl logs -n kube-system -l name=nvidia-device-plugin --tail=200
What it does: Dumps recent device plugin logs to reveal registration or device mount errors.

Binary, library, and manual Triton run checks
Check for tritonserver binary path inside a pod using the same image

bash
kubectl run -n inference triton-run --rm -it --restart=Never --image=478253497479.dkr.ecr.us-east-1.amazonaws.com/triton:24.01-py3 -- sh -c "which tritonserver || ls -l /opt/tritonserver /opt/tritonserver/bin || true"
What it does: Starts a throwaway container from the Triton image to locate the tritonserver binary without touching the Deployment.

Run tritonserver manually with verbose logging from a throwaway container

bash
kubectl run -n inference triton-run --rm -it --restart=Never --image=478253497479.dkr.ecr.us-east-1.amazonaws.com/triton:24.01-py3 -- sh -c "/opt/tritonserver/bin/tritonserver --model-repository=/models --log-verbose=1 2>&1 | sed -n '1,200p'"
What it does: Runs Triton manually with verbose logs to reveal library load errors, config parse errors, or CUDA init failures.

Check shared library dependencies for tritonserver

bash
kubectl run -n inference triton-run --rm -it --restart=Never --image=478253497479.dkr.ecr.us-east-1.amazonaws.com/triton:24.01-py3 -- sh -c "ldd /opt/tritonserver/bin/tritonserver 2>/dev/null | sed -n '1,200p' || true"
What it does: Lists dynamic dependencies and any “not found” entries that indicate missing libraries.

Node and kubelet diagnostics
Describe the GPU node for capacity and conditions

bash
kubectl describe node <gpu-node-name> | sed -n '1,240p'
What it does: Shows node allocatable resources, labels, taints, and recent events; useful for scheduling and resource exhaustion clues.

Show recent kubelet logs on the node (requires node access)

bash
# run on the node or via your cloud provider console
sudo journalctl -u kubelet -n 200 --no-pager
What it does: Reveals node-level errors such as device plugin failures, cgroup denials, or OOM events that kill containers.

Cleanup and helper commands
Delete the debug pod when done

bash
kubectl delete pod -n inference triton-debug --ignore-not-found
What it does: Removes the debug pod to avoid consuming node resources.

Scale Triton deployment to a single replica

bash
kubectl scale deploy triton -n inference --replicas=1
What it does: Ensures only one Triton pod attempts to bind the GPU on a single‑GPU node.

Restart the deployment to pick up Helm changes

bash
kubectl rollout restart deploy triton -n inference
What it does: Triggers a rolling restart so new args/command/values are applied to pods.

```

How to use this list
Start with Pod logs and lastState to capture the exit reason.

If logs are inconclusive, create the triton-debug pod and inspect /models and device visibility.

If models exist but Triton still exits, run the manual tritonserver command in a throwaway container to reveal library or CUDA errors.

If scheduling is the issue, inspect node capacity, device plugin, and PVC binding.
