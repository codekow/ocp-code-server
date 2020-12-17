FROM centos:8

### Atomic/OpenShift Labels - https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="custom-code-server" \
      maintainer="cory@happykow.com" \
      vendor="Coder" \
      version="3.7.2" \
      summary="Custom Code Server" \
      description="Custom Code Server base image with a basic collection of tools"

# bug: hadolint doesn't see user below
# hadolint ignore=DL3002
USER root

# Set shell for RUN commands to ensure consistent execution
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# fix: node CA trust defaults for requests / node
ENV REQUESTS_CA_BUNDLE=/etc/pki/tls/certs/ca-bundle.crt
ENV NODE_EXTRA_CA_CERTS=/etc/pki/tls/certs/ca-bundle.crt

# fix: path for local bin
ENV PATH=$PATH:/home/coder/.local/bin

WORKDIR /home/coder

# setup: basic home files
# COPY skel /etc/skel

# setup: entrypoint and other scripts over 
COPY bin /usr/local/bin

ARG CODE_SERVER_VERSION

RUN rpm -ivh https://github.com/cdr/code-server/releases/download/v${CODE_SERVER_VERSION:-3.7.2}/code-server-${CODE_SERVER_VERSION:-3.7.2}-amd64.rpm && \
    dnf update -y && \
    dnf install -y \
    nss_wrapper \
    curl gnupg wget \
    bind-utils traceroute \
    git gcc gcc-c++ cmake make \
    pkg-config \
    bash-completion rsync tree zsh zip unzip \
    krb5-workstation \
    tmux \
    nano vim jq && \
    dnf clean all && \
    chmod g+w /etc/passwd


# install tools needed to compile python
RUN dnf update -y && \
    dnf install groupinstall -y "Development Tools" && \
    dnf install openssl-devel bzip2-devel libffi-devel && \
    dnf clean all 

ARG PYTHON_36_VERSION=3.6.12
RUN curl -O https://www.python.org/ftp/python/${PYTHON_36_VERSION}/Python-${PYTHON_36_VERSION}.tar.xz && \
    tar -xf Python-${PYTHON_36_VERSION}.tar.xz && \
    cd Python-${PYTHON_36_VERSION} && \
    ./configure --enable-optimizations --enable-loadable-sqlite-extensions && \
    make -j $(nproc) && \
    make altinstall && \
    cd .. && rm -r Python-${PYTHON_36_VERSION}

ARG PYTHON_37_VERSION=3.7.9
RUN curl -O https://www.python.org/ftp/python/${PYTHON_37_VERSION}/Python-${PYTHON_37_VERSION}.tar.xz && \
    tar -xf Python-${PYTHON_37_VERSION}.tar.xz && \
    cd Python-${PYTHON_37_VERSION} && \
    ./configure --enable-optimizations --enable-loadable-sqlite-extensions && \
    make -j $(nproc) && \
    make altinstall && \
    cd .. && rm -r Python-${PYTHON_37_VERSION}

ARG PYTHON_38_VERSION=3.8.6
RUN curl -O https://www.python.org/ftp/python/${PYTHON_38_VERSION}/Python-${PYTHON_38_VERSION}.tar.xz && \
    tar -xf Python-${PYTHON_38_VERSION}.tar.xz && \
    cd Python-${PYTHON_38_VERSION} && \
    ./configure --enable-optimizations --enable-loadable-sqlite-extensions && \
    make -j $(nproc) && \
    make altinstall && \
    cd .. && rm -r Python-${PYTHON_38_VERSION}

ARG PYTHON_39_VERSION=3.9.1
RUN curl -O https://www.python.org/ftp/python/${PYTHON_39_VERSION}/Python-${PYTHON_39_VERSION}.tar.xz && \
    tar -xf Python-${PYTHON_39_VERSION}.tar.xz && \
    cd Python-${PYTHON_39_VERSION} && \
    ./configure --enable-optimizations --enable-loadable-sqlite-extensions && \
    make -j $(nproc) && \
    make altinstall && \
    cd .. && rm -r Python-${PYTHON_39_VERSION}

# fix: alias python / pip 
ARG PYTHON_DEFAULT=3.8
RUN rm /usr/local/bin/python; rm /usr/local/bin/pip; \
    ln -s /usr/local/bin/python${PYTHON_DEFAULT} /usr/local/bin/python && \
    ln -s /usr/local/bin/pip${PYTHON_DEFAULT} /usr/local/bin/pip

# install: oc
ARG OC3_VERSION="3.11.318"
ARG OC3_HASH="45051b28bba343b81ab279fbf670535cc92de7140dc8d73d00327ee04e6d666c"
ARG OC3_URL="https://mirror.openshift.com/pub/openshift-v3/clients/${OC3_VERSION}/linux/oc.tar.gz"

ARG OC4_VERSION="4.4"
ARG OC4_HASH="10118c55177200412a7740eae02b91ac9c0ffb1bb6e50c6fceef2f220ccd99db"
ARG OC4_URL="https://mirror.openshift.com/pub/openshift-v4/clients/oc/${OC4_VERSION}/linux/oc.tar.gz"

RUN curl -sL "${OC3_URL}" -o oc.tgz && \
    sha256sum < oc.tgz && \
    [ "$OC3_HASH  -" = "$(sha256sum < oc.tgz)" ] && \
    echo "OC3_HASH: PASSED" && \
    tar -C /usr/local/bin -zxf oc.tgz oc && \
    mv /usr/local/bin/oc /usr/local/bin/oc-${OC3_VERSION%.*} && \
    /usr/local/bin/oc-${OC3_VERSION%.*} completion bash > /etc/bash_completion.d/oc-${OC3_VERSION%.*} && \
    
    curl -sL "${OC4_URL}" -o oc.tgz && \
    sha256sum < oc.tgz && \
    [ "$OC4_HASH  -" = "$(sha256sum < oc.tgz)" ] && \
    echo "OC4_HASH: PASSED" && \
    tar -C /usr/local/bin -zxf oc.tgz oc && \
    mv /usr/local/bin/oc /usr/local/bin/oc-${OC4_VERSION} && \
    /usr/local/bin/oc-${OC4_VERSION} completion bash > /etc/bash_completion.d/oc-${OC4_VERSION} && \
    rm oc.tgz && \

    ln -s /usr/local/bin/oc-wrapper.sh /usr/local/bin/oc

# expose ports for local app / s2i
EXPOSE 1337 8000 8050 8080

WORKDIR /home/coder
USER 1001

VOLUME /home/coder

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["code-server", "--bind-addr", "0.0.0.0:1337", ".", "--disable-telemetry"]
