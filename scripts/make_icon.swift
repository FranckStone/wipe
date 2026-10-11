// 生成 Resources/AppIcon.icns：swift scripts/make_icon.swift
import AppKit

let size: CGFloat = 1024

func renderIcon() -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size),
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext

    // macOS 图标网格：824×824 主体，四周留 100 的边距
    let body = CGRect(x: 100, y: 100, width: 824, height: 824)
    let bodyPath = NSBezierPath(roundedRect: body, xRadius: 185, yRadius: 185)

    // 阴影
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 28,
                  color: NSColor.black.withAlphaComponent(0.3).cgColor)
    NSColor.black.setFill()
    bodyPath.fill()
    ctx.restoreGState()

    // 背景渐变
    ctx.saveGState()
    bodyPath.addClip()
    NSGradient(colors: [
        NSColor(red: 0.13, green: 0.80, blue: 0.80, alpha: 1),
        NSColor(red: 0.25, green: 0.47, blue: 1.00, alpha: 1),
    ])!.draw(in: body, angle: -60)

    // 屏幕
    let screen = CGRect(x: 230, y: 300, width: 564, height: 400)
    let screenPath = NSBezierPath(roundedRect: screen, xRadius: 44, yRadius: 44)
    NSColor.white.withAlphaComponent(0.95).setFill()
    screenPath.fill()

    // 屏幕上一道擦干净的斜向高光
    ctx.saveGState()
    screenPath.addClip()
    NSColor(red: 0.20, green: 0.55, blue: 1.0, alpha: 0.16).setFill()
    screenPath.fill()
    let shine = NSBezierPath()
    shine.move(to: CGPoint(x: 330, y: 300))
    shine.line(to: CGPoint(x: 520, y: 300))
    shine.line(to: CGPoint(x: 760, y: 700))
    shine.line(to: CGPoint(x: 570, y: 700))
    shine.close()
    NSColor.white.setFill()
    shine.fill()
    ctx.restoreGState()

    // 支架
    let stand = NSBezierPath(roundedRect: CGRect(x: 452, y: 230, width: 120, height: 60),
                             xRadius: 14, yRadius: 14)
    stand.append(NSBezierPath(roundedRect: CGRect(x: 380, y: 206, width: 264, height: 34),
                              xRadius: 17, yRadius: 17))
    stand.windingRule = .nonZero
    NSColor.white.withAlphaComponent(0.85).setFill()
    stand.fill()

    // 闪光
    func sparkle(center: CGPoint, radius: CGFloat) {
        let p = NSBezierPath()
        let inner = radius * 0.22
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4 + .pi / 2
            let r = i % 2 == 0 ? radius : inner
            let pt = CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
            i == 0 ? p.move(to: pt) : p.line(to: pt)
        }
        p.close()
        NSColor.white.setFill()
        p.fill()
    }
    sparkle(center: CGPoint(x: 760, y: 770), radius: 92)
    sparkle(center: CGPoint(x: 650, y: 820), radius: 42)
    sparkle(center: CGPoint(x: 830, y: 660), radius: 34)

    ctx.restoreGState()
    NSGraphicsContext.restoreGraphicsState()
    return rep
}

func resized(_ rep: NSBitmapImageRep, to px: Int) -> Data {
    let out = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: out)
    NSGraphicsContext.current!.imageInterpolation = .high
    rep.draw(in: CGRect(x: 0, y: 0, width: px, height: px))
    NSGraphicsContext.restoreGraphicsState()
    return out.representation(using: .png, properties: [:])!
}

let root = URL(fileURLWithPath: CommandLine.arguments[0])
    .deletingLastPathComponent().deletingLastPathComponent()
let iconset = FileManager.default.temporaryDirectory.appendingPathComponent("AppIcon.iconset")
try? FileManager.default.removeItem(at: iconset)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

let master = renderIcon()
for base in [16, 32, 128, 256, 512] {
    try resized(master, to: base).write(to: iconset.appendingPathComponent("icon_\(base)x\(base).png"))
    try resized(master, to: base * 2).write(to: iconset.appendingPathComponent("icon_\(base)x\(base)@2x.png"))
}

let resources = root.appendingPathComponent("Resources")
try FileManager.default.createDirectory(at: resources, withIntermediateDirectories: true)
try resized(master, to: 1024).write(to: resources.appendingPathComponent("AppIcon.png"))

let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
task.arguments = ["-c", "icns", iconset.path, "-o", resources.appendingPathComponent("AppIcon.icns").path]
try task.run()
task.waitUntilExit()
print(task.terminationStatus == 0 ? "✅ Resources/AppIcon.icns" : "❌ iconutil 失败")
