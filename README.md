# Cloudera Flow Management (CFM) NiFi Deployment via CNAB Bundle

This repository provides a complete guide to deploying Cloudera Flow Management (CFM) NiFi on a Kubernetes cluster (e.g., AKS) using CNAB (Cloud-Native Application Bundles) with Duffle.

---

## ☁ Step 1: Create Kubernetes Cluster (AKS Example)

```bash
az login
az account set --subscription <your-subscription-id>
az aks get-credentials --resource-group <your-rg> --name <your-aks-cluster>
```

---

## 🧰 Step 2: Install Duffle and Initialize

```bash
brew install duffle
duffle init
```

This creates:

- `~/.duffle/bundles`
- `~/.duffle/credentials`
- `~/.duffle/claims`

---

## 📦 Step 3: Prepare CNAB Bundle

Your project folder should include:

```plaintext
.
├── Dockerfile
├── duffle.json
├── app.sh
├── ca-cluster-issuer.yaml
├── nifi-cr.yaml
```

Build the bundle:

```bash
duffle build
```

Expected output:

```plaintext
Successfully built bundle cfm-nifi:1.0.0
```

---

## 🔐 Step 4: Create Duffle Credentials

### Option 1: Using Bundle Name

```bash
duffle creds generate kube-creds cfm-nifi:1.0.0
```

Fill in values when prompted (kubeconfig path, license path, env vars).

### Option 2: Using Bundle Hash

```bash
duffle creds generate kube-creds -f ~/.duffle/bundles/<BUNDLE_HASH>
```

### Option 3: Manual Edit

Edit the file directly:

```bash
vi ~/.duffle/credentials/kube-creds.yaml
```

Example:

```yaml
name: kube-creds
credentials:
- name: kubeconfig
  source:
    value: /Users/<user>/.kube/config
- name: licenseFile
  source:
    value: /Users/<user>/Downloads/cloudera_license.txt
- name: nifiUser
  source:
    env: NIFI_USER
- name: nifiPass
  source:
    env: NIFI_PASS
- name: registryUser
  source:
    env: REGISTRY_USER
- name: registryPass
  source:
    env: REGISTRY_PASS
```

---

## 🔧 Step 5: Set Required Environment Variables

```bash
export REGISTRY_USER="<cloudera-username>"
export REGISTRY_PASS="<cloudera-password>"
export NIFI_USER=admin
export NIFI_PASS=yourSecurePassword
```

---

## 🚀 Step 6: Install the CNAB Bundle

```bash
duffle install cfm-nifi cfm-nifi:1.0.0 \
  -c kube-creds \
  --set replicas=3
```

This runs `app.sh` which:

- Installs cert-manager via Helm
- Creates docker registry and license secrets
- Installs CFM Kubernetes Operator
- Creates TLS cert and ClusterIssuer
- Deploys NiFi Custom Resource
- Extracts NiFi LoadBalancer IP

---

## ⏳ Step 7: Wait for NiFi Service to Become Available

You will see this output like below.

```bash
[INFO] NiFi service not ready, waiting 10s...
[INFO] NiFi is accessible at:
https://4.255.110.167:8443
```

```bash
kubectl get svc mynifi-web -n my-nifi -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null; do

```

---

## 📋 Step 8: Validate the Deployment

```bash
kubectl get pods -n my-nifi
kubectl get svc -n my-nifi
```

Access NiFi:

```url
https://<external-ip>:8443
```

Login:

- **Username**: `${NIFI_USER}`
- **Password**: `${NIFI_PASS}`

---

## 🧹 Step 9: Uninstall (Optional)

```bash
duffle uninstall cfm-nifi
```

If uninstall fails, delete manually:

```bash
helm uninstall cfm-operator -n cfm-operator-system
kubectl delete ns my-nifi cfm-operator-system cert-manager
```

---

## 📁 Project Structure

```plaintext
.
├── Dockerfile
├── app.sh
├── duffle.json
├── ca-cluster-issuer.yaml
├── nifi-cr.yaml
```

---

## ✅ Notes

- This bundle is ideal for controlled or air-gapped environments.
- Update `cfmctl` support in `app.sh` as needed.
- If you hit errors, verify webhook readiness and cluster DNS.

---

## 📄 License

A valid Cloudera license is required to deploy this solution.

---

Feel free to fork, modify, or raise issues as needed! Contributions welcome.

