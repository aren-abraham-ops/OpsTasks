# EKS Cluster Setup with Karpenter and Graviton using Terragrunt

## Overview
This repository provides Terraform code and Terragrunt configuration to deploy an EKS cluster on AWS using the latest available version. The cluster integrates Karpenter for autoscaling, supporting both x86 and Graviton (ARM64) instances.

## Prerequisites
- Terraform v1.5.0+
- Terragrunt v0.50.0+
- AWS CLI configured with credentials
- Existing VPC with public and private subnets

## Setup and Deployment
1. **Clone the repository**:
   ```bash
   git clone https://github.com/aren-abraham-ops/OpsTasks/tree/main/eks-karpenter-setup/karpenter
   cd your-repo/terragrunt/dev
   ```

2. **Initialize Terragrunt**:
   ```bash
   terragrunt init
   ```

3. **Deploy the EKS cluster**:
   ```bash
   terragrunt apply
   ```

   This will provision the EKS cluster, Karpenter, and associated resources in the specified VPC.

## Running Workloads
To run a pod on a specific instance type, you can use `nodeSelector` or `affinity`:

### Example: Run a Pod on ARM64 (Graviton)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: arm64-pod
spec:
  containers:
  - name: nginx
    image: nginx
  nodeSelector:
    kubernetes.io/arch: arm64
```

### Example: Run a Pod on x86_64
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: x86-pod
spec:
  containers:
  - name: nginx
    image: nginx
  nodeSelector:
    kubernetes.io/arch: amd64
```

Deploy these manifests using:
```bash
kubectl apply -f arm64-pod.yaml
kubectl apply -f x86-pod.yaml
```

## Cleanup
To destroy the EKS cluster and associated resources:
```bash
terragrunt destroy
```
Ensure you run this command in the appropriate environment directory (`dev` or `prod`).

## Additional Notes
- Adjust the Terraform variables in `terragrunt.hcl` as needed for your setup.
- Refer to the `karpenter.tf` file for additional configuration options.
