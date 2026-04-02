import AppKit
import SwiftUI

@MainActor
public final class WindowManager<Content: View>: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private let contentView: Content
    private let windowTitle: String
    private let autosaveName: String

    public init(
        title: String,
        autosaveName: String,
        content: Content
    ) {
        self.contentView = content
        self.windowTitle = title
        self.autosaveName = autosaveName
        super.init()
        createWindow()
    }

    private func createWindow() {
        let hostingController = NSHostingController(rootView: contentView)

        let windowSize = NSSize(
            width: DesignSystem.Spacing.windowWidth,
            height: DesignSystem.Spacing.windowHeight
        )
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: windowSize),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        self.window = window

        window.title = windowTitle
        window.contentViewController = hostingController
        window.isMovableByWindowBackground = true
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true

        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        window.delegate = self

        window.setFrameAutosaveName(autosaveName)

        if !isFrameOnScreen(window.frame) {
            window.center()
        }
    }

    public func showWindow() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    public func hideWindow() {
        window?.orderOut(nil)
    }

    public func toggleWindow() {
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

    public func windowShouldClose(_ sender: NSWindow) -> Bool {
        hideWindow()
        return false
    }
}
