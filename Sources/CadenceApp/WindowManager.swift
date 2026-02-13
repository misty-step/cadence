import AppKit
import SwiftUI
import Combine

@MainActor
final class WindowManager: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private let timerState: TimerState
    private let notificationManager: NotificationManager
    private var cancellables = Set<AnyCancellable>()
    private let windowFrameKey = "CadenceWindowFrame"
    
    init(timerState: TimerState, notificationManager: NotificationManager) {
        self.timerState = timerState
        self.notificationManager = notificationManager
        super.init()
        createWindow()
    }
    
    private func createWindow() {
        // Create the hosting controller with our SwiftUI view
        let contentView = TimerView(timerState: timerState, notificationManager: notificationManager)
        let hostingController = NSHostingController(rootView: contentView)
        
        // Create window with fixed elegant size
        let windowSize = NSSize(width: 380, height: 480)
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: windowSize),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        self.window = window
        
        // Window configuration
        window.title = "Cadence"
        window.contentViewController = hostingController
        window.isMovableByWindowBackground = true
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        
        // Floating panel style - always accessible
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Delegate for window events
        window.delegate = self
        
        // Restore or center window position
        restoreWindowPosition()
        
        // Subscribe to window position changes
        NotificationCenter.default.publisher(for: NSWindow.didMoveNotification)
            .compactMap { $0.object as? NSWindow }
            .filter { [weak self] win in win == self?.window }
            .sink { [weak self] _ in
                self?.saveWindowPosition()
            }
            .store(in: &cancellables)
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
    
    // MARK: - Window Position Persistence
    
    private func restoreWindowPosition() {
        guard let window = window else { return }
        
        if let frameData = UserDefaults.standard.data(forKey: windowFrameKey),
           let frame = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSValue.self, from: frameData)?.rectValue {
            window.setFrame(frame, display: true)
        } else {
            window.center()
        }
    }
    
    private func saveWindowPosition() {
        guard let window = window else { return }
        let frame = window.frame
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: NSValue(rect: frame), requiringSecureCoding: false) {
            UserDefaults.standard.set(data, forKey: windowFrameKey)
        }
    }
    
    // MARK: - NSWindowDelegate
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Hide instead of close (keep app running in menu bar)
        hideWindow()
        return false
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        // Window became active - ensure display link is running
    }
}
