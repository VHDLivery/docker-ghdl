FROM ubuntu:26.04

ARG DEBIAN_FRONTEND=noninteractive

ARG GHDL_VERSION=v6.0.0

ARG USERNAME=fpga-env
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

# -----------------------------------------------------------------------------
# Base packages
# -----------------------------------------------------------------------------

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        openssh-client \
        sudo \
        locales \
        pkg-config \
        zlib1g-dev \
        gnat \
        llvm-dev \
        clang \
        python3 \
        python3-pip \
        python3-venv \
        gtkwave \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8


# -----------------------------------------------------------------------------
# Build GHDL with LLVM backend
# -----------------------------------------------------------------------------

RUN git clone \
        --depth 1 \
        --branch "${GHDL_VERSION}" \
        https://github.com/ghdl/ghdl.git \
        /tmp/ghdl \
    && cd /tmp/ghdl \
    && ./configure \
        --prefix=/usr/local \
        --with-llvm-config="$(command -v llvm-config)" \
    && make -j"$(nproc)" \
    && make install \
    && cd / \
    && rm -rf /tmp/ghdl


# -----------------------------------------------------------------------------
# Create development user
# -----------------------------------------------------------------------------

RUN existing_user="$(getent passwd "${USER_UID}" | cut -d: -f1)" \
    && if [ -n "${existing_user}" ] && [ "${existing_user}" != "${USERNAME}" ]; then \
        usermod -l "${USERNAME}" "${existing_user}"; \
        existing_group="$(getent group "${USER_GID}" | cut -d: -f1)"; \
        if [ -n "${existing_group}" ] && [ "${existing_group}" != "${USERNAME}" ]; then \
            groupmod -n "${USERNAME}" "${existing_group}" || true; \
        fi; \
        usermod -d "/home/${USERNAME}" -m "${USERNAME}"; \
    elif [ -z "${existing_user}" ]; then \
        existing_group="$(getent group "${USER_GID}" | cut -d: -f1)"; \
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
    && pip install --upgrade pip \
    && pip install \
        vunit_hdl \
        fpgather


# -----------------------------------------------------------------------------
# Default working directory
# -----------------------------------------------------------------------------

WORKDIR /workspaces
