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
    private enum Constants {
        static let width: CGFloat = 400
        static let height: CGFloat = 500
    }

    private static let noiseImage: NSImage = {
        let size = CGRect(x: 0, y: 0, width: Constants.width, height: Constants.height)
        guard let randomFilter = CIFilter(name: "CIRandomGenerator"),
              let output = randomFilter.outputImage else {
            assertionFailure("Failed to create CIRandomGenerator output image")
            return NSImage()
        }
        let cropped = output.cropped(to: size)
        guard let cgImage = CIContext().createCGImage(cropped, from: size) else {
            assertionFailure("Failed to create CGImage for grain overlay")
            return NSImage()
        }
        return NSImage(cgImage: cgImage, size: NSSize(width: Constants.width, height: Constants.height))
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
    private enum Constants {
        static let stackSpacing: CGFloat = 6
        static let letterTracking: CGFloat = 1.8
        static let underlineWidth: CGFloat = 20
        static let underlineHeight: CGFloat = 1.5
    }

    let phase: TimerState.Phase

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.stackSpacing) {
            Text(phase.name.uppercased())
                .font(DesignSystem.Typography.phaseLabel())
                .tracking(Constants.letterTracking)
                .foregroundStyle(phase.color.opacity(DesignSystem.Opacity.phaseLabelColor))
            Rectangle()
                .fill(phase.color)
                .frame(width: Constants.underlineWidth, height: Constants.underlineHeight)
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
        let clampedSeconds = max(seconds, 0)
        return String(format: "%02d:%02d", clampedSeconds / 60, clampedSeconds % 60)
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
    private enum Constants {
        static let horizontalPadding: CGFloat = 44
        static let verticalPadding: CGFloat = 13
        static let pressedScale: CGFloat = 0.97
    }

    let isRunning: Bool
    let phase: TimerState.Phase
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(isRunning ? "Pause" : "Start")
                .font(DesignSystem.Typography.buttonLabel())
                .foregroundStyle(phase.color)
                .padding(.horizontal, Constants.horizontalPadding)
                .padding(.vertical, Constants.verticalPadding)
                .background(Capsule().fill(phase.color.opacity(DesignSystem.Opacity.buttonBackground)))
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.space, modifiers: [])
        .scaleEffect(isPressed ? Constants.pressedScale : 1.0)
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

    let phase: TimerState.Phase
    let state: SegmentState
    let progress: Double
    let width: CGFloat

    private var opacity: Double {
        switch state {
        case .active: return DesignSystem.Opacity.timelineActive
        case .completed: return DesignSystem.Opacity.timelineCompleted
        case .upcoming: return DesignSystem.Opacity.timelineUpcoming
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
                    .fill(Color.white.opacity(DesignSystem.Opacity.timelineProgress))
                    .frame(width: width * progress, height: height)
            }
        }
        .frame(width: width, height: DesignSystem.Spacing.timelineHeightActive, alignment: .center)
        .frame(width: width, height: DesignSystem.Spacing.timelineHitTargetHeight, alignment: .center)
        .contentShape(Rectangle())
        .animation(DesignSystem.Animation.timelineHover, value: state)
    }
}

// MARK: - Phase Timeline

struct PhaseTimeline: View {
    @Bindable var timerState: TimerState

    var body: some View {
        GeometryReader { geo in
            let segments = timerState.cycleSegments
            let durations = segments.map { CGFloat($0.phase.duration) }
            let totalDuration = max(durations.reduce(0, +), 1)
            let segmentCount = segments.count
            let gapCount = max(0, segmentCount - 1)
            let totalGap = DesignSystem.Spacing.timelineGap * CGFloat(gapCount)
            let available = max(0, geo.size.width - totalGap)

            HStack(spacing: DesignSystem.Spacing.timelineGap) {
                ForEach(segments.indices, id: \.self) { idx in
                    let seg = segments[idx]
                    let segWidth = available * (durations[idx] / totalDuration)
                    TimelineSegment(
                        phase: seg.phase,
                        state: seg.isActive ? .active : (seg.isCompleted ? .completed : .upcoming),
                        progress: seg.progressFraction,
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
        .frame(height: DesignSystem.Spacing.timelineHitTargetHeight)
    }
}

// MARK: - Timer View

struct TimerView: View {
    @Bindable var timerState: TimerState

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
