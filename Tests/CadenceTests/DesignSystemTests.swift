import Testing
@testable import CadenceApp
import SwiftUI

@Suite("DesignSystem")
struct DesignSystemTests {
    @Test func allPhasesHaveDesignTokens() {
        let phases: [TimerState.Phase] = [.focus, .shortBreak, .longBreak]
        for phase in phases {
            _ = phase.color
        }
    }

    @Test func gradientColorsMatchSpec() {
        let phases: [TimerState.Phase] = [.focus, .shortBreak, .longBreak]
        let schemes: [ColorScheme] = [.light, .dark]
        for phase in phases {
            for scheme in schemes {
                _ = DesignSystem.Gradients.background(for: phase, scheme: scheme)
            }
        }
    }

    @Test func spacingTokensArePositive() {
        #expect(DesignSystem.Spacing.windowWidth > 0)
        #expect(DesignSystem.Spacing.windowHeight > 0)
        #expect(DesignSystem.Spacing.timelineHeightActive > DesignSystem.Spacing.timelineHeightInactive)
    }

    @Test func opacityTokensInRange() {
        #expect(DesignSystem.Opacity.grainOverlay > 0 && DesignSystem.Opacity.grainOverlay < 1)
        #expect(DesignSystem.Opacity.timelineActive == 1.0)
        #expect(DesignSystem.Opacity.timelineUpcoming < DesignSystem.Opacity.timelineCompleted)
    }
}
