import SwiftUI

@main
struct CadenceApp: App {
    @State private var timerState = TimerState()
    @State private var notificationManager = NotificationManager()

    var body: some Scene {
        Window("Cadence", id: "cadence-timer") {
            TimerWindowView(timerState: timerState, notificationManager: notificationManager)
                .onAppear {
                    notificationManager.requestAuthorizationIfNeeded()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 280, height: 360)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
