import CadenceKit
import SwiftUI

struct TempoTimerView: View {
    @Bindable var timerState: TimerState
    var activityStore: ActivityStore
    @State private var completedActivity: Activity?
    @State private var completedPhase: TimerState.Phase?
    @State private var undoTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            GradientBackground(phase: timerState.currentPhase)
            GrainOverlay()

            // Header: phase label + current activity
            VStack {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 12) {
                        PhaseLabel(phase: timerState.currentPhase)
                        activityLabel
                    }
                    Spacer()
                }
                .padding(.top, DesignSystem.Spacing.headerTop)
                .padding(.horizontal, DesignSystem.Spacing.headerSideInset)
                Spacer()
            }

            // Time display
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

            // Controls
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
        .animation(DesignSystem.Animation.uiUpdate, value: timerState.currentPhase)
    }

    // MARK: - Activity Label

    @ViewBuilder
    private var activityLabel: some View {
        if let completed = completedActivity {
            // Completed state: strikethrough + undo
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(timerState.currentPhase.color.opacity(0.6))
                    .font(.system(size: 16))
                Text(completed.name)
                    .font(DesignSystem.Typography.activityLabel())
                    .strikethrough()
                    .foregroundStyle(.primary.opacity(0.35))
                Button("Undo") {
                    undoCompletion()
                }
                .font(DesignSystem.Typography.activityAction())
                .foregroundStyle(timerState.currentPhase.color.opacity(0.7))
                .buttonStyle(.plain)
            }
            .transition(.opacity)
        } else if let activity = activityStore.currentActivity(for: timerState.currentPhase) {
            // Normal state
            HStack(spacing: 8) {
                Text(activity.name)
                    .font(DesignSystem.Typography.activityLabel())
                    .foregroundStyle(.primary.opacity(0.55))
                    .contentTransition(.opacity)
                    .onTapGesture {
                        withAnimation(DesignSystem.Animation.uiUpdate) {
                            activityStore.pickActivity(for: timerState.currentPhase)
                        }
                    }
                if !activity.isRecurring {
                    Button {
                        markCompleted(activity)
                    } label: {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(timerState.currentPhase.color.opacity(0.6))
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
            .transition(.opacity)
        }
    }

    // MARK: - Completion Flow

    private func markCompleted(_ activity: Activity) {
        undoTask?.cancel()
        let phase = timerState.currentPhase

        withAnimation(DesignSystem.Animation.uiUpdate) {
            completedActivity = activity
            completedPhase = phase
        }

        undoTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            commitCompletion()
        }
    }

    private func undoCompletion() {
        undoTask?.cancel()
        withAnimation(DesignSystem.Animation.uiUpdate) {
            completedActivity = nil
            completedPhase = nil
        }
    }

    private func commitCompletion() {
        guard completedActivity != nil, let phase = completedPhase else { return }
        withAnimation(DesignSystem.Animation.uiUpdate) {
            completedActivity = nil
            completedPhase = nil
            activityStore.completeCurrentActivity(for: phase)
        }
    }
}
