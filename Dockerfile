FROM rust:latest as build

RUN rustup target add wasm32-unknown-unknown
RUN cargo install trunk wasm-bindgen-cli

WORKDIR usr/src/web
COPY . .

RUN cargo build --release
RUN cd fleet && trunk build --release

FROM gcr.io/distroless/cc-debian10

COPY --from=build /usr/src/web/target/release/port /usr/local/bin/port
COPY --from=build /usr/src/web/fleet/dist /usr/local/bin/dist

WORKDIR /usr/local/bin
CMD ["port"]