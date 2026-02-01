import SwiftUI

struct MenuBarView: View {
    @Bindable var timerState: TimerState
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let notificationManager: NotificationManager

    var body: some View {
        VStack(spacing: 16) {
            Text(timerState.currentPhase.name)
                .font(.headline)

            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index < timerState.displayCompletedSessions ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }

            Text(timeString(timerState.secondsRemaining))
                .font(.system(size: 32, weight: .semibold, design: .monospaced))

            Button(timerState.isRunning ? "Pause" : "Start") {
                timerState.toggle()
            }
            .keyboardShortcut(.space, modifiers: [])
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

#if DEBUG
            Button("Skip Phase") {
                timerState.skipPhase(notificationManager: notificationManager)
            }
            .keyboardShortcut("s", modifiers: [.option])
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
#endif

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
