import SwiftUI

struct ContentView: View {
    @EnvironmentObject var controller: CleanController

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text("Wipe")
                    .font(.system(size: 28, weight: .bold))
                Text("锁住输入，放心擦键盘和屏幕")
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)

            if !controller.hasPermission {
                PermissionBanner()
            }

            HStack(spacing: 14) {
                ModeCard(
                    icon: "keyboard",
                    title: "清洁键盘",
                    detail: "锁定所有按键\n鼠标仍可用"
                ) { controller.start(.keyboard) }

                ModeCard(
                    icon: "display",
                    title: "清洁屏幕",
                    detail: "黑屏 + 锁定键盘和触控板\n按住 Esc 退出"
                ) { controller.start(.screen) }
            }
            .disabled(!controller.hasPermission)
            .opacity(controller.hasPermission ? 1 : 0.5)

            Text("提示：电源键 / Touch ID 无法被拦截，擦拭时请避开。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(28)
        .frame(width: 460)
    }
}

private struct PermissionBanner: View {
    @EnvironmentObject var controller: CleanController

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("需要「辅助功能」权限才能拦截键盘和触控板", systemImage: "lock.shield")
                .font(.callout.weight(.medium))
            HStack {
                Button("请求权限") { controller.requestPermission() }
                    .buttonStyle(.borderedProminent)
                Button("打开系统设置") { controller.openAccessibilitySettings() }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
    }
}

private struct ModeCard: View {
    let icon: String
    let title: String
    let detail: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 34))
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 150)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 长按进度圈（键盘解锁和屏幕退出共用）

struct HoldRing<Label: View>: View {
    let holding: Bool
    var color: Color = .accentColor
    var size: CGFloat = 96
    @ViewBuilder let label: () -> Label

    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.18), lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            label()
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
        .scaleEffect(holding ? 1.06 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: holding)
        .onAppear { update(holding) }
        .onChange(of: holding) { update($0) }
    }

    private func update(_ holding: Bool) {
        if holding {
            withAnimation(.linear(duration: CleanController.holdSeconds)) { progress = 1 }
        } else {
            withAnimation(.easeOut(duration: 0.2)) { progress = 0 }
        }
    }
}

// MARK: - 键盘锁定面板

struct KeyboardLockView: View {
    @EnvironmentObject var controller: CleanController
    @State private var pressing = false

    var body: some View {
        VStack(spacing: 16) {
            Text("键盘已锁定")
                .font(.title.bold())
                .padding(.top, 8)

            Text("随便擦，按键不会生效")
                .foregroundStyle(.secondary)

            Text("已拦截 \(controller.blockedKeys) 次按键")
                .font(.system(.body, design: .monospaced))
                .contentTransition(.numericText())
                .animation(.default, value: controller.blockedKeys)

            Spacer(minLength: 0)

            // 长按才解锁，避免擦触控板时误触
            HoldRing(holding: pressing) {
                Image(systemName: pressing ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 32, weight: .semibold))
            }
            .contentShape(Circle())
            .onLongPressGesture(minimumDuration: CleanController.holdSeconds, maximumDistance: 40) {
                controller.stop()
            } onPressingChanged: { pressing = $0 }

            Text(pressing ? "继续按住…" : "按住 \(CleanController.holdSeconds, specifier: "%.1f") 秒解锁")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(28)
        .frame(width: 420, height: 360)
    }
}

// MARK: - 屏幕清洁全屏层

struct ScreenCleanView: View {
    @EnvironmentObject var controller: CleanController
    @State private var showHint = true

    var body: some View {
        let fg: Color = controller.whiteBackground ? .black : .white

        ZStack {
            (controller.whiteBackground ? Color.white : Color.black)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                Text("屏幕清洁中")
                    .font(.system(size: 32, weight: .semibold))
                Text("键盘和触控板已锁定\n空格 切换黑 / 白背景    按住 Esc \(CleanController.holdSeconds, specifier: "%.1f") 秒退出")
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(fg.opacity(0.6))
            .opacity(showHint && !controller.escHolding ? 1 : 0)
            .animation(.easeInOut(duration: 0.6), value: showHint)

            VStack(spacing: 16) {
                HoldRing(holding: controller.escHolding, color: fg.opacity(0.8)) {
                    Text("esc")
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                }
                Text("继续按住…")
                    .font(.callout)
                    .foregroundStyle(fg.opacity(0.6))
            }
            .opacity(controller.escHolding ? 1 : 0)
            .animation(.easeInOut(duration: 0.15), value: controller.escHolding)

            VStack {
                Spacer()
                Text("\(controller.secondsLeft) 秒后自动解锁")
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(fg.opacity(0.18))
                    .padding(.bottom, 24)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            showHint = false
        }
    }
}
