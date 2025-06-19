# Cloudera Flow Management - Kubernetes Operator on Kubernetes

# Cloudera CFM NiFi Deployment on AKS using CNAB (Duffle)

This project demonstrates how to package and deploy Cloudera Flow Management (CFM) NiFi on an Azure Kubernetes Service (AKS) cluster using CNAB and [Duffle](https://github.com/deislabs/duffle).

---

## Prerequisites

- Azure CLI installed and authenticated
- AKS Cluster created
- `kubectl` configured
- `helm` installed
- `duffle` installed (`brew install duffle`)
- Cloudera credentials (for Docker registry and license)

---

##  1. Setup Azure Kubernetes Cluster (AKS)

```bash
az login
az account set --subscription <your-subscription-id>

# Create AKS cluster (adjust name and node count as needed)
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --node-count 1 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Get kubeconfig for kubectl
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster


This repository contains a [CNAB](https://cnab.io/) bundle to deploy **Cloudera Flow Management (NiFi)** on **Azure Kubernetes Service (AKS)** using [Duffle](https://github.com/deislabs/duffle).

---

##  2. Install Duffle and Initialize

```bash
brew install duffle
duffle init
