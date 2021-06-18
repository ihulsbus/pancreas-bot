ARG  BUILDER_IMAGE=golang:buster
ARG  DISTROLESS_IMAGE=gcr.io/distroless/base
############################
# STEP 1 build executable binary
############################
FROM ${BUILDER_IMAGE} as builder

# Ensure ca-certficates are up to date
RUN update-ca-certificates

WORKDIR /build

# use modules
COPY . .

ENV GO111MODULE=on
RUN go mod download
RUN go mod verify


# Build the binary.
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags="-w -s" -o /go/bin/pancreas-bot

############################
# STEP 2 build a small image
############################
# using base nonroot image
# user:group is nobody:nobody, uid:gid = 65534:65534
FROM ${DISTROLESS_IMAGE}

# Copy our static executable.
COPY --from=builder /go/bin/pancreas-bot /go/bin/pancreas-bot

# Run the hello binary.
ENTRYPOINT ["/go/bin/pancreas-bot"]