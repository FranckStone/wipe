import SwiftUI

@main
struct WipeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var controller = CleanController.shared

    var body: some Scene {
        Window("Wipe", id: "main") {
            ContentView()
                .environmentObject(controller)
        }
        .windowResizability(.contentSize)

        MenuBarExtra("Wipe", systemImage: "sparkles") {
            MenuBarContent()
                .environmentObject(controller)
        }
    }
}

private struct MenuBarContent: View {
    @EnvironmentObject var controller: CleanController
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("清洁键盘") { controller.start(.keyboard) }
            .disabled(controller.mode != nil)
        Button("清洁屏幕") { controller.start(.screen) }
            .disabled(controller.mode != nil)

        if !controller.hasPermission {
            Divider()
            Button("授予辅助功能权限…") { controller.requestPermission() }
        }

        Divider()
        Button("打开 Wipe 窗口") {
            openWindow(id: "main")
            NSApp.activate(ignoringOtherApps: true)
        }
        Button("退出 Wipe") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    // 关掉主窗口后常驻菜单栏
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }

    func applicationWillTerminate(_ notification: Notification) {
        CleanController.shared.stop()
    }
}
