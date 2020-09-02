FROM golang:alpine AS builder

# Install git + SSL ca certificates.
# Git is required for fetching the dependencies.
# Ca-certificates is required to call HTTPS endpoints.
RUN apk update && apk add --no-cache git ca-certificates tzdata=2020a-r0 && update-ca-certificates

WORKDIR $GOPATH/src/github.com/txn2/txpdf
COPY . .

RUN go mod download
RUN go mod verify

RUN CGO_ENABLED=0 go build -a -installsuffix cgo -o /go/bin/server .

FROM txn2/n2pdf

WORKDIR /

COPY --from=builder /go/bin/server /server
ENTRYPOINT ["/server"]
