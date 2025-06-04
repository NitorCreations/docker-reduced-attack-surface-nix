FROM nixos/nix:latest as builder

COPY . /build
WORKDIR /build

RUN nix --extra-experimental-features 'nix-command flakes' build -o result

FROM scratch
COPY --link=false --from=builder /build/result /
ENTRYPOINT ["/bin/sh"]
