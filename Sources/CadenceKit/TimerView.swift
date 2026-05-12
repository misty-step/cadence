import AppKit
import CoreImage
import SwiftUI

// MARK: - Gradient Background

public struct GradientBackground: View {
    let phase: TimerState.Phase
    @Environment(\.colorScheme) var scheme

    public init(phase: TimerState.Phase) { self.phase = phase }

    public var body: some View {
        DesignSystem.Gradients.background(for: phase, scheme: scheme)
            .ignoresSafeArea()
            .animation(DesignSystem.Animation.gradientTransition, value: phase)
    }
}

// MARK: - Grain Overlay

public struct GrainOverlay: View {
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

    public init() {}

    public var body: some View {
        Image(nsImage: Self.noiseImage)
            .resizable()
            .opacity(DesignSystem.Opacity.grainOverlay)
            .allowsHitTesting(false)
            .drawingGroup()
    }
}

// MARK: - Phase Label

public struct PhaseLabel: View {
    private enum Constants {
        static let stackSpacing: CGFloat = 7
        static let letterTracking: CGFloat = 1.4
        static let underlineWidth: CGFloat = 28
        static let underlineHeight: CGFloat = 2
    }

    let phase: TimerState.Phase
    @Environment(\.colorScheme) private var scheme

    public init(phase: TimerState.Phase) { self.phase = phase }

    public var body: some View {
        VStack(alignment: .leading, spacing: Constants.stackSpacing) {
            Text(phase.name.uppercased())
                .font(DesignSystem.Typography.phaseLabel())
                .tracking(Constants.letterTracking)
                .foregroundStyle(DesignSystem.Colors.secondaryText(for: scheme))
            Rectangle()
                .fill(phase.color)
                .frame(width: Constants.underlineWidth, height: Constants.underlineHeight)
                .opacity(DesignSystem.Opacity.underlineAccent)
        }
        .animation(DesignSystem.Animation.uiUpdate, value: phase)
    }
}

// MARK: - Time Display

public struct TimeDisplay: View {
    let secondsRemaining: Int
    @Environment(\.colorScheme) private var scheme

    public init(secondsRemaining: Int) { self.secondsRemaining = secondsRemaining }

    public var body: some View {
        Text(formatted(secondsRemaining))
            .font(DesignSystem.Typography.timeDisplay())
            .monospacedDigit()
            .foregroundStyle(DesignSystem.Colors.primaryText(for: scheme))
            .contentTransition(.numericText())
    }

    private func formatted(_ seconds: Int) -> String {
        let clampedSeconds = max(seconds, 0)
        return String(format: "%02d:%02d", clampedSeconds / 60, clampedSeconds % 60)
    }
}

// MARK: - Press Events Modifier

public struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    @State private var pressing = false

    public func body(content: Content) -> some View {
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
    public func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

// MARK: - Cadence Button

public struct CadenceButton: View {
    private enum Constants {
        static let horizontalPadding: CGFloat = 46
        static let verticalPadding: CGFloat = 14
        static let labelSpacing: CGFloat = 8
        static let symbolSize: CGFloat = 10
        static let pressedScale: CGFloat = 0.96
    }

    let isRunning: Bool
    let phase: TimerState.Phase
    let action: () -> Void
    @State private var isPressed = false
    @Environment(\.colorScheme) private var scheme

    public init(isRunning: Bool, phase: TimerState.Phase, action: @escaping () -> Void) {
        self.isRunning = isRunning
        self.phase = phase
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.labelSpacing) {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: Constants.symbolSize, weight: .semibold))
                    .contentTransition(.symbolEffect(.replace))
                    .offset(x: isRunning ? 0 : 1)
                Text(isRunning ? "Pause" : "Start")
                    .font(DesignSystem.Typography.buttonLabel())
                    .contentTransition(.opacity)
            }
            .foregroundStyle(DesignSystem.Colors.controlForeground(for: phase, scheme: scheme))
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, Constants.verticalPadding)
            .background(
                Capsule()
                    .fill(DesignSystem.Colors.controlSurface(for: phase, scheme: scheme))
                    .shadow(color: phase.color.opacity(scheme == .light ? 0.24 : 0.30), radius: 18, y: 8)
            )
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.space, modifiers: [])
        .scaleEffect(isPressed ? Constants.pressedScale : 1.0)
        .animation(DesignSystem.Animation.buttonPress, value: isPressed)
        .animation(DesignSystem.Animation.uiUpdate, value: isRunning)
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
    }
}

// MARK: - Timeline Segment

public struct TimelineSegment: View {
    public enum SegmentState { case active, completed, upcoming }

    let phase: TimerState.Phase
    let state: SegmentState
    let progress: Double
    let width: CGFloat

    public init(phase: TimerState.Phase, state: SegmentState, progress: Double, width: CGFloat) {
        self.phase = phase
        self.state = state
        self.progress = progress
        self.width = width
    }

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

    private var trackColor: Color {
        switch state {
        case .completed:
            return phase.color.opacity(opacity)
        case .active:
            return Color.primary.opacity(DesignSystem.Opacity.timelineUpcoming)
        case .upcoming:
            return Color.primary.opacity(opacity)
        }
    }

    private var progressWidth: CGFloat {
        switch state {
        case .active:
            return width * progress
        case .completed:
            return width
        case .upcoming:
            return 0
        }
    }

    private var showsProgressIndicator: Bool {
        switch state {
        case .active:
            return true
        case .completed, .upcoming:
            return false
        }
    }

    private var segmentShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 1,
            bottomLeadingRadius: 1,
            bottomTrailingRadius: 1,
            topTrailingRadius: 1
        )
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            segmentShape
                .fill(trackColor)
                .frame(width: width, height: height)
            if state == .active && progressWidth > 0 {
                segmentShape
                    .fill(phase.color.opacity(DesignSystem.Opacity.timelineProgress))
                    .frame(width: progressWidth, height: height)
            }
            if showsProgressIndicator {
                segmentShape
                    .fill(phase.color)
                    .frame(width: 3, height: height)
            }
        }
        .frame(width: width, height: DesignSystem.Spacing.timelineHitTargetHeight, alignment: .center)
        .contentShape(Rectangle())
        .animation(DesignSystem.Animation.timelineHover, value: state)
        .animation(.linear(duration: 0.2), value: progress)
    }
}

// MARK: - Phase Timeline

public struct PhaseTimeline: View {
    @Bindable var timerState: TimerState

    public init(timerState: TimerState) { self.timerState = timerState }

    public var body: some View {
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
