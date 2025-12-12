dev-->kubectl get pods -n inference -w
NAME                      READY   STATUS             RESTARTS   AGE
triton-76f6845487-h7db9   0/1     Pending            0          4h20m
triton-79569cfbbc-m2wcc   0/1     ImagePullBackOff   0          2m54s
^Cdev-->pwd
/home/ubuntu/mlops-k8s-triton-inference/services/triton
dev-->kubectl describe pod triton-79569cfbbc-m2wcc -n inference
Name:             triton-79569cfbbc-m2wcc
Namespace:        inference
Priority:         0
Service Account:  triton-sa
Node:             ip-10-0-1-149.ec2.internal/10.0.1.149
Start Time:       Fri, 12 Dec 2025 03:32:32 +0000
Labels:           app=triton
                  pod-template-hash=79569cfbbc
Annotations:      <none>
Status:           Pending
IP:               10.0.1.208
IPs:
  IP:           10.0.1.208
Controlled By:  ReplicaSet/triton-79569cfbbc
Init Containers:
  sync-models:
    Container ID:  containerd://46ca8942295c4af73208373bbb074c1cc77e3ccd5e2f512810e67cf9b75bd127
    Image:         amazon/aws-cli:latest
    Image ID:      docker.io/amazon/aws-cli@sha256:c6e58b7374789eee08785dde289217cc35a169432dbc87540597827d571705c0
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      echo 'sync models step placeholder'
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Fri, 12 Dec 2025 03:32:38 +0000
      Finished:     Fri, 12 Dec 2025 03:32:38 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /models from model-repo (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-qbh2p (ro)
Containers:
  triton:
    Container ID:   
    Image:          478253497479.dkr.ecr.us-east-1.amazonaws.com/triton:resnet50
    Image ID:       
    Ports:          8000/TCP (http), 8001/TCP (grpc), 8002/TCP (metrics)
    Host Ports:     0/TCP (http), 0/TCP (grpc), 0/TCP (metrics)
    State:          Waiting
      Reason:       ImagePullBackOff
    Ready:          False
    Restart Count:  0
    Limits:
      cpu:                3
      ephemeral-storage:  18Gi
      memory:             12Gi
      nvidia.com/gpu:     1
    Requests:
      cpu:                2
      ephemeral-storage:  15Gi
      memory:             8Gi
      nvidia.com/gpu:     1
    Environment:          <none>
    Mounts:
      /models from model-repo (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-qbh2p (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       False 
  ContainersReady             False 
  PodScheduled                True 
Volumes:
  model-repo:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  triton-models-pvc
    ReadOnly:   false
  kube-api-access-qbh2p:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              accelerator=nvidia
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
                             nvidia.com/gpu:NoSchedule op=Exists
Events:
  Type     Reason     Age                  From               Message
  ----     ------     ----                 ----               -------
  Normal   Scheduled  3m9s                 default-scheduler  Successfully assigned inference/triton-79569cfbbc-m2wcc to ip-10-0-1-149.ec2.internal
  Normal   Pulling    3m8s                 kubelet            Pulling image "amazon/aws-cli:latest"
  Normal   Pulled     3m3s                 kubelet            Successfully pulled image "amazon/aws-cli:latest" in 5.419s (5.419s including waiting). Image size: 128976715 bytes.
  Normal   Created    3m3s                 kubelet            Created container: sync-models
  Normal   Started    3m3s                 kubelet            Started container sync-models
  Warning  Failed     61s                  kubelet            Failed to pull image "478253497479.dkr.ecr.us-east-1.amazonaws.com/triton:resnet50": failed to pull and unpack image "478253497479.dkr.ecr.us-east-1.amazonaws.com/triton:resnet50": failed to extract layer (application/vnd.oci.image.layer.v1.tar+gzip sha256:573e602e6564cb45ecb9743e909c510eec7a78e6db1a3a1a7c343c091705bce1) to overlayfs as "extract-871885561-oknc sha256:85b8e878ad28f1bea36973f8a98ff4df41b8cf62db7583f9edce5fca0b9e582f": write /var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/360/fs/opt/nvidia/nsight-compute/2023.3.1/docs/pdf/NsightCompute.pdf: no space left on device
  Warning  Failed     61s                  kubelet            Error: ErrImagePull
  Normal   BackOff    60s                  kubelet            Back-off pulling image "478253497479.dkr.ecr.us-east-1.amazonaws.com/triton:resnet50"
  Warning  Failed     60s                  kubelet            Error: ImagePullBackOff
  Normal   Pulling    50s (x2 over 2m59s)  kubelet            Pulling image "478253497479.dkr.ecr.us-east-1.amazonaws.com/triton:resnet50"
dev-->
