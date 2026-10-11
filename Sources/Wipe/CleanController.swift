import AppKit
import SwiftUI

enum CleanMode {
    case keyboard
    case screen
}

final class CleanController: ObservableObject {
    static let shared = CleanController()

    static let screenTimeout = 120
    static let holdSeconds = 1.5
    private static let escKeyCode: Int64 = 53
    private static let spaceKeyCode: Int64 = 49

    @Published private(set) var mode: CleanMode?
    @Published private(set) var hasPermission = AXIsProcessTrusted()
    @Published private(set) var blockedKeys = 0
    @Published private(set) var whiteBackground = false
    @Published private(set) var secondsLeft = 0
    @Published private(set) var escHolding = false

    private let blocker = InputBlocker()
    private var windows: [NSWindow] = []
    private var permissionTimer: Timer?
    private var countdownTimer: Timer?
    private var escWork: DispatchWorkItem?

    private init() {
        blocker.shouldBlock = { [weak self] type, event in
            self?.handle(type, event) ?? false
        }
        watchPermission()
    }

    // MARK: - 权限

    func requestPermission() {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        _ = AXIsProcessTrustedWithOptions([key: true] as CFDictionary)
        watchPermission()
    }

    func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    private func watchPermission() {
        permissionTimer?.invalidate()
        permissionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { return timer.invalidate() }
            let trusted = AXIsProcessTrusted()
            if trusted != self.hasPermission { self.hasPermission = trusted }
            if trusted { timer.invalidate() }
        }
    }

    // MARK: - 开始 / 结束

    func start(_ newMode: CleanMode) {
        guard mode == nil else { return }
        guard AXIsProcessTrusted() else {
            hasPermission = false
            requestPermission()
            return
        }

        blockedKeys = 0
        whiteBackground = false
        escHolding = false
        mode = newMode

        guard blocker.start() else {
            mode = nil
            hasPermission = false
            requestPermission()
            return
        }

        switch newMode {
        case .keyboard: showKeyboardPanel()
        case .screen: showScreenOverlay()
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    func stop() {
        guard mode != nil else { return }
        blocker.stop()
        escWork?.cancel()
        escWork = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()
        if mode == .screen {
            NSApp.presentationOptions = []
            NSCursor.unhide()
        }
        mode = nil
        escHolding = false
    }

    // MARK: - 事件过滤（在主线程 RunLoop 上回调）

    private func handle(_ type: CGEventType, _ event: CGEvent) -> Bool {
        switch mode {
        case .keyboard:
            if type == .keyDown && event.getIntegerValueField(.keyboardEventAutorepeat) == 0 {
                blockedKeys += 1
            }
            return type.isKeyboard || isMediaKey(type, event)

        case .screen:
            if type.isKeyboard {
                handleScreenKey(type, event)
                return true
            }
            return type.isPointer || isMediaKey(type, event)

        case nil:
            return false
        }
    }

    private func handleScreenKey(_ type: CGEventType, _ event: CGEvent) {
        let code = event.getIntegerValueField(.keyboardEventKeycode)
        let isRepeat = event.getIntegerValueField(.keyboardEventAutorepeat) != 0

        if code == Self.spaceKeyCode && type == .keyDown && !isRepeat {
            whiteBackground.toggle()
        }

        guard code == Self.escKeyCode else { return }
        if type == .keyDown && !isRepeat && escWork == nil {
            escHolding = true
            let work = DispatchWorkItem { [weak self] in self?.stop() }
            escWork = work
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.holdSeconds, execute: work)
        } else if type == .keyUp {
            escWork?.cancel()
            escWork = nil
            escHolding = false
        }
    }

    // MARK: - 窗口

    private func showKeyboardPanel() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 360),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: KeyboardLockView().environmentObject(self))
        window.center()
        window.makeKeyAndOrderFront(nil)
        windows = [window]
    }

    private func showScreenOverlay() {
        NSApp.presentationOptions = [.hideDock, .hideMenuBar]
        NSCursor.hide()

        windows = NSScreen.screens.map { screen in
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false,
                screen: screen
            )
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            window.isReleasedWhenClosed = false
            window.backgroundColor = .black
            window.contentView = NSHostingView(rootView: ScreenCleanView().environmentObject(self))
            window.setFrame(screen.frame, display: true)
            window.orderFrontRegardless()
            return window
        }
        windows.first?.makeKey()

        secondsLeft = Self.screenTimeout
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.secondsLeft -= 1
            if self.secondsLeft <= 0 { self.stop() }
        }
    }
}
