FROM golang:latest AS builder

WORKDIR /go/src/app
COPY . .
#move to makefile
#RUN go get
RUN make build

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot"]