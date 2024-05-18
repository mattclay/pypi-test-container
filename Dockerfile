FROM quay.io/bedrock/alpine:3.19.1 AS base

RUN apk add --no-cache python3

FROM base as builder

RUN apk add --no-cache gcc python3-dev musl-dev libffi-dev

COPY files/pip/*.txt /tmp/setup/

RUN python -m venv /root/devpi/
RUN /root/devpi/bin/pip install -r /tmp/setup/requirements.txt -c /tmp/setup/constraints.txt --disable-pip-version-check
RUN cd /root/devpi/lib/python*/site-packages/ && rm -rf pip pip-* setuptools setuptools-*

FROM base as output

COPY --from=builder /root/devpi/ /root/devpi/
COPY files/devpi-server/devpi-server.yml /root/.config/devpi-server/devpi-server.yml

RUN /root/devpi/bin/devpi-init

CMD /root/devpi/bin/devpi-server
