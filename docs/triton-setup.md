The correct commands to force your pod to pick up "tritonserver":
cd helm
helm upgrade triton ./ -n inference -f values.yaml --force

Optional: delete old pod to be 100% sure
kubectl delete pod -n inference -l app=triton

Verify:
kubectl get pod -n inference -l app=triton \
  -o jsonpath='{.items[0].spec.containers[0].args}'


Expected output:

["tritonserver","--model-repository=/models","--model-control-mode=poll",...]


💡 Notes:

./ points to your local chart (helm/)

--force ensures the Deployment is replaced

Deleting the old pod guarantees Kubernetes starts fresh with the new spec

