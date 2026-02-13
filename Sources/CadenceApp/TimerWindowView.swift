import SwiftUI

struct TimerWindowView: View {
    @Bindable var timerState: TimerState
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let notificationManager: NotificationManager

    private let phaseColors: [TimerState.Phase: Color] = [
        .focus: Color(red: 1.0, green: 0.58, blue: 0.0),      // #FF9400
        .shortBreak: Color(red: 0.19, green: 0.84, blue: 0.78), // #30D6C8
        .longBreak: Color(red: 0.35, green: 0.34, blue: 0.84)  // #5957D6
    ]

    var body: some View {
        VStack(spacing: 24) {
            // Phase indicator
            Text(timerState.currentPhase.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(2)

            // Circular progress with timer
            ZStack {
                // Background ring
                Circle()
                    .stroke(
                        timerState.currentPhase.color.opacity(0.15),
                        lineWidth: 8
                    )

                // Progress ring
                Circle()
                    .trim(from: 0, to: timerState.progress)
                    .stroke(
                        timerState.currentPhase.color.gradient,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: timerState.progress)

                // Time display
                VStack(spacing: 4) {
                    Text(timeString(timerState.secondsRemaining))
                        .font(.system(size: 48, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)

                    // Session progress dots
                    HStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { index in
                            Circle()
                                .fill(index < timerState.displayCompletedSessions
                                    ? timerState.currentPhase.color
                                    : Color.secondary.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: timerState.displayCompletedSessions)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .frame(width: 200, height: 200)

            // Controls
            HStack(spacing: 20) {
                // Play/Pause button
                Button(action: { timerState.toggle() }) {
                    Image(systemName: timerState.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(timerState.currentPhase.color.opacity(0.15))
                        )
                        .foregroundColor(timerState.currentPhase.color)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.space, modifiers: [])
                .help(timerState.isRunning ? "Pause (Space)" : "Start (Space)")

                // Reset button
                Button(action: { timerState.reset() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill(Color.secondary.opacity(0.1))
                        )
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("r", modifiers: [.command])
                .help("Reset (Cmd+R)")

                #if DEBUG
                Button(action: { timerState.skipPhase(notificationManager: notificationManager) }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 14))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color.orange.opacity(0.15))
                        )
                        .foregroundColor(.orange)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("s", modifiers: [.option])
                .help("Skip Phase (Opt+S)")
                #endif
            }

            Spacer(minLength: 0)
        }
        .padding(32)
        .frame(width: 280, height: 360)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            timerState.currentPhase.color.opacity(0.03),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .background(.ultraThinMaterial)
        )
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
