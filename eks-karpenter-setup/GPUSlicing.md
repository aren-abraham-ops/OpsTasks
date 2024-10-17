
# GPU Slicing on EKS with Karpenter Autoscaler

## Overview
This guide explains how to enable GPU Slicing on Amazon EKS using NVIDIA Multi-Instance GPU (MIG) capabilities. It also covers how to integrate GPU Slicing with the Karpenter Autoscaler for optimal resource utilization and cost efficiency.

## Prerequisites
- **NVIDIA A100 GPUs** on EC2 instances (e.g., `p4d`, `p4de` instance types).
- **EKS cluster** running Kubernetes **version 1.21+**.
- **NVIDIA driver** and **CUDA libraries** compatible with MIG.

## Step 1: Enable MIG Mode on GPU Instances
1. SSH into your GPU-enabled EC2 instance.
2. Enable MIG mode using `nvidia-smi`:
   ```bash
   nvidia-smi -i 0 -mig 1
   ```
3. Create MIG devices by specifying the desired profile (e.g., `1g.5gb` for 1 GPU slice with 5 GB memory):
   ```bash
   nvidia-smi mig -cgi 19 -C
   ```
4. Verify the MIG configuration:
   ```bash
   nvidia-smi mig -l
   ```

## Step 2: Deploy NVIDIA Device Plugin with MIG Support
1. Deploy the NVIDIA device plugin as a DaemonSet with MIG support enabled:
   ```yaml
   apiVersion: apps/v1
   kind: DaemonSet
   metadata:
     name: nvidia-device-plugin-daemonset
     namespace: kube-system
   spec:
     selector:
       matchLabels:
         name: nvidia-device-plugin-ds
     template:
       metadata:
         labels:
           name: nvidia-device-plugin-ds
       spec:
         containers:
           - image: nvidia/k8s-device-plugin:latest
             name: nvidia-device-plugin-ctr
             env:
               - name: NVIDIA_MIG_ENABLE
                 value: "true"
   ```

2. Apply the manifest:
   ```bash
   kubectl apply -f nvidia-device-plugin.yaml
   ```

## Step 3: Use GPU Slices in Kubernetes Pods
To use specific MIG profiles in your pods, modify the resource requests in the pod specification:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mig-pod
spec:
  containers:
  - name: ai-workload
    image: your-ai-image:latest
    resources:
      limits:
        nvidia.com/mig-1g.5gb: 1  # Replace with the profile you set up
```

## Step 4: Configure Karpenter for GPU Slicing
1. Create a `Provisioner` in Karpenter to support MIG instances:
   ```yaml
   apiVersion: karpenter.sh/v1alpha5
   kind: Provisioner
   metadata:
     name: gpu-provisioner
   spec:
     requirements:
       - key: nvidia.com/mig-1g.5gb
         operator: Exists
     limits:
       resources:
         nvidia.com/gpu: 1  # Adjust as needed
   ```

2. Apply the `Provisioner`:
   ```bash
   kubectl apply -f gpu-provisioner.yaml
   ```

## Step 5: Scale GPU Instances with Karpenter
Karpenter will automatically scale the GPU-enabled instances based on the workload demands, choosing the appropriate instance type and GPU slices. This ensures optimal usage of GPU resources, minimizing underutilization and reducing costs.

## Summary
By following this guide, you can:
- Enable GPU slicing using NVIDIA's MIG capabilities.
- Deploy GPU slices in Kubernetes pods.
- Leverage Karpenter to autoscale GPU instances with slicing support, ensuring cost-effective resource usage for GPU-intensive AI workloads.
