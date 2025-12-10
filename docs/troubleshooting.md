# Issue : GFD ( GPU Feature discovery ) 
Pods Not scheduing for GPU workloads

Solution : Via helm update/add the GFD. 

Test a Pod :  The pod should show scheduled - nvidia.com/gpu     1           1

```        

dev-ec2-->kubectl run nvidia-test --rm -it --restart=Never   --image=nvidia/cuda:13.0-base   --overrides='
{
  "apiVersion": "v1",
  "spec": {
    "containers": [{
      "name": "nvidia-test",
      "image": "nvidia/cuda:13.0-base",
      "command": ["nvidia-smi"],
      "resources": {
        "limits": {
          "nvidia.com/gpu": 1
        }
      }
    }]
  }
}' 
Error from server (AlreadyExists): pods "nvidia-test" already exists
dev-ec2-->kubectl describe node ip-10-0-1-199.ec2.internal | grep -A10 "Allocated resources:"
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests    Limits
  --------           --------    ------
  cpu                465m (11%)  0 (0%)
  memory             660Mi (4%)  5972Mi (39%)
  ephemeral-storage  0 (0%)      0 (0%)
  hugepages-1Gi      0 (0%)      0 (0%)
  hugepages-2Mi      0 (0%)      0 (0%)
  nvidia.com/gpu     1           1

```
