FROM ubuntu:26.04@sha256:d66b366dac61b575bee2aef07e9c26e8070096fbe84a3d4d3eb0da069b5d76db

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

ARG GHDL_VERSION=v6.0.0

# hadolint ignore=DL3064
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

# -----------------------------------------------------------------------------
# Base packages
# -----------------------------------------------------------------------------

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential=12.12ubuntu2.26.04.2 \
        ca-certificates=20260816ubuntu0.26.04.2 \
        curl=8.18.0-1ubuntu2.8 \
        git=1:2.53.0-1ubuntu1.1 \
        openssh-client=1:10.2p1-2ubuntu3.8 \
        sudo=1.9.17p2-1ubuntu3.2 \
        locales=2.43-2ubuntu2.7 \
        pkg-config=2.5.1-4 \
        zlib1g-dev=1:1.3.dfsg+really1.3.1-1ubuntu3.2 \
        gnat=14.1ubuntu2 \
        llvm-dev=1:21.1.6-71 \
        clang=1:21.1.6-71 \
        python3=3.14.3-0ubuntu2 \
        python3-pip=25.1.1+dfsg-1ubuntu2 \
        python3-venv=3.14.3-0ubuntu2 \
        gtkwave=3.3.126-1 \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8


# -----------------------------------------------------------------------------
# Build GHDL with LLVM backend
# -----------------------------------------------------------------------------

WORKDIR /tmp/ghdl

RUN git clone \
        --depth 1 \
        --branch "${GHDL_VERSION}" \
        https://github.com/ghdl/ghdl.git \
        /tmp/ghdl \
    && ./configure \
        --prefix=/usr/local \
        --with-llvm-config="$(command -v llvm-config)" \
    && make -j"$(nproc)" \
    && make install \
    && rm -rf /tmp/ghdl

WORKDIR /


# -----------------------------------------------------------------------------
# Create development user
# -----------------------------------------------------------------------------

RUN existing_user="$(getent passwd "${USER_UID}" | cut -d: -f1 || true)" \
    && if [ -n "${existing_user}" ] && [ "${existing_user}" != "${USERNAME}" ]; then \
        usermod -l "${USERNAME}" "${existing_user}"; \
        existing_group="$(getent group "${USER_GID}" | cut -d: -f1 || true)"; \
        if [ -n "${existing_group}" ] && [ "${existing_group}" != "${USERNAME}" ]; then \
            groupmod -n "${USERNAME}" "${existing_group}" || true; \
        fi; \
        usermod -d "/home/${USERNAME}" -m "${USERNAME}"; \
    elif [ -z "${existing_user}" ]; then \
        existing_group="$(getent group "${USER_GID}" | cut -d: -f1 || true)"; \
        if [ -z "${existing_group}" ]; then \
            groupadd --gid "${USER_GID}" "${USERNAME}"; \
        fi; \
        useradd \
            --uid "${USER_UID}" \
            --gid "${USER_GID}" \
            --create-home \
            --shell /bin/bash \
            "${USERNAME}"; \
    fi \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" \
        > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}" \
    && chmod 0755 "/home/${USERNAME}"


# -----------------------------------------------------------------------------
# Python environment
# -----------------------------------------------------------------------------

USER ${USERNAME}

ENV VIRTUAL_ENV=/home/${USERNAME}/.venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

RUN python3 -m venv "${VIRTUAL_ENV}" \
    && pip install --no-cache-dir pip==26.3 \
    && pip install --no-cache-dir \
        vunit_hdl==4.7.1 \
        fpgather==0.1.0 \
        colorama==0.4.6 \
        PyYAML==6.0.4


# -----------------------------------------------------------------------------
# Default working directory
# -----------------------------------------------------------------------------

WORKDIR /workspaces
