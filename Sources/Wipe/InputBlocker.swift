import AppKit
import CoreGraphics

/// 基于 CGEventTap 的全局输入拦截器，需要「辅助功能」权限。
final class InputBlocker {
    /// 返回 true 表示吞掉这个事件。
    var shouldBlock: ((CGEventType, CGEvent) -> Bool)?

    private var tap: CFMachPort?
    private var source: CFRunLoopSource?

    var isRunning: Bool { tap != nil }

    func start() -> Bool {
        guard tap == nil else { return true }

        let callback: CGEventTapCallBack = { _, type, event, refcon in
            let me = Unmanaged<InputBlocker>.fromOpaque(refcon!).takeUnretainedValue()
            // 系统超时或用户输入导致 tap 被关掉时，立刻重新打开
            if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                if let tap = me.tap { CGEvent.tapEnable(tap: tap, enable: true) }
                return Unmanaged.passUnretained(event)
            }
            if me.shouldBlock?(type, event) == true { return nil }
            return Unmanaged.passUnretained(event)
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(UInt64.max),
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return false }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        self.source = source
        return true
    }

    func stop() {
        if let tap { CGEvent.tapEnable(tap: tap, enable: false) }
        if let source { CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes) }
        tap = nil
        source = nil
    }
}

extension CGEventType {
    static let systemDefined = CGEventType(rawValue: 14)!

    var isKeyboard: Bool {
        self == .keyDown || self == .keyUp || self == .flagsChanged
    }

    var isPointer: Bool {
        switch self {
        case .mouseMoved, .leftMouseDown, .leftMouseUp, .leftMouseDragged,
             .rightMouseDown, .rightMouseUp, .rightMouseDragged,
             .otherMouseDown, .otherMouseUp, .otherMouseDragged, .scrollWheel:
            return true
        default:
            // 29~32 等为触控板手势（缩放、旋转、轻扫等）
            return rawValue >= 18 && rawValue <= 40
        }
    }
}

/// 亮度、音量、播放等媒体键走的是 NX_SYSDEFINED（subtype 8）。
func isMediaKey(_ type: CGEventType, _ event: CGEvent) -> Bool {
    guard type == .systemDefined, let ns = NSEvent(cgEvent: event) else { return false }
    return ns.subtype.rawValue == 8
}
