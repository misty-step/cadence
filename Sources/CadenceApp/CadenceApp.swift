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
            Image(systemName: timerState.isRunning ? "circle.fill" : "circle")
                .foregroundStyle(timerState.currentPhase.isFocus ? .red : .green)
        }
        .menuBarExtraStyle(.window)
    }
}
