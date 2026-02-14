import AppKit
import Combine
import SwiftUI

@main
struct CadenceApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var windowManager: WindowManager?
    var timerState = TimerState()
    var notificationManager = NotificationManager()
    var statusItem: NSStatusItem?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        notificationManager.requestAuthorizationIfNeeded()
        windowManager = WindowManager(timerState: timerState, notificationManager: notificationManager)
        setupStatusBarItem()
        windowManager?.showWindow()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    private func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            updateStatusBarIcon()
            button.action = #selector(toggleWindow)
            button.target = self
        }

        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.updateStatusBarIcon()
                }
            }
            .store(in: &cancellables)
    }

    private func updateStatusBarIcon() {
        guard let button = statusItem?.button else { return }
        let icon = MenuBarIconImage(
            phase: timerState.currentPhase,
            isRunning: timerState.isRunning
        )
        button.image = icon.createNSImage()
    }

    @objc private func toggleWindow() {
        windowManager?.toggleWindow()
    }
}

// MARK: - Menu Bar Icon (NSImage-based for status bar)
struct MenuBarIconImage {
    let phase: TimerState.Phase
    let isRunning: Bool

    func createNSImage() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.labelColor.setStroke()

            let inset: CGFloat = 2
            let circleRect = rect.insetBy(dx: inset, dy: inset)
            let center = NSPoint(x: rect.midX, y: rect.midY)
            let radius = circleRect.width / 2

            switch (phase, isRunning) {
            case (.focus, true):
                NSBezierPath(ovalIn: circleRect).fill()

            case (.focus, false):
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = 2
                path.stroke()

            case (.shortBreak, true):
                let bottomPath = NSBezierPath()
                bottomPath.move(to: NSPoint(x: center.x - radius, y: center.y))
                bottomPath.appendArc(withCenter: center, radius: radius,
                                    startAngle: 180, endAngle: 0, clockwise: true)
                bottomPath.close()
                bottomPath.fill()

                let topPath = NSBezierPath()
                topPath.appendArc(withCenter: center, radius: radius,
                                 startAngle: 0, endAngle: 180, clockwise: false)
                topPath.lineWidth = 1.5
                topPath.stroke()

            case (.shortBreak, false):
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = 1.5
                path.stroke()

            case (.longBreak, true):
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = 2
                path.setLineDash([3, 2], count: 2, phase: 0)
                path.stroke()

            case (.longBreak, false):
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = 1
                path.setLineDash([2, 2], count: 2, phase: 0)
                path.stroke()
            }
            return true
        }
        image.isTemplate = true
        return image
    }
}
