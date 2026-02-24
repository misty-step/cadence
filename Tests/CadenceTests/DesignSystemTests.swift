import AppKit
import SwiftUI
import Testing

@testable import CadenceApp

@Suite("DesignSystem")
@MainActor
struct DesignSystemTests {
    @Test func allPhasesHaveDesignTokens() throws {
        let expected: [(phase: TimerState.Phase, color: Color)] = [
            (.focus, DesignSystem.Colors.focus),
            (.shortBreak, DesignSystem.Colors.shortBreak),
            (.longBreak, DesignSystem.Colors.longBreak)
        ]

        for item in expected {
            let actual = try #require(rgba(item.phase.color))
            let expectedColor = try #require(rgba(item.color))
            #expect(abs(actual.red - expectedColor.red) < 0.001)
            #expect(abs(actual.green - expectedColor.green) < 0.001)
            #expect(abs(actual.blue - expectedColor.blue) < 0.001)
            #expect(actual.alpha > 0)
        }
    }

    @Test func gradientColorsMatchSpec() {
        let phases: [TimerState.Phase] = [.focus, .shortBreak, .longBreak]
        let schemes: [ColorScheme] = [.light, .dark]

        for phase in phases {
            for scheme in schemes {
                let colors = DesignSystem.Gradients.colors(for: phase, scheme: scheme)
                #expect(colors.count == 3)
                if let first = rgba(colors.first), let last = rgba(colors.last) {
                    #expect(first.alpha > 0)
                    #expect(last.alpha > 0)
                }
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

    private struct RGBA {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat
    }

    private func rgba(_ color: Color?) -> RGBA? {
        guard let color else { return nil }
        guard let nsColor = NSColor(color).usingColorSpace(.sRGB) else { return nil }
        return RGBA(
            red: nsColor.redComponent,
            green: nsColor.greenComponent,
            blue: nsColor.blueComponent,
            alpha: nsColor.alphaComponent
        )
    }
}
