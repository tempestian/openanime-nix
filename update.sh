#!/usr/bin/env bash
set -euo pipefail

REPO="OpenAnime/desktop-ts"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_VERSION=$(nix eval --impure --expr "(import $SCRIPT_DIR/source.nix).version" --raw 2>/dev/null || echo "0.0.0")

echo "Current version: $CURRENT_VERSION"

LATEST_TAG=$(curl -sL "https://api.github.com/repos/${REPO}/releases/latest" | jq -r .tag_name)
LATEST_VERSION="${LATEST_TAG#v}"

if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
  echo "Error: Could not retrieve latest release version from GitHub." >&2
  exit 1
fi

echo "Latest upstream version: $LATEST_VERSION"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
  echo "Already up to date."
  echo "UPDATED=false" >> "${GITHUB_OUTPUT:-/dev/null}"
  exit 0
fi

echo "New version available: $LATEST_VERSION"

DEB_URL="https://github.com/${REPO}/releases/download/v${LATEST_VERSION}/openanime_${LATEST_VERSION}_amd64.deb"
NEW_HASH=$(nix-prefetch-url "$DEB_URL")
SRI_HASH=$(nix hash convert --to sri "sha256:$NEW_HASH")

cat <<EOF > "$SCRIPT_DIR/source.nix"
{
  version = "$LATEST_VERSION";
  hash = "$SRI_HASH";
}
EOF

echo "source.nix updated to $LATEST_VERSION ($SRI_HASH)"
echo "UPDATED=true" >> "${GITHUB_OUTPUT:-/dev/null}"
echo "NEW_VERSION=$LATEST_VERSION" >> "${GITHUB_OUTPUT:-/dev/null}"
