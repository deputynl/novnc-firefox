#!/bin/bash
set -e

VERSION=${1:-latest}
IMAGE=ghcr.io/deputynl/novnc-firefox

# Create or reuse a multi-arch builder
docker buildx inspect multiarch-builder > /dev/null 2>&1 || \
    docker buildx create --name multiarch-builder --use
docker buildx use multiarch-builder

echo "Building ${IMAGE}:${VERSION} for linux/amd64 and linux/arm64 ..."

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag ${IMAGE}:${VERSION} \
    --tag ${IMAGE}:latest \
    --push \
    .

echo ""
echo "Done. Pushed:"
echo "  ${IMAGE}:${VERSION}"
echo "  ${IMAGE}:latest"
