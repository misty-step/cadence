import SwiftUI

@main
struct CadenceApp: App {
    @State private var timerState = TimerState()
    @State private var notificationManager = NotificationManager()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(timerState: timerState, notificationManager: notificationManager)
                .onAppear {
                    notificationManager.requestAuthorizationIfNeeded()
                }
        } label: {
            MenuBarIcon(progress: timerState.progress, isFocus: timerState.currentPhase.isFocus)
        }
        .menuBarExtraStyle(.window)
    }
}
