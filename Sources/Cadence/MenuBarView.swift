import SwiftUI

struct MenuBarView: View {
    @Bindable var timerState: TimerState
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let notificationManager: NotificationManager

    var body: some View {
        VStack(spacing: 16) {
            Text(timerState.currentPhase.name)
                .font(.headline)

            Text(timeString(timerState.secondsRemaining))
                .font(.system(size: 32, weight: .semibold, design: .monospaced))

            Button(timerState.isRunning ? "Pause" : "Start") {
                timerState.toggle()
            }
            .keyboardShortcut(.space, modifiers: [])
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 200)
        .padding(16)
        .onReceive(timer) { _ in
            timerState.tick(notificationManager: notificationManager)
        }
    }

    private func timeString(_ seconds: Int) -> String {
        let minutes = max(seconds, 0) / 60
        let remaining = max(seconds, 0) % 60
        return String(format: "%02d:%02d", minutes, remaining)
    }
}
