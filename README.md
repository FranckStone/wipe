# Wipe

<img src="Resources/AppIcon.png" width="128" alt="Wipe 图标">

清洁键盘和屏幕时临时锁定输入的 macOS 菜单栏工具，使用 SwiftUI 和 AppKit 编写。

[下载最新版本](https://github.com/FranckStone/wipe/releases/latest) · [更新记录](CHANGELOG.md) · [MIT 许可证](LICENSE)

## 功能

- **清洁键盘**：拦截键盘与媒体按键，鼠标仍可用；用鼠标按住解锁按钮 1.5 秒结束。
- **清洁屏幕**：覆盖所有显示器，拦截键盘、鼠标和触控板输入；空格切换黑白背景，按住 Esc 1.5 秒退出，120 秒后自动解锁。
- **菜单栏操作**：关闭主窗口后仍可通过菜单栏选择模式或退出。

电源键和 Touch ID 无法拦截，擦拭时请避开。Wipe 用于临时防止误触，不是安全锁屏工具。

## 下载与安装

要求 macOS 13.0 或更高版本。当前发布的预编译安装包适用于 Apple Silicon（arm64）。

1. 从 [Releases](https://github.com/FranckStone/wipe/releases/latest) 下载 `.dmg`，打开后将 Wipe 拖入 Applications；也可下载 `.zip`，解压后移动 `Wipe.app`。
2. 首次启动后，前往「系统设置 → 隐私与安全性 → 辅助功能」授权 Wipe。
3. 返回应用，选择清洁键盘或清洁屏幕。

安装包使用 ad-hoc 签名，未经 Apple 公证。如果 macOS 阻止打开，在尝试打开后前往「系统设置 → 隐私与安全性」确认允许打开。更新或重新构建后如权限失效，可在辅助功能列表中移除旧条目并重新添加 Wipe。

每个版本附带 `SHA256SUMS.txt`，将它与安装包放在同一目录后校验：

```sh
shasum -a 256 -c SHA256SUMS.txt
```

## 从源码构建

需要 macOS、Swift 5.9 或更高版本，以及 Xcode 或 Xcode Command Line Tools。

```sh
git clone https://github.com/FranckStone/wipe.git
cd wipe
./build.sh
open build/Wipe.app
```

`./build.sh --install` 会替换 `/Applications/Wipe.app` 并启动应用。默认构建当前机器架构，使用 ad-hoc 签名，无需开发者证书。需要使用自己的签名证书时：

```sh
SIGN_IDENTITY="你的代码签名证书名称" ./build.sh
```

版本号来自 `VERSION`，`BUILD_NUMBER` 可覆盖内部构建号。`ARCH=arm64` 或 `ARCH=x86_64` 可选择编译目标；Intel 版本需要在对应硬件上验证，当前不提供经过验证的 Intel 安装包。

## 打包发布

```sh
./scripts/package_release.sh
```

生成 `build/release/Wipe-<版本>-<架构>.dmg`、`.zip` 和 `SHA256SUMS.txt`。发布前检查版本号、更新记录、签名与实际启动情况。

## 权限与隐私

辅助功能权限用于通过 `CGEventTap` 临时拦截输入。应用不会保存按键内容，不包含联网、遥测或自动更新代码；键盘模式仅在内存中累计拦截次数。

欢迎通过 [Issues](https://github.com/FranckStone/wipe/issues) 反馈问题或提交 Pull Request。源码和仓库内图标按 [MIT 许可证](LICENSE) 开源。
