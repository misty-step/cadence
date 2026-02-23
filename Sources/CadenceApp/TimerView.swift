import AppKit
import CoreImage
import SwiftUI

// MARK: - Gradient Background

struct GradientBackground: View {
    let phase: TimerState.Phase
    @Environment(\.colorScheme) var scheme

    var body: some View {
        DesignSystem.Gradients.background(for: phase, scheme: scheme)
            .ignoresSafeArea()
            .animation(DesignSystem.Animation.gradientTransition, value: phase)
    }
}

// MARK: - Grain Overlay

struct GrainOverlay: View {
    private static let noiseImage: NSImage = {
        let size = CGRect(x: 0, y: 0, width: 400, height: 500)
        guard let randomFilter = CIFilter(name: "CIRandomGenerator"),
              let output = randomFilter.outputImage else { return NSImage() }
        let cropped = output.cropped(to: size)
        guard let cgImage = CIContext().createCGImage(cropped, from: size) else { return NSImage() }
        return NSImage(cgImage: cgImage, size: NSSize(width: 400, height: 500))
    }()

    var body: some View {
        Image(nsImage: Self.noiseImage)
            .resizable()
            .opacity(DesignSystem.Opacity.grainOverlay)
            .allowsHitTesting(false)
            .drawingGroup()
    }
}

// MARK: - Phase Label

struct PhaseLabel: View {
    let phase: TimerState.Phase

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(phase.name.uppercased())
                .font(DesignSystem.Typography.phaseLabel())
                .tracking(1.8)
                .foregroundStyle(phase.color.opacity(DesignSystem.Opacity.phaseLabelColor))
            Rectangle()
                .fill(phase.color)
                .frame(width: 20, height: 1.5)
                .opacity(DesignSystem.Opacity.underlineAccent)
        }
        .animation(DesignSystem.Animation.uiUpdate, value: phase)
    }
}

// MARK: - Time Display

struct TimeDisplay: View {
    let secondsRemaining: Int

    var body: some View {
        Text(formatted(secondsRemaining))
            .font(DesignSystem.Typography.timeDisplay())
            .monospacedDigit()
            .contentTransition(.numericText())
    }

    private func formatted(_ seconds: Int) -> String {
        let s = max(seconds, 0)
        return String(format: "%02d:%02d", s / 60, s % 60)
    }
}

// MARK: - Press Events Modifier

struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    @State private var pressing = false

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !pressing else { return }
                        pressing = true
                        onPress()
                    }
                    .onEnded { _ in
                        pressing = false
                        onRelease()
                    }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

// MARK: - Cadence Button

struct CadenceButton: View {
    let isRunning: Bool
    let phase: TimerState.Phase
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(isRunning ? "Pause" : "Start")
                .font(DesignSystem.Typography.buttonLabel())
                .foregroundStyle(phase.color)
                .padding(.horizontal, 44)
                .padding(.vertical, 13)
                .background(Capsule().fill(phase.color.opacity(DesignSystem.Opacity.buttonBackground)))
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.space, modifiers: [])
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(DesignSystem.Animation.buttonPress, value: isPressed)
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
    }
}

// MARK: - Timeline Segment

struct TimelineSegment: View {
    enum SegmentState { case active, completed, upcoming }

    let index: Int
    let phase: TimerState.Phase
    let state: SegmentState
    let progress: Double
    let width: CGFloat

    private var opacity: Double {
        switch state {
        case .active:    return DesignSystem.Opacity.timelineActive
        case .completed: return DesignSystem.Opacity.timelineCompleted
        case .upcoming:  return DesignSystem.Opacity.timelineUpcoming
        }
    }

    private var height: CGFloat {
        state == .active
            ? DesignSystem.Spacing.timelineHeightActive
            : DesignSystem.Spacing.timelineHeightInactive
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(phase.color.opacity(opacity))
                .frame(width: width, height: height)
            if state == .active && progress > 0 {
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: width * progress, height: height)
            }
        }
        .frame(width: width, height: DesignSystem.Spacing.timelineHeightActive, alignment: .center)
        .animation(DesignSystem.Animation.timelineHover, value: state)
    }
}

// MARK: - Phase Timeline

struct PhaseTimeline: View {
    @Bindable var timerState: TimerState

    // Proportional durations (minutes): focus=25, short=5, long=15. Total=130
    private static let durations: [CGFloat] = [25, 5, 25, 5, 25, 5, 25, 15]
    private static let totalDuration: CGFloat = durations.reduce(0, +)

    private func segmentPhase(at index: Int) -> TimerState.Phase {
        switch index {
        case 1, 3, 5: return .shortBreak
        case 7:        return .longBreak
        default:       return .focus
        }
    }

    private func segmentState(at index: Int) -> TimelineSegment.SegmentState {
        let current = timerState.cycleIndex
        if index == current { return .active }
        if index < current  { return .completed }
        return .upcoming
    }

    var body: some View {
        GeometryReader { geo in
            let totalGap = DesignSystem.Spacing.timelineGap * 7
            let available = geo.size.width - totalGap
            HStack(spacing: DesignSystem.Spacing.timelineGap) {
                ForEach(0..<8, id: \.self) { idx in
                    let segWidth = available * (Self.durations[idx] / Self.totalDuration)
                    TimelineSegment(
                        index: idx,
                        phase: segmentPhase(at: idx),
                        state: segmentState(at: idx),
                        progress: idx == timerState.cycleIndex ? timerState.progress : 0,
                        width: segWidth
                    )
                    .onTapGesture {
                        withAnimation(DesignSystem.Animation.uiUpdate) {
                            if idx == timerState.cycleIndex {
                                timerState.resetCurrentPhase()
                            } else {
                                timerState.jumpToPhase(idx)
                            }
                        }
                    }
                }
            }
        }
        .frame(height: DesignSystem.Spacing.timelineHeightActive)
    }
}

// MARK: - Timer View

struct TimerView: View {
    @Bindable var timerState: TimerState
    let notificationManager: NotificationManager

    var body: some View {
        ZStack {
            GradientBackground(phase: timerState.currentPhase)
            GrainOverlay()

            VStack {
                HStack(alignment: .center) {
                    PhaseLabel(phase: timerState.currentPhase)
                    Spacer()
                }
                .padding(.top, DesignSystem.Spacing.headerTop)
                .padding(.horizontal, DesignSystem.Spacing.headerSideInset)
                Spacer()
            }

            VStack {
                HStack {
                    Spacer()
                    TimeDisplay(secondsRemaining: timerState.secondsRemaining)
                        .padding(.trailing, DesignSystem.Spacing.timeRightPadding)
                }
                .padding(.leading, DesignSystem.Spacing.timeLeftInset)
                .padding(.top, DesignSystem.Spacing.timeTop)
                Spacer()
            }

            VStack(spacing: 0) {
                Spacer()
                CadenceButton(
                    isRunning: timerState.isRunning,
                    phase: timerState.currentPhase
                ) { timerState.toggle() }
                .padding(.bottom, DesignSystem.Spacing.buttonBottom)

                PhaseTimeline(timerState: timerState)
                    .padding(.horizontal, DesignSystem.Spacing.timelineSideInset)
                    .padding(.bottom, DesignSystem.Spacing.timelineBottom)
            }
        }
        .frame(
            width: DesignSystem.Spacing.windowWidth,
            height: DesignSystem.Spacing.windowHeight
        )
    }
}
