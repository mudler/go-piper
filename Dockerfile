FROM quay.io/pypa/manylinux_2_28_x86_64 as build-amd64

FROM quay.io/pypa/manylinux_2_28_aarch64 as build-arm64

FROM debian:bullseye as build-armv7

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
        build-essential cmake ca-certificates curl pkg-config

# -----------------------------------------------------------------------------

ARG TARGETARCH
ARG TARGETVARIANT
FROM build-${TARGETARCH}${TARGETVARIANT} as build
ARG TARGETARCH
ARG TARGETVARIANT

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /build

ARG SPDLOG_VERSION="1.11.0"
RUN curl -L "https://github.com/gabime/spdlog/archive/refs/tags/v${SPDLOG_VERSION}.tar.gz" | \
    tar -xzvf - && \
    mkdir -p "spdlog-${SPDLOG_VERSION}/build" && \
    cd "spdlog-${SPDLOG_VERSION}/build" && \
    cmake ..  && \
    make -j8 && \
    cmake --install . --prefix /usr

RUN mkdir -p "lib/Linux-$(uname -m)"
RUN dnf install -y wget
# Use pre-compiled Piper phonemization library (includes onnxruntime)
ARG PIPER_PHONEMIZE_VERSION='1.0.0'
RUN mkdir -p "lib/Linux-$(uname -m)/piper_phonemize" && \
    curl -L "https://github.com/rhasspy/piper-phonemize/releases/download/v${PIPER_PHONEMIZE_VERSION}/libpiper_phonemize-${TARGETARCH}${TARGETVARIANT}.tar.gz" | \
        tar -C "lib/Linux-$(uname -m)/piper_phonemize" -xzvf -

RUN wget https://go.dev/dl/go1.20.5.linux-amd64.tar.gz &&  rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz


RUN cp -rfv /build/lib/Linux-$(uname -m)/piper_phonemize/lib/. /lib64/
RUN cp -rfv /build/lib/Linux-$(uname -m)/piper_phonemize/lib/. /usr/lib/
RUN cp -rfv /build/lib/Linux-$(uname -m)/piper_phonemize/include/. /usr/include/

ENV PATH=$PATH:/usr/local/go/bin
# Build piper binary
#COPY piper/Makefile ./
#COPY piper/src/cpp/ ./src/cpp/
#RUN make

# Do a test run
#RUN ./build/piper --help

# Build .tar.gz to keep symlinks
#WORKDIR /dist
#RUN mkdir -p piper && \
#    cp -dR /build/build/*.so* /build/build/espeak-ng-data /build/build/libtashkeel_model.ort /build/build/piper ./piper/ && \
#    tar -czf "piper_${TARGETARCH}${TARGETVARIANT}.tar.gz" piper/

