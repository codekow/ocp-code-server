FROM codercom/code-server:3.11.1

### Atomic/OpenShift Labels - https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="custom-code-server" \
      maintainer="koree@redhat.com" \
      vendor="Coder" \
      version="3.11.1" \
      summary="Custom Code Server" \
      description="Custom Code Server base image with a basic collection of tools"

# bug: hadolint doesn't see user below
# hadolint ignore=DL3002
USER root

# Set shell for RUN commands to ensure consistent execution
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# fix: node CA trust defaults for requests / node
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
#ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

# fix: path for local bin
ENV PATH=$PATH:/home/coder/.local/bin

# setup: basic home files
COPY skel /etc/skel

# setup: entrypoint and other scripts over 
COPY bin /usr/local/bin

# non interactive install
ENV DEBIAN_FRONTEND=noninteractive

# install: updates, utils, and python
# hadolint ignore=DL3008 
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    libnss-wrapper \
    apt-transport-https lsb-release \
    curl gnupg wget \
    dnsutils traceroute \
    git gcc g++ cmake make \
    python3 python3-pip python3-venv python3-dev \
    libcurl4-openssl-dev libssl-dev pkg-config \
    bash-completion pass rsync tree zsh zip unzip \
    krb5-user libkrb5-dev \
    tmux screen \
    nano vim jq && \
    rm -rf /var/lib/apt/lists/* && \
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
USER coder

VOLUME /home/coder

HEALTHCHECK --interval=30s \
            --timeout=60s \
            --retries=3 \
  CMD curl -sf http://127.0.0.1:1337 || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["dumb-init", "fixuid", "-q", "code-server", "--bind-addr", "0.0.0.0:1337", ".", "--disable-telemetry"]
