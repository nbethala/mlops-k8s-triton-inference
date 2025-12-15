🛠 TechSpec: Loki StatefulSet
Here’s a technical specification you can use as a baseline:

General
Kind: StatefulSet

Name: loki

Namespace: monitoring

Replicas: Typically 1 for dev, 3+ for HA clusters

Update Strategy: RollingUpdate

Pod Template
Containers:

Name: loki

Image: grafana/loki:<version> (e.g., grafana/loki:3.0.0)

Ports:

3100/TCP → Loki HTTP API

7946/TCP → Memberlist gossip (for clustering)

Args/Config:

Config file mounted at /etc/loki/config/config.yaml

Run mode: single binary (ingester, querier, distributor combined)

Resources:

CPU: request 100m, limit 500m

Memory: request 256Mi, limit 1Gi (tune for workload)

Storage
VolumeClaimTemplates:

Name: loki-data

AccessMode: ReadWriteOnce

StorageClass: gp2 (AWS) or cluster default

Size: 10Gi (dev), 100Gi+ (prod)

Services
ClusterIP Service: loki → exposes port 3100 inside cluster

Headless Service: loki-headless → enables pod DNS (loki-0.loki-headless.monitoring.svc.cluster.local)

Networking
Selectors: app=loki

DNS: Pods discover each other via loki-headless

RBAC
ServiceAccount: loki

Roles: read/write ConfigMaps, PVCs, endpoints

✅ Bottom Line
Loki uses a StatefulSet because it needs stable pod identities and persistent volumes.

The StatefulSet ensures ordered rollout and reliable storage for logs.

Key ports: 3100 (API), 7946 (gossip).

Headless service is critical for pod discovery in clustered mode.

Verify : service exists 

```

dev-->kubectl get endpointslices -n monitoring | grep loki 
loki-2fcwj                                      IPv4          3100             10.0.1.133   97m
loki-headless-bcxwc                             IPv4          3100             10.0.1.133   97m
loki-lb-mqks5                                   IPv4          3100             10.0.1.133   80m
loki-memberlist-m72dg                           IPv4          7946             10.0.1.133   97m
dev-->

```
