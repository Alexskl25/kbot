FROM --platform=$BUILDPLATFORM golang:latest AS builder
ARG BUILDPLATFORM
WORKDIR /go/src/app
COPY . .
RUN make build PLATFORM=$BUILDPLATFORM

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/build/kbot(*)? .
#enable certs for https
#COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot", "start"]