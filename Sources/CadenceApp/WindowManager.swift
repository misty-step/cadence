import AppKit
import SwiftUI

@MainActor
final class WindowManager: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private let timerState: TimerState

    init(timerState: TimerState) {
        self.timerState = timerState
        super.init()
        createWindow()
    }

    private func createWindow() {
        let contentView = TimerView(timerState: timerState)
        let hostingController = NSHostingController(rootView: contentView)

        let windowSize = NSSize(width: 380, height: 480)
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: windowSize),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        self.window = window

        window.title = "Cadence"
        window.contentViewController = hostingController
        window.isMovableByWindowBackground = true
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true

        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        window.delegate = self

        // Persist and restore window position automatically
        window.setFrameAutosaveName("CadenceMainWindow")

        // Validate restored frame is on-screen; center if not
        if !isFrameOnScreen(window.frame) {
            window.center()
        }
    }

    func showWindow() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hideWindow() {
        window?.orderOut(nil)
    }

    func toggleWindow() {
        guard let window = window else { return }

        if window.isVisible && window.isKeyWindow {
            hideWindow()
        } else {
            showWindow()
        }
    }

    // MARK: - Off-Screen Validation

    private func isFrameOnScreen(_ frame: NSRect) -> Bool {
        NSScreen.screens.contains { screen in
            screen.visibleFrame.intersects(frame)
        }
    }

    // MARK: - NSWindowDelegate

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        hideWindow()
        return false
    }
}
