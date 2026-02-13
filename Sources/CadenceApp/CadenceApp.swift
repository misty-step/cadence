import SwiftUI
import AppKit

@main
struct CadenceApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var timerState = TimerState()
    @State private var notificationManager = NotificationManager()

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
        // Set up as menu bar app (no dock icon)
        NSApp.setActivationPolicy(.accessory)
        
        // Request notification authorization
        notificationManager.requestAuthorizationIfNeeded()
        
        // Create window manager
        windowManager = WindowManager(timerState: timerState, notificationManager: notificationManager)
        
        // Create status bar item
        setupStatusBarItem()
        
        // Show the main window
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
        
        // Update icon when timer state changes
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateStatusBarIcon()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
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
        return NSImage(size: size, flipped: false) { rect in
            NSColor.labelColor.setStroke()
            
            let inset: CGFloat = 2
            let circleRect = rect.insetBy(dx: inset, dy: inset)
            let center = NSPoint(x: rect.midX, y: rect.midY)
            let radius = circleRect.width / 2
            
            switch (phase, isRunning) {
            case (.focus, true):
                // Solid filled circle
                NSBezierPath(ovalIn: circleRect).fill()
                
            case (.focus, false):
                // Hollow circle outline
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = 2
                path.stroke()
                
            case (.shortBreak, true):
                // Bottom half filled
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
    }
}

import Combine
