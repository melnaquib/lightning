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

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/builder/target \
    cargo build --profile release --bin lightning-cli && \
    cargo strip

FROM ubuntu:latest

RUN apt-get update -yq && \
    apt-get install -yq \
    libssl-dev \
    ca-certificates

COPY --from=builder /builder/target/release/lightning-cli /usr/local/bin/lgtn

ENTRYPOINT ["lgtn", "run"]