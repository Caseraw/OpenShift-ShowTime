FROM fedora:41

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

# OpenShift / Kubernetes tooling versions (override at build time if needed)
ARG HELM_VERSION=v3.17.3
ARG KUSTOMIZE_VERSION=v5.6.0

RUN dnf -y install dnf-plugins-core \
    && dnf -y update \
    && dnf -y install \
        ansible-core \
        bash-completion \
        curl \
        git \
        gzip \
        jq \
        openssl \
        podman \
        python3-pip \
        python3-devel \
        tar \
        vim-minimal \
        which \
        openshift-clients \
    && dnf clean all

# Helm and Kustomize (not always packaged at the versions we want on Fedora)
RUN curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" \
        | tar -xz -C /usr/local/bin --strip-components=1 linux-amd64/helm \
    && curl -fsSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" \
        | tar -xz -C /usr/local/bin kustomize \
    && chmod +x /usr/local/bin/helm /usr/local/bin/kustomize

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd -s /bin/bash --uid "${USER_UID}" --gid "${USER_GID}" -m "${USERNAME}" \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/"${USERNAME}" \
    && chmod 0440 /etc/sudoers.d/"${USERNAME}"

USER ${USERNAME}
WORKDIR /home/${USERNAME}

RUN pip install --user mkdocs-material

ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"

WORKDIR /workspaces/OpenShift-ShowTime
