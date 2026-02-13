import SwiftUI
import Combine

struct TimerView: View {
    @Bindable var timerState: TimerState
    let notificationManager: NotificationManager
    
    @State private var animationTimer: SmoothAnimationTimer?
    @State private var animationProgress: Double = 0
    @State private var phaseTransitionId = UUID()
    
    var body: some View {
        ZStack {
            // Background gradient based on phase
            PhaseBackground(phase: timerState.currentPhase)
            
            VStack(spacing: 0) {
                // Header with phase name
                PhaseHeader(phase: timerState.currentPhase)
                    .padding(.top, 40)
                
                Spacer()
                
                // Main timer with circular progress
                CircularTimerView(
                    timerState: timerState,
                    animationProgress: animationProgress
                )
                .id(phaseTransitionId)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                    removal: .opacity.combined(with: .scale(scale: 1.05))
                ))
                
                Spacer()
                
                // Session progress dots
                SessionProgressDots(
                    completedSessions: timerState.displayCompletedSessions,
                    phase: timerState.currentPhase
                )
                .padding(.bottom, 24)
                
                // Control button
                ControlButton(isRunning: timerState.isRunning) {
                    timerState.toggle()
                }
                .padding(.bottom, 40)
            }
        }
        .frame(width: 380, height: 480)
        .onAppear {
            setupAnimationTimer()
            animationProgress = timerState.progress
        }
        .onDisappear {
            animationTimer?.invalidate()
        }
        .onChange(of: timerState.currentPhase) { _, _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                phaseTransitionId = UUID()
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            timerState.tick(notificationManager: notificationManager)
        }
    }
    
    private func setupAnimationTimer() {
        animationTimer = SmoothAnimationTimer { [timerState] in
            // Update progress smoothly without animation (timer drives the updates)
            animationProgress = timerState.progress
        }
        animationTimer?.start()
    }
}

// MARK: - Phase Background

struct PhaseBackground: View {
    let phase: TimerState.Phase
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base background color
                (colorScheme == .dark 
                    ? Color.black
                    : Color.white)
                    .ignoresSafeArea()
                
                // Gradient glow
                RadialGradient(
                    colors: [
                        phase.color.opacity(colorScheme == .dark ? 0.15 : 0.08),
                        phase.color.opacity(0)
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: min(geometry.size.width, geometry.size.height) * 0.6
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: phase)
            }
        }
    }
}

// MARK: - Phase Header

struct PhaseHeader: View {
    let phase: TimerState.Phase
    
    var body: some View {
        VStack(spacing: 8) {
            Text(phase.name)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(phase.color)
            
            Text(phaseSubtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .animation(.easeInOut(duration: 0.3), value: phase)
    }
    
    private var phaseSubtitle: String {
        switch phase {
        case .focus:
            return "Deep work session"
        case .shortBreak:
            return "Quick refresh"
        case .longBreak:
            return "Full recharge"
        }
    }
}

// MARK: - Circular Timer View

struct CircularTimerView: View {
    let timerState: TimerState
    let animationProgress: Double
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Outer glow ring
            ProgressRing(
                progress: animationProgress,
                lineWidth: 6,
                color: timerState.currentPhase.color.opacity(0.3)
            )
            .blur(radius: 8)
            .frame(width: 240, height: 240)
            
            // Main progress ring
            ProgressRing(
                progress: animationProgress,
                lineWidth: 12,
                color: timerState.currentPhase.color
            )
            .frame(width: 240, height: 240)
            .shadow(color: timerState.currentPhase.color.opacity(0.4), radius: 10, x: 0, y: 0)
            
            // Timer text
            VStack(spacing: 4) {
                Text(timeString(timerState.secondsRemaining))
                    .font(.system(size: 64, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                
                Text("remaining")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func timeString(_ seconds: Int) -> String {
        let mins = max(seconds, 0) / 60
        let secs = max(seconds, 0) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

// MARK: - Progress Ring

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(color.opacity(0.12), lineWidth: lineWidth)
            
            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color.gradient,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.016), value: progress)
        }
    }
}

// MARK: - Session Progress Dots

struct SessionProgressDots: View {
    let completedSessions: Int
    let phase: TimerState.Phase
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { index in
                SessionDot(
                    isFilled: index < completedSessions,
                    phase: phase,
                    index: index
                )
            }
        }
    }
}

struct SessionDot: View {
    let isFilled: Bool
    let phase: TimerState.Phase
    let index: Int
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Circle()
            .fill(isFilled ? phase.color : Color.secondary.opacity(0.2))
            .frame(width: 10, height: 10)
            .scaleEffect(scale)
            .onChange(of: isFilled) { oldValue, newValue in
                if newValue && !oldValue {
                    // Animate fill
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        scale = 1.4
                    }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.1)) {
                        scale = 1.0
                    }
                }
            }
    }
}

// MARK: - Control Button

struct ControlButton: View {
    let isRunning: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text(isRunning ? "Pause" : "Start")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(width: 140, height: 48)
            .background(
                Capsule()
                    .fill(isRunning 
                        ? Color.orange.gradient 
                        : Color.green.gradient)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.space, modifiers: [])
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Smooth Animation Timer

@MainActor
final class SmoothAnimationTimer: ObservableObject {
    private var timer: Timer?
    private let callback: () -> Void
    
    init(callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    func start() {
        // Use a 60fps timer for smooth animation (16.67ms interval)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.callback()
        }
    }
    
    func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Button Press Effects

struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}
