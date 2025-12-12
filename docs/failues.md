# Kubernetes Replicat-set Failure : 
=======================================

ec2-->kubectl get pods -n inference
No resources found in inference namespace.
ec2-->kubectl logs -n inference deploy/triton

error: timed out waiting for the condition
ec2-->
ec2-->kubectl get deploy triton -n inference
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
triton   0/1     0            0           2m47s
ec2-->kubectl describe deploy triton -n inference
Name:                   triton
Namespace:              inference
CreationTimestamp:      Thu, 11 Dec 2025 19:58:56 +0000
Labels:                 app=triton
                        app.kubernetes.io/managed-by=Helm
Annotations:            deployment.kubernetes.io/revision: 1
                        meta.helm.sh/release-name: triton
                        meta.helm.sh/release-namespace: inference
Selector:               app=triton
Replicas:               1 desired | 0 updated | 0 total | 0 available | 1 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:           app=triton
  Service Account:  triton-sa
  Init Containers:
   sync-models:
    Image:        amazon/aws-cli:2.16.19
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Containers:
   triton:
    Image:       478253497479.dkr.ecr.us-east-1.amazonaws.com/triton:resnet50
    Ports:       8000/TCP (http), 8001/TCP (grpc), 8002/TCP (metrics)
    Host Ports:  0/TCP (http), 0/TCP (grpc), 0/TCP (metrics)
    Limits:
      cpu:             4
      memory:          16Gi
      nvidia.com/gpu:  1
    Requests:
      cpu:        2
      memory:     8Gi
    Environment:  <none>
    Mounts:
      /models from model-repo (rw)
  Volumes:
   model-repo:
    Type:          PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:     triton-models-pvc
    ReadOnly:      false
  Node-Selectors:  accelerator=nvidia
  Tolerations:     nvidia.com/gpu:NoSchedule op=Exists
Conditions:
  Type             Status  Reason
  ----             ------  ------
  Progressing      True    NewReplicaSetCreated
  Available        False   MinimumReplicasUnavailable
  ReplicaFailure   True    FailedCreate
OldReplicaSets:    <none>
NewReplicaSet:     triton-5fc797b8f8 (0/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  3m2s  deployment-controller  Scaled up replica set triton-5fc797b8f8 from 0 to 1
ec2-->kubectl get pods -n inference
No resources found in inference namespace.
ec2-->
