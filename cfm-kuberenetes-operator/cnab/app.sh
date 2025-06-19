#!/bin/bash
set -e

echo "[INFO] Step 1: Installing cert-manager"
helm repo add jetstack https://charts.jetstack.io --force-update
helm install cert-manager jetstack/cert-manager \
  --version v1.18.0 \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true

kubectl create ns cfm-operator-system || true

echo "[INFO] Step 2: Creating docker registry secret..."
kubectl create secret docker-registry docker-pull-secret \
  --namespace cfm-operator-system \
  --docker-server container.repository.cloudera.com \
  --docker-username ${REGISTRY_USER}  \
  --docker-password ${REGISTRY_PASS} || true

echo "[INFO] Step 3: Creating Cloudera License Secret"
kubectl create secret generic cfm-operator-license \
  --from-file=license.txt=/cnab/app/license.txt \
  -n cfm-operator-system || true

echo "[INFO] Step 4: cfmctl CLI Support (Optional for Runtime)"
#curl -o /usr/local/bin/cfmctl -L https://archive.cloudera.com/p/cfm-operator/cfmctl-linux-amd64
#chmod +x /usr/local/bin/cfmctl

echo "[INFO] Step 5: Installing CFM Operator"
helm install cfm-operator https://${REGISTRY_USER}:${REGISTRY_PASS}@archive.cloudera.com/p/cfm-operator/cfm-operator-2.10.0-b134.tgz  \
  --namespace cfm-operator-system \
  --set crds.enabled=true \
  --set image.repository=container.repository.cloudera.com/cloudera/cfm-operator \
  --set image.tag=2.10.0-b134 \
  --set licenseSecret=cfm-operator-license

echo "[INFO] Step 6: Creating NiFi Secrets and Namespace"
kubectl create namespace my-nifi || true

kubectl create secret docker-registry cloudera-container-repository-credentials \
  --namespace my-nifi \
  --docker-server container.repository.cloudera.com \
  --docker-username ${REGISTRY_USER} \
  --docker-password ${REGISTRY_PASS} || true

kubectl create secret generic nifi-cred-secret -n my-nifi \
  --from-literal=username=${NIFI_USER} \
  --from-literal=password=${NIFI_PASS} || true

echo "[INFO] Step 7: Generating TLS Cert"
openssl req -x509 -newkey rsa:2048 -days 365 -nodes \
  -keyout /cnab/app/ca.key -out /cnab/app/ca.crt \
  -subj "/CN=nifi-cluster-ca"

kubectl create secret tls nifi-cluster-ca \
  --cert=/cnab/app/ca.crt --key=/cnab/app/ca.key -n my-nifi || true

echo "[INFO] Step 8: Creating ClusterIssuer"
kubectl apply -f /cnab/app/ca-cluster-issuer.yaml -n my-nifi || true

echo "[INFO] Waiting for cfm-operator webhook to be ready..."

for i in {1..30}; do
  READY=$(kubectl get endpoints cfm-operator-webhook-service -n cfm-operator-system -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
  if [[ -n "$READY" ]]; then
    echo "[INFO] Webhook service is ready: $READY"
    break
  fi
  echo "[INFO] Waiting for webhook endpoint... ($i/30)"
  sleep 5
done

if [[ -z "$READY" ]]; then
  echo "[ERROR] Webhook did not become ready in time." >&2
  exit 1
fi

echo "[INFO] Step 9: Deploying NiFi CR"
kubectl apply -f /cnab/app/nifi-cr.yaml -n my-nifi || true

echo "[INFO] Step 10: Waiting for NiFi service 'mynifi-web' to be ready..."

# Wait until the service gets a LoadBalancer IP
while true; do
  IP=$(kubectl get svc mynifi-web -n my-nifi -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
  if [[ -n "$IP" ]]; then
    break
  fi
  echo "[INFO] NiFi service not ready, waiting 10s..."
  sleep 10
done

echo "[INFO] NiFi is accessible at:"
echo "https://${IP}:8443"
