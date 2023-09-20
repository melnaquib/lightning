FROM rust:latest as builder
WORKDIR /builder

RUN apt-get update
RUN apt-get install -y \
    build-essential \
    cmake \
    clang \
    pkg-config \
    libssl-dev \
    gcc \
    protobuf-compiler

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    cargo install cargo-strip

COPY . .
ENV RUST_BACKTRACE=1

RUN mkdir -p /builder/target/release
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/builder/target/release \
    cargo build --profile release --bin lightning-cli && \
    cargo strip && \
    ls -la /builder && \
    ls -la /builder/target/release

FROM ubuntu:latest

RUN apt-get update -yq && \
    apt-get install -yq \
    libssl-dev \
    ca-certificates

COPY --from=builder /builder/target/release/lightning-cli /usr/local/bin/lgtn

ENTRYPOINT ["lgtn", "run"]