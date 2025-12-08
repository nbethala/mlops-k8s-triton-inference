# mlops-k8s-triton-inference
GPU-enabled Triton inference pipelines on Kubernetes/EKS.

Goal: Build, test, deploy, and teardown a cost-aware GPU inference stack on EKS.

🧩 The Business Problem
Modern AI workloads — especially those involving deep learning, large language models, or computer vision — require:

GPU acceleration for training and inference
Scalable orchestration of containerized workloads
Multi-tenant isolation and secure access control
Cost-aware scheduling and resource lifecycle hygiene
Reproducibility across environments (dev, staging, prod)
Observability and compliance for regulated industries
But most enterprises struggle with:
Ad hoc GPU provisioning (manual, error-prone, expensive)
Poor reproducibility of ML pipelines
Lack of infrastructure-as-code for AI environments
Security gaps in IAM, CI/CD, and service-to-service trust
No clear disaster recovery or multi-region strategy

✅ The Solution: AI Infra GPU EKS Platform
Your platform solves this by delivering a modular, reproducible, GPU-ready Kubernetes environment on AWS, built with:

Layer   What It Solves
VPC + Subnets   Isolated, AZ-resilient network for GPU workloads
IAM + Policies  Fine-grained access for operators, CI/CD, and IRSA
EKS Cluster Managed Kubernetes control plane with GPU node groups
Node Groups Separate GPU and general-purpose pools for cost control
CI/CD Integration   GitHub OIDC + Terraform for secure automation  - " DEFFERED for now in phase 1 setup "
ALB Controller (IRSA)   Ingress with service account–scoped permissions
Observability (Planned) Hooks for Prometheus/Grafana, FluentBit, etc.
Disaster Recovery (Planned) Multi-region failover and backup scaffolding

 Summary
You're building a reproducible, secure, GPU-accelerated Kubernetes platform that enables teams to run AI/ML workloads at scale — with infrastructure-as-code, cost control, and compliance baked in.

This isn’t just a cluster — it’s a launchpad for AI workloads that need to be:

Scalable
Auditable
Cost-efficient
Secure by default
