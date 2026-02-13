import SwiftUI

@main
struct CadenceApp: App {
    @State private var timerState = TimerState()
    @State private var notificationManager = NotificationManager()

    var body: some Scene {
        Window("Cadence", id: "main") {
            TimerWindowView(timerState: timerState, notificationManager: notificationManager)
                .onAppear {
                    notificationManager.requestAuthorizationIfNeeded()
                    configureWindow()
                }
        }
        .defaultPosition(.center)
        .defaultSize(width: 280, height: 360)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }

    private func configureWindow() {
        // Configure window appearance
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                // Make the window look nice
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.isMovableByWindowBackground = true
                window.standardWindowButton(.closeButton)?.isHidden = false
                window.standardWindowButton(.miniaturizeButton)?.isHidden = false
                window.standardWindowButton(.zoomButton)?.isHidden = true

                // Prevent window from being too small
                window.minSize = NSSize(width: 280, height: 360)
                window.maxSize = NSSize(width: 400, height: 500)

                // Restore saved position if available
                if let savedFrame = UserDefaults.standard.string(forKey: "windowFrame") {
                    let frame = NSRectFromString(savedFrame)
                    window.setFrame(frame, display: true)
                }

                // Save position on move/resize
                NotificationCenter.default.addObserver(
                    forName: NSWindow.didMoveNotification,
                    object: window,
                    queue: .main
                ) { [weak window] _ in
                    Task { @MainActor in
                        if let w = window {
                            UserDefaults.standard.set(NSStringFromRect(w.frame), forKey: "windowFrame")
                        }
                    }
                }

                NotificationCenter.default.addObserver(
                    forName: NSWindow.didResizeNotification,
                    object: window,
                    queue: .main
                ) { [weak window] _ in
                    Task { @MainActor in
                        if let w = window {
                            UserDefaults.standard.set(NSStringFromRect(w.frame), forKey: "windowFrame")
                        }
                    }
                }
            }
        }
    }
}
