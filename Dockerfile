FROM rust:latest as builder
ARG PROFILE=release
WORKDIR /lightning

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
    --mount=type=cache,target=/lightning/target \
    cargo build --profile $PROFILE --bin lightning-node && \
    cargo strip  && \
    mv /lightning/target/release/lightning-node /lightning-node

FROM ubuntu:latest

RUN apt-get update -yq && \
    apt-get install -yq \
    libssl-dev \
    ca-certificates

COPY --from=builder /lightning/target/release/lightning-node /usr/local/bin/lgtn

ENTRYPOINT ["lgtn", "run"]