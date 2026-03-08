import AppKit
import CadenceKit
import CoreText
import SwiftUI

@main
struct TempoApp: App {
    @NSApplicationDelegateAdaptor(TempoAppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
class TempoAppDelegate: NSObject, NSApplicationDelegate {
    var windowManager: WindowManager<TempoTimerView>?
    var editorWindow: NSWindow?
    let notificationManager = NotificationManager()
    let activityStore = ActivityStore()
    lazy var timerState = TimerState(notificationManager: notificationManager)
    var statusItem: NSStatusItem?
    private var lastPhase: TimerState.Phase?
    private var lastIsRunning: Bool = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        registerFonts()
        notificationManager.requestAuthorizationIfNeeded()

        windowManager = WindowManager(
            title: "Tempo",
            autosaveName: "TempoMainWindow",
            content: TempoTimerView(timerState: timerState, activityStore: activityStore)
        )

        lastPhase = timerState.currentPhase
        setupStatusBarItem()
        windowManager?.showWindow()
    }

    private func registerFonts() {
        let fontNames = ["Outfit-Light", "Outfit-Regular", "Outfit-Medium"]
        for name in fontNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { continue }
            var error: Unmanaged<CFError>?
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    // MARK: - Status Bar

    private func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem?.button else { return }
        updateStatusBarIcon()
        button.action = #selector(statusBarClicked)
        button.target = self
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                let current = self.timerState.currentPhase
                let running = self.timerState.isRunning

                if current != self.lastPhase {
                    if let old = self.lastPhase {
                        self.activityStore.phaseCompleted(old)
                    }
                    self.activityStore.pickActivity(for: current)
                    self.lastPhase = current
                    self.updateStatusBarIcon()
                } else if running != self.lastIsRunning {
                    self.lastIsRunning = running
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
        button.title = ""
    }

    @objc private func statusBarClicked(_ sender: NSStatusBarButton) {
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

    // MARK: - Context Menu

    private func showContextMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: "Show Timer", action: #selector(showTimer), keyEquivalent: ""))
        menu.addItem(NSMenuItem(
            title: "Edit Activities\u{2026}", action: #selector(showEditor), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "Quit Tempo", action: #selector(quitApp), keyEquivalent: "q"))

        for item in menu.items { item.target = self }

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

    // MARK: - Activity Editor

    @objc private func showEditor() {
        if let existing = editorWindow, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate()
            return
        }

        let editor = ActivityEditorView(store: activityStore)
        let controller = NSHostingController(rootView: editor)

        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: NSSize(
                width: DesignSystem.Spacing.editorWidth,
                height: DesignSystem.Spacing.editorHeight
            )),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Activities"
        window.contentViewController = controller
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate()

        editorWindow = window
    }
}
