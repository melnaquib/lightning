FROM rust:latest as build
WORKDIR /build

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

RUN mkdir -p /build/target/release
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/build/target \
    cargo build --profile release --bin lightning-cli && \
    cargo strip && \
    cp /build/target/release/lightning-cli /build

FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y \
    libssl-dev \
    ca-certificates

COPY --from=build /build/lightning-cli /usr/local/bin/lgtn

ENTRYPOINT ["lgtn", "run"]