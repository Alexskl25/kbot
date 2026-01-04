# How to build:
# Before you start:
# Note Windows container cannot be build on Linux/macOS!!!
# Darwin (macOS) cannot be build as Docker Image!!!
# docker build --platform TARGETOS/TARGETARCH .
# Examples:
# docker build --platform linux/amd64 .
# docker build --platform linux/arm .
# docker build --platform windows/amd64 .

# Baseimage from quay.io/projectquay/golang:1.25
FROM --platform=$BUILDPLATFORM quay.io/projectquay/golang:1.25 AS builder
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH
WORKDIR /go/src/app
COPY . .
RUN make build PLATFORM=$BUILDPLATFORM

RUN --mount=type=cache,target=/tmp \
    echo "Parsing PLATFORM=$PLATFORM" && \
    TARGETOS="${PLATFORM%%/*}" && \
    TARGETARCH="${PLATFORM##*/}" && \
    echo "TARGETOS=$TARGETOS TARGETARCH=$TARGETARCH" > /tmp/target && \
    true

# Linux final image
FROM scratch AS final-linux
WORKDIR /
COPY --from=builder /go/src/app/build/kbot(*)? /kbot
# enable certs for https
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot", "start"]

# Windows final image
# Note Windows container cannot be build on Linux/macOS
FROM mcr.microsoft.com/windows/nanoserver:ltsc2022 AS final-windows
WORKDIR /
COPY --from=builder /go/src/app/build/kbot* ./kbot.exe
# Optional: enable certs for https
# RUN certutil.exe -generateSSTFromWU roots.sst
ENTRYPOINT ["kbot.exe", "start"]

FROM final-${TARGETOS}