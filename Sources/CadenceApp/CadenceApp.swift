import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

@main
struct CadenceApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @State private var timerState = TimerState()
    @State private var notificationManager = NotificationManager()

    var body: some Scene {
        Window("Cadence", id: "cadence-timer") {
            TimerWindowView(timerState: timerState)
                .onAppear {
                    notificationManager.requestAuthorizationIfNeeded()
                    timerState.onPhaseChange = { [notificationManager] phase in
                        notificationManager.notify(phase: phase)
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .defaultSize(width: 280, height: 360)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
