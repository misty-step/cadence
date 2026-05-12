import AppKit
import CadenceKit
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
    var windowManager: WindowManager<TimerView>?
    let timerState: TimerState
    let notificationManager: NotificationManager
    var statusItem: NSStatusItem?

    override init() {
        let notificationManager = NotificationManager()
        self.notificationManager = notificationManager
        self.timerState = TimerState(notificationManager: notificationManager)
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        registerFonts()
        notificationManager.requestAuthorizationIfNeeded()
        windowManager = WindowManager(
            title: "Cadence",
            autosaveName: "CadenceMainWindow",
            content: TimerView(timerState: timerState)
        )
        setupStatusBarItem()
        windowManager?.showWindow()
    }

    private func registerFonts() {
        let fontNames = ["Outfit-Light", "Outfit-Regular", "Outfit-Medium"]
        for name in fontNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                #if DEBUG
                assertionFailure("Missing font resource: \(name).ttf")
                #endif
                continue
            }

            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                #if DEBUG
                let description = (error?.takeRetainedValue() as Error?)?.localizedDescription ?? "Unknown error"
                assertionFailure("Font registration failed for \(name): \(description)")
                #endif
            }
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
