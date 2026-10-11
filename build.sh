#!/bin/bash
# 构建 Wipe.app 到 ./build 目录
set -euo pipefail
cd "$(dirname "$0")"

APP="build/Wipe.app"

swift build -c release

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/release/Wipe "$APP/Contents/MacOS/Wipe"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<'PLIST'
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
    <key>CFBundleShortVersionString</key><string>1.0.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
    <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

# 用固定证书签名，重新构建后「辅助功能」授权不会失效；可用 SIGN_IDENTITY 覆盖，传 - 为 ad-hoc
SIGN_IDENTITY="${SIGN_IDENTITY:-517FC4031416CCAC0B1E71452B5BDF8A114A2BE3}"
codesign --force --sign "$SIGN_IDENTITY" "$APP"
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
