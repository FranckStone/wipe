#!/bin/bash
# 构建 Wipe.app 到 ./build 目录
set -euo pipefail
cd "$(dirname "$0")"

APP="build/Wipe.app"
VERSION="$(tr -d '[:space:]' < VERSION)"
BUILD_NUMBER="${BUILD_NUMBER:-2}"
ARCH="${ARCH:-$(uname -m)}"

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ ! "$BUILD_NUMBER" =~ ^[0-9]+$ ]]; then
    echo "VERSION 必须为 x.y.z，BUILD_NUMBER 必须为整数" >&2
    exit 1
fi
case "$ARCH" in
    arm64|x86_64) ;;
    *) echo "不支持的架构：$ARCH" >&2; exit 1 ;;
esac

swift build -c release --arch "$ARCH"
BIN_DIR="$(swift build -c release --arch "$ARCH" --show-bin-path)"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/Wipe" "$APP/Contents/MacOS/Wipe"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
cp LICENSE "$APP/Contents/Resources/LICENSE"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>Wipe</string>
    <key>CFBundleDisplayName</key><string>Wipe</string>
    <key>CFBundleIdentifier</key><string>com.frank.wipe</string>
    <key>CFBundleExecutable</key><string>Wipe</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>$VERSION</string>
    <key>CFBundleVersion</key><string>$BUILD_NUMBER</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
    <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

# 默认 ad-hoc 签名；可设置 SIGN_IDENTITY 使用自己的固定证书。
SIGN_IDENTITY="${SIGN_IDENTITY:--}"
codesign --force --sign "$SIGN_IDENTITY" "$APP"
codesign --verify --deep --strict "$APP"
echo "✅ 已生成 $APP"

# ./build.sh --install：安装到 /Applications 并重新打开
if [[ "${1:-}" == "--install" ]]; then
    pkill -f "Wipe.app/Contents/MacOS/Wipe" || true
    sleep 1
    rm -rf /Applications/Wipe.app
    ditto "$APP" /Applications/Wipe.app
    open /Applications/Wipe.app
    echo "✅ 已安装到 /Applications/Wipe.app"
fi
