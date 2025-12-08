resource "helm_release" "nvidia_device_plugin" {
  name       = "nvidia-device-plugin"
  namespace  = "kube-system"
  repository = "https://nvidia.github.io/k8s-device-plugin"
  chart      = "nvidia-device-plugin"
  version    = "0.17.1"

  values = [yamlencode({
    tolerations = [{
      key      = "gpu"
      operator = "Exists"
      effect   = "NoSchedule"
    }]
    nodeSelector = {
      accelerator = "nvidia"
    }
  })]
}
