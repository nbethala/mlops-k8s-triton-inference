
Issue : ReplicaSet no scheduling pods - Deployment Issue - ReplicaSet is failing at creation time, not scheduling.  
========================================================
# PVC status
kubectl get pvc -n inference
kubectl describe pvc triton-models-pvc -n inference

# Node labels and GPU resources
kubectl get nodes --show-labels
kubectl describe node <node-name> | grep -A5 "Allocatable"

# Events at ReplicaSet level
kubectl describe rs triton-5fc797b8f8 -n inference

# Check the pod description for events 
kubectl get pods -n inference
kubectl describe rs -n inference

