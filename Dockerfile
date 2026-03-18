# syntax=docker/dockerfile:1.6

########################
# 1) Build stage
########################
FROM golang:1.25-bookworm AS builder

WORKDIR /src

# Cache de dependências
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

# Copia o código
COPY . .

# Build binário estático
RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" -o /out/evaluation-service .

########################
# 2) Runtime stage (minimal)
########################
FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /app

COPY --from=builder /out/evaluation-service /app/evaluation-service

# Porta default do app
EXPOSE 8004

ENTRYPOINT ["/app/evaluation-service"]
