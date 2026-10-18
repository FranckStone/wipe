#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="$(tr -d '[:space:]' < VERSION)"
ARCH="${ARCH:-$(uname -m)}"
export ARCH
./build.sh

OUT="build/release"
NAME="Wipe-$VERSION-$ARCH"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/wipe-release.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$OUT"
ditto build/Wipe.app "$STAGE/Wipe.app"
cp LICENSE "$STAGE/LICENSE.txt"
ln -s /Applications "$STAGE/Applications"

ditto -c -k --sequesterRsrc --keepParent build/Wipe.app "$OUT/$NAME.zip"
hdiutil create -volname "Wipe $VERSION" -srcfolder "$STAGE" -ov -format UDZO "$OUT/$NAME.dmg"
(
    cd "$OUT"
    shasum -a 256 "$NAME.dmg" "$NAME.zip" > SHA256SUMS.txt
    shasum -a 256 -c SHA256SUMS.txt
)
echo "✅ 安装包：$OUT/$NAME.dmg 和 $OUT/$NAME.zip"
