# 🌐 Cloudera CFM NiFi on AKS with CNAB (Duffle)

This guide provides a complete workflow for deploying **Cloudera Flow Management (CFM) NiFi** on **Azure Kubernetes Service (AKS)** using the **CNAB** packaging format via **Duffle**.

---

## 📋 Prerequisites
- Azure CLI installed
- Valid Cloudera license file
- Cloudera Docker registry credentials (username/password)
- macOS system with:
  - Docker
  - Helm 3
  - kubectl
  - duffle

---

## ☁️ Step 1: Create an AKS Cluster

az login
az account set --subscription <your-subscription-id>

az aks create
--resource-group myResourceGroup
--name myAKSCluster
--node-count 1
--enable-addons monitoring
--generate-ssh-keys

az aks get-credentials
--resource-group myResourceGroup
--name myAKSCluster


---

## 🧰 Step 2: Install Duffle and Initialize


brew install duffle
duffle init

Creates:
- `~/.duffle/bundles`
- `~/.duffle/credentials`
- `~/.duffle/claims`

---

## 📦 Step 3: Prepare CNAB Bundle
Bundle structure:
├── cfm-operator-k8s/duffle.json
├── cnab/Dockerfile
├── cnab/app.sh
├── cnab/ca-cluster-issuer.yaml
├── cnab/nifi-cr.yaml

Build the bundle:

duffle build

**Output:** `Successfully built bundle cfm-nifi:1.0.0`

---

## 🔐 Step 4: Create Duffle Credentials
Generate credentials:

Option 1: 

duffle creds generate kube-creds cfm-nifi:1.0.0

? Choose a source for "kubeconfig" file path
? Enter a value for "kubeconfig"  /Users/rohnu/.kube/config
? Choose a source for "licenseFile" file path
? Enter a value for "licenseFile" /Users/rohnu/Downloads/cloudera_license.txt
? Choose a source for "nifiPass" environment variable
? Enter a value for "nifiPass" NIFI_PASS
? Choose a source for "nifiUser" environment variable
? Enter a value for "nifiUser" NIFI_USER
? Choose a source for "registryPass" environment variable
? Enter a value for "registryPass" REGISTRY_PASS
? Choose a source for "registryUser" environment variable
? Enter a value for "registryUser" REGISTRY_USER
hw14039:cfm-kuberenetes-operator rganeshbabu$


Option2
duffle creds generate kube-creds -f ~/.duffle/bundles/db1d0de9a18e09b71d98feedbb46f233b578c5fd 
? Choose a source for "kubeconfig" file path
? Enter a value for "kubeconfig" /Users/rohnu/.kube/config
? Choose a source for "licenseFile" file path
? Enter a value for "licenseFile" /Users/rohnu/Downloads/cloudera_license.txtramprasad_ohnu_ganeshbabu_2025_2026_cloudera_license.txt
? Choose a source for "nifiPass" environment variable
? Enter a value for "nifiPass" NIFI_PASS
? Choose a source for "nifiUser" environment variable
? Enter a value for "nifiUser" NIFI_USER
? Choose a source for "registryPass" environment variable
? Enter a value for "registryPass" REGISTRY_PASS
? Choose a source for "registryUser" environment variable
? Enter a value for "registryUser" REGISTRY_USER

Option 3
                                      
kube-creds vi /Users/rohnu/.duffle/credentials/kube-creds.yaml
hw14039:azure_cnab rganeshbabu$ cat /Users/rganeshbabu/.duffle/credentials/kube-creds.yaml
name: kube-creds
credentials:
- name: kubeconfig
  source:
    value: /Users/rohnu/.kube/config
- name: licenseFile
  source:
    value: /Users/rohnu/Downloads/cloudera_license.txtramprasad_ohnu_ganeshbabu_2025_2026_cloudera_license.txt
- name: nifiPass
  source:
    env: NIFI_PASS
- name: nifiUser
  source:
    env: NIFI_USER
- name: registryPass
  source:
    env: REGISTRY_PASS
- name: registryUser
  source:
    env: REGISTRY_USER



