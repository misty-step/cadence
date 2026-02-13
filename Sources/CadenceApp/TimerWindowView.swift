import SwiftUI

struct TimerWindowView: View {
    @Bindable var timerState: TimerState
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let notificationManager: NotificationManager

    private let focusColor = Color(red: 1.0, green: 0.58, blue: 0.0)        // #FF9400
    private let shortBreakColor = Color(red: 0.19, green: 0.84, blue: 0.78) // #30D6C8
    private let longBreakColor = Color(red: 0.35, green: 0.34, blue: 0.84)   // #5957D6

    private var phaseColor: Color {
        switch timerState.currentPhase {
        case .focus: return focusColor
        case .shortBreak: return shortBreakColor
        case .longBreak: return longBreakColor
        }
    }

    var body: some View {
        ZStack {
            // Background that shifts with phase
            phaseColor.opacity(0.15)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Phase label
                Text(timerState.currentPhase.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(phaseColor)
                    .textCase(.uppercase)
                    .tracking(1.5)

                // Circular progress ring with time
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(phaseColor.opacity(0.2), lineWidth: 8)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: timerState.progress)
                        .stroke(phaseColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: timerState.progress)

                    // Time display
                    Text(timeString(timerState.secondsRemaining))
                        .font(.system(size: 48, weight: .ultraLight, design: .monospaced))
                        .foregroundStyle(.primary)
                }
                .frame(width: 180, height: 180)
                .padding(.vertical, 8)

                // Session progress dots
                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(index < timerState.displayCompletedSessions ? phaseColor : phaseColor.opacity(0.2))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: timerState.displayCompletedSessions)
                    }
                }

                // Controls
                HStack(spacing: 16) {
                    // Play/Pause button
                    Button {
                        timerState.toggle()
                    } label: {
                        Image(systemName: timerState.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(phaseColor)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.space, modifiers: [])

                    // Reset button
                    Button {
                        timerState.reset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16))
                            .foregroundStyle(phaseColor)
                            .frame(width: 40, height: 40)
                            .background(phaseColor.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("r", modifiers: .command)
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
        .frame(width: 280, height: 360)
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
