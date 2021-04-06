FROM quay.io/bedrock/ubuntu:focal-20210325

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3-pip \
    && \
    apt-get clean \
    && \
    rm -rf /var/lib/apt/lists/*

COPY files/pip/*.txt /tmp/
COPY files/devpi-server/devpi-server.yml /root/.config/devpi-server/devpi-server.yml

RUN pip3 install -r /tmp/requirements.txt -c /tmp/constraints.txt --disable-pip-version-check --no-cache

RUN /usr/local/bin/devpi-init
CMD /usr/local/bin/devpi-server
