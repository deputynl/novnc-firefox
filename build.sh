#!/bin/bash
set -e

if [ -n "$1" ]; then
    VERSION=$1
else
    CURRENT=$(cat VERSION)
    MAJOR=$(echo "$CURRENT" | cut -d. -f1)
    MINOR=$(echo "$CURRENT" | cut -d. -f2)
    PATCH=$(echo "$CURRENT" | cut -d. -f3)
    PATCH=$((PATCH + 1))
    VERSION="${MAJOR}.${MINOR}.${PATCH}"
    echo "Auto-incremented version: ${CURRENT} -> ${VERSION}"
fi

if git rev-parse "v${VERSION}" >/dev/null 2>&1; then
    echo "Tag v${VERSION} already exists — aborting before build."
    exit 1
fi

echo "$VERSION" > VERSION
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

git add -u
git commit -m "Release v${VERSION}"
git tag "v${VERSION}"
git push origin main "v${VERSION}"
gh release create "v${VERSION}" --title "v${VERSION}" --generate-notes
