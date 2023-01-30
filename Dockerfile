FROM rust:1.67.0-alpine3.17 as builder
WORKDIR /app
RUN apk update
RUN apk add --no-cache musl-dev
COPY Cargo.toml Cargo.toml
RUN mkdir -p src/
RUN echo "fn main() {println!(\"failed to build\")}" > src/main.rs
RUN cargo build --release
RUN rm -f target/release/deps/rustypaste*
COPY . .
RUN cargo build --locked --release
RUN mkdir -p build-out/
RUN cp target/release/rustypaste build-out/
RUN strip build-out/rustypaste

FROM scratch
WORKDIR /app
COPY --from=builder \
    /app/build-out/rustypaste \
    /app/config.toml ./
ENV SERVER__ADDRESS=0.0.0.0:8000
EXPOSE 8000
USER 1000:1000
CMD ["./rustypaste"]
