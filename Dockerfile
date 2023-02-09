#1-5
FROM rust as planner
WORKDIR /app
RUN cargo install cargo-chef
COPY . .
RUN cargo chef prepare --recipe-path recipe.json
#6-12
FROM rust as cacher
WORKDIR /app
RUN cargo install cargo-chef
RUN apt-get update 
RUN apt-get install -y clang
COPY --from=planner /app/recipe.json  recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
#13-22
FROM rust as builder
COPY . /app
WORKDIR /app
COPY --from=cacher /app/target target
RUN apt-get update 
RUN apt-get install -y clang
RUN rustup target add wasm32-unknown-unknown
RUN cargo install trunk wasm-bindgen-cli
RUN cd fleet && trunk build --release
RUN cargo build --release
#23
FROM debian
COPY --from=builder /app/target/release/port /usr/local/bin/port
COPY --from=builder /app/fleet/dist /usr/local/bin/dist
RUN apt-get update 
RUN apt-get install -y curl
WORKDIR /usr/local/bin
CMD ["/usr/local/bin/port"]