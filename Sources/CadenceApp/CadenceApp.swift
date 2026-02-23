import AppKit
import CoreText
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

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        registerFonts()
        notificationManager.requestAuthorizationIfNeeded()
        windowManager = WindowManager(timerState: timerState, notificationManager: notificationManager)
        setupStatusBarItem()
        windowManager?.showWindow()
    }

    private func registerFonts() {
        let fontNames = ["Outfit-Light", "Outfit-Regular", "Outfit-Medium"]
        for name in fontNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
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
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Use withObservationTracking to update status bar only when state changes
        setupObservationTracking()
    }

    private func setupObservationTracking() {
        var lastPhase: TimerState.Phase = timerState.currentPhase
        var lastIsRunning: Bool = timerState.isRunning

        // Periodically check for state changes and update status bar (more reliable than withObservationTracking)
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if self.timerState.currentPhase != lastPhase || self.timerState.isRunning != lastIsRunning {
                    lastPhase = self.timerState.currentPhase
                    lastIsRunning = self.timerState.isRunning
                    self.updateStatusBarIcon()
                }
            }
        }
    }

    private func updateStatusBarIcon() {
        guard let button = statusItem?.button else { return }
        let icon = MenuBarIconImage(
            phase: timerState.currentPhase,
            isRunning: timerState.isRunning
        )
        button.image = icon.createNSImage()
    }

    @objc private func toggleWindow(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            windowManager?.toggleWindow()
            return
        }

        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            windowManager?.toggleWindow()
        }
    }

    private func showContextMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show Timer", action: #selector(showTimer), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Cadence", action: #selector(quitApp), keyEquivalent: "q"))

        for item in menu.items {
            item.target = self
        }

        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc private func showTimer() {
        windowManager?.showWindow()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}

// MARK: - Menu Bar Icon (NSImage-based for status bar)
struct MenuBarIconImage {
    let phase: TimerState.Phase
    let isRunning: Bool

    // Constants extracted to avoid magic numbers
    private enum Constants {
        static let size: CGFloat = 18
        static let inset: CGFloat = 2
        static let lineWidth: CGFloat = 2
        static let thinLineWidth: CGFloat = 1.5
        static let veryThinLineWidth: CGFloat = 1
        static let dashPatternLarge: [CGFloat] = [3, 2]
        static let dashPatternSmall: [CGFloat] = [2, 2]
    }

    func createNSImage() -> NSImage {
        let size = NSSize(width: Constants.size, height: Constants.size)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.labelColor.setStroke()

            let circleRect = rect.insetBy(dx: Constants.inset, dy: Constants.inset)
            let center = NSPoint(x: rect.midX, y: rect.midY)
            let radius = circleRect.width / 2

            switch (phase, isRunning) {
            case (.focus, true):
                NSColor.labelColor.setFill()
                NSBezierPath(ovalIn: circleRect).fill()

            case (.focus, false):
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = Constants.lineWidth
                path.stroke()

            case (.shortBreak, true):
                NSColor.labelColor.setFill()
                let bottomPath = NSBezierPath()
                bottomPath.move(to: NSPoint(x: center.x - radius, y: center.y))
                bottomPath.appendArc(withCenter: center, radius: radius,
                                    startAngle: 180, endAngle: 0, clockwise: true)
                bottomPath.close()
                bottomPath.fill()

                let topPath = NSBezierPath()
                topPath.appendArc(withCenter: center, radius: radius,
                                 startAngle: 0, endAngle: 180, clockwise: false)
                topPath.lineWidth = Constants.thinLineWidth
                topPath.stroke()

            case (.shortBreak, false):
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = Constants.thinLineWidth
                path.stroke()

            case (.longBreak, true):
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = Constants.lineWidth
                path.setLineDash(Constants.dashPatternLarge, count: Constants.dashPatternLarge.count, phase: 0)
                path.stroke()

            case (.longBreak, false):
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = Constants.veryThinLineWidth
                path.setLineDash(Constants.dashPatternSmall, count: Constants.dashPatternSmall.count, phase: 0)
                path.stroke()
            }
            return true
        }
        image.isTemplate = true
        return image
    }
}
