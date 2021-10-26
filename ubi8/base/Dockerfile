FROM registry.access.redhat.com/ubi8/ubi

### Atomic/OpenShift Labels - https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="custom-code-server" \
      maintainer="koree@redhat.com" \
      vendor="Coder" \
      version="3.12.0" \
      summary="Custom Code Server" \
      description="Custom Code Server base image with a basic collection of tools"

# bug: hadolint doesn't see user below
# hadolint ignore=DL3002
USER root

# Set shell for RUN commands to ensure consistent execution
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# fix: node CA trust defaults for requests / node
ENV REQUESTS_CA_BUNDLE=/etc/pki/tls/certs/ca-bundle.crt
#ENV NODE_EXTRA_CA_CERTS=/etc/pki/tls/certs/ca-bundle.crt

# fix: path for local bin
ENV PATH=$PATH:/home/coder/.local/bin

WORKDIR /home/coder

# setup: basic home files
COPY skel /etc/skel

# setup: entrypoint and other scripts over 
COPY bin /usr/local/bin

ARG CODE_SERVER_VERSION

RUN rpm -ivh https://github.com/cdr/code-server/releases/download/v${CODE_SERVER_VERSION:-3.12.0}/code-server-${CODE_SERVER_VERSION:-3.12.0}-amd64.rpm && \
    dnf update -y && \
    dnf install -y \
    nss_wrapper \
    curl gnupg wget \
    bind-utils \
    git gcc gcc-c++ cmake make \
    python3 python3-pip \
    pkg-config \
    bash-completion rsync zip unzip \
    krb5-workstation \
    nano vim jq && \
    dnf clean all && \
    chmod g+w /etc/passwd

# fix: alias python / pip 
RUN ln -s /usr/bin/python3 /usr/local/bin/python && \
    ln -s /usr/bin/pip3 /usr/local/bin/pip

# install: oc
ENV OC3_VERSION="3.11.374"
ARG OC3_HASH="1fb49e5548c649d8bab15ac4dca7a77225747b1957c2082f8e47ccbb9120356e"
ARG OC3_URL="https://mirror.openshift.com/pub/openshift-v3/clients/${OC3_VERSION}/linux/oc.tar.gz"

ENV OC4_VERSION="4.8.10"
ARG OC4_HASH="9d727adc9438bb7431344a7349ee88fbf05b5dbb856e678013a15c084b72cc9d"
ARG OC4_URL="https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OC4_VERSION}/openshift-client-linux.tar.gz"

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
    mv /usr/local/bin/oc /usr/local/bin/oc-${OC4_VERSION%.*} && \
    /usr/local/bin/oc-${OC4_VERSION%.*} completion bash > /etc/bash_completion.d/oc-${OC4_VERSION%.*} && \
    rm oc.tgz && \
    ln -s /usr/local/bin/oc-wrapper.sh /usr/local/bin/oc

# expose ports for local app / s2i
EXPOSE 1337 8000 8050 8080

WORKDIR /home/coder
USER 1001

VOLUME /home/coder

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["code-server", "--bind-addr", "0.0.0.0:1337", ".", "--disable-telemetry"]
