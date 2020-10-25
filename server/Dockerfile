FROM golang:1.15.3 AS builder
LABEL maintainer="Midnight Riders <info@midnightriders.com>"

WORKDIR /go

RUN go get github.com/pilu/fresh

WORKDIR /go/src/github.com/MidnightRiders/MemberPortal/server
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -a -installsuffix 'static' -o server .

FROM scratch

WORKDIR /
COPY --from=builder /go/src/github.com/MidnightRiders/MemberPortal/server/server .

USER 1002:1002

ENTRYPOINT [ "/server" ]
