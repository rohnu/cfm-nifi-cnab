FROM alpine:3.18

# Install basic tools
RUN apk add --no-cache bash curl openssl

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/

# Install helm
RUN curl -LO https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz && \
    tar -zxvf helm-v3.14.4-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf helm-v3.14.4-linux-amd64.tar.gz linux-amd64

# (Optional) Add a non-root user
RUN adduser -D -u 65532 -G root nonroot

# Copy CNAB scripts
COPY app.sh /cnab/app/run
COPY ca-cluster-issuer.yaml /cnab/app/ca-cluster-issuer.yaml
COPY nifi-cr.yaml /cnab/app/nifi-cr.yaml

RUN chmod +x /cnab/app/run
RUN mkdir -p /cnab/app/outputs

CMD ["/cnab/app/run"]
