# syntax=docker/dockerfile:1

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.5

ARG HELM_VERSION="3.20.2"
ARG OC_VERSION="stable-4.17"

LABEL org.opencontainers.image.title="ubi9-openshift-cicd"
LABEL org.opencontainers.image.description="RHEL UBI 9 CI/CD image with oc, kubectl, helm, git, jq, yq"
LABEL org.opencontainers.image.base.name="registry.access.redhat.com/ubi9/ubi-minimal:9.5"

ENV HOME=/home/ci \
    XDG_CACHE_HOME=/tmp/.cache \
    XDG_CONFIG_HOME=/tmp/.config \
    HELM_CACHE_HOME=/tmp/.cache/helm \
    HELM_CONFIG_HOME=/tmp/.config/helm \
    HELM_DATA_HOME=/tmp/.local/share/helm \
    KUBECONFIG=/tmp/kubeconfig \
    PATH="/usr/local/bin:${PATH}"

USER 0

RUN microdnf update -y && \
    microdnf install -y \
      bash \
      ca-certificates \
      findutils \
      git \
      gzip \
      jq \
      openssl \
      tar \
      unzip \
      shadow-utils \
      which && \
    microdnf clean all && \
    rm -rf /var/cache/dnf /var/cache/yum

# Install Helm
RUN set -eux; \
    ARCH="$(uname -m)"; \
    case "${ARCH}" in \
      x86_64) HELM_ARCH="amd64" ;; \
      aarch64) HELM_ARCH="arm64" ;; \
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/helm.tar.gz \
      "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${HELM_ARCH}.tar.gz"; \
    tar -xzf /tmp/helm.tar.gz -C /tmp; \
    mv "/tmp/linux-${HELM_ARCH}/helm" /usr/local/bin/helm; \
    chmod 0755 /usr/local/bin/helm; \
    rm -rf /tmp/helm.tar.gz "/tmp/linux-${HELM_ARCH}"

# Install oc and kubectl from OpenShift mirror
RUN set -eux; \
    ARCH="$(uname -m)"; \
    case "${ARCH}" in \
      x86_64) OC_ARCH="linux" ;; \
      aarch64) OC_ARCH="linux-arm64" ;; \
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/oc.tar.gz \
      "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_VERSION}/openshift-client-${OC_ARCH}.tar.gz"; \
    tar -xzf /tmp/oc.tar.gz -C /tmp oc kubectl; \
    mv /tmp/oc /usr/local/bin/oc; \
    mv /tmp/kubectl /usr/local/bin/kubectl; \
    chmod 0755 /usr/local/bin/oc /usr/local/bin/kubectl; \
    rm -f /tmp/oc.tar.gz

# Install yq
RUN set -eux; \
    ARCH="$(uname -m)"; \
    case "${ARCH}" in \
      x86_64) YQ_ARCH="amd64" ;; \
      aarch64) YQ_ARCH="arm64" ;; \
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /usr/local/bin/yq \
      "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${YQ_ARCH}"; \
    chmod 0755 /usr/local/bin/yq

# Create non-root CI user
RUN useradd \
      --uid 1001 \
      --gid 0 \
      --home-dir /home/ci \
      --create-home \
      --shell /bin/bash \
      ci && \
    mkdir -p \
      /home/ci \
      /tmp/.cache \
      /tmp/.config \
      /tmp/.local/share/helm && \
    chown -R 1001:0 /home/ci /tmp/.cache /tmp/.config /tmp/.local && \
    chmod -R g=u /home/ci /tmp/.cache /tmp/.config /tmp/.local

USER 1001

WORKDIR /workspace

RUN helm version --client && \
    oc version --client && \
    kubectl version --client=true && \
    jq --version && \
    yq --version

CMD ["/bin/bash"]
