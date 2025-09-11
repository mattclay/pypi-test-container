FROM public.ecr.aws/docker/library/alpine:3.22.1 AS base

RUN apk add --no-cache python3

FROM base as builder

RUN apk add --no-cache gcc python3-dev musl-dev libffi-dev

COPY files/pip/*.txt /tmp/setup/

RUN python -m venv /root/devpi/
RUN /root/devpi/bin/pip install -r /tmp/setup/requirements.txt -c /tmp/setup/constraints.txt --disable-pip-version-check
RUN /root/devpi/bin/pip freeze --disable-pip-version-check
RUN /root/devpi/bin/pip uninstall pip -y --disable-pip-version-check
# We can't uninstall `setuptools` using `pip` because `pyramid` depends `pkg_resources` at runtime.
# See: https://github.com/Pylons/pyramid/issues/3731
# Instead, we remove `setuptools` files while leaving `pkg_resources` behind, to reduce image size.
# However, we do need to install `jaraco.text` to keep `pkg_resources` working, so it's included in the requirements.
RUN cd /root/devpi/lib/python*/site-packages/ && rm -rf setuptools setuptools-*

FROM base as output

COPY --from=builder /root/devpi/ /root/devpi/
COPY files/devpi-server/devpi-server.yml /root/.config/devpi-server/devpi-server.yml

# Avoid `pkg_resources` deprecation warning caused by the `pyramid` package.
ENV PYTHONWARNINGS="ignore:pkg_resources is deprecated as an API:UserWarning:pyramid.path:0"

RUN /root/devpi/bin/devpi-init

CMD /root/devpi/bin/devpi-server
