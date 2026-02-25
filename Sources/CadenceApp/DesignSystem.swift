import SwiftUI

enum DesignSystem {
    enum Colors {
        static let focus = Color(red: 1.0, green: 0.58, blue: 0.0)
        static let shortBreak = Color(red: 0.19, green: 0.84, blue: 0.78)
        static let longBreak = Color(red: 0.35, green: 0.34, blue: 0.84)
    }

    enum Gradients {
        private static let focusLight: [Color] = [
            Color(red: 0.992, green: 0.965, blue: 0.925),
            Color(red: 0.996, green: 0.953, blue: 0.886),
            Color(red: 1.0, green: 0.973, blue: 0.941)
        ]
        private static let shortBreakLight: [Color] = [
            Color(red: 0.929, green: 0.980, blue: 0.973),
            Color(red: 0.910, green: 0.980, blue: 0.969),
            Color(red: 0.941, green: 1.0, blue: 0.998)
        ]
        private static let longBreakLight: [Color] = [
            Color(red: 0.957, green: 0.941, blue: 0.996),
            Color(red: 0.929, green: 0.910, blue: 0.992),
            Color(red: 0.973, green: 0.957, blue: 1.0)
        ]
        private static let focusDark: [Color] = [
            Color(red: 0.090, green: 0.063, blue: 0.039),
            Color(red: 0.122, green: 0.082, blue: 0.0),
            Color(red: 0.133, green: 0.098, blue: 0.0)
        ]
        private static let shortBreakDark: [Color] = [
            Color(red: 0.0, green: 0.102, blue: 0.094),
            Color(red: 0.0, green: 0.122, blue: 0.110),
            Color(red: 0.0, green: 0.133, blue: 0.125)
        ]
        private static let longBreakDark: [Color] = [
            Color(red: 0.055, green: 0.031, blue: 0.094),
            Color(red: 0.067, green: 0.043, blue: 0.122),
            Color(red: 0.075, green: 0.051, blue: 0.133)
        ]

        static func colors(for phase: TimerState.Phase, scheme: ColorScheme) -> [Color] {
            switch (phase, scheme) {
            case (.focus, .light):
                return focusLight
            case (.shortBreak, .light):
                return shortBreakLight
            case (.longBreak, .light):
                return longBreakLight
            case (.focus, .dark):
                return focusDark
            case (.shortBreak, .dark):
                return shortBreakDark
            case (.longBreak, .dark):
                return longBreakDark
            @unknown default:
                return focusLight
            }
        }

        static func background(for phase: TimerState.Phase, scheme: ColorScheme) -> LinearGradient {
            LinearGradient(
                colors: colors(for: phase, scheme: scheme),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    enum Typography {
        static func phaseLabel() -> Font { Font.custom("Outfit-Medium", size: 11) }
        static func timeDisplay() -> Font { Font.custom("Outfit-Light", size: 84) }
        static func buttonLabel() -> Font { Font.custom("Outfit-Medium", size: 14) }
    }

    enum Spacing {
        static let windowWidth: CGFloat = 380
        static let windowHeight: CGFloat = 480
        static let headerTop: CGFloat = 44
        static let headerSideInset: CGFloat = 36
        static let timeTop: CGFloat = 160
        static let timeRightPadding: CGFloat = 36
        static let timeLeftInset: CGFloat = 24
        static let buttonBottom: CGFloat = 56
        static let timelineBottom: CGFloat = 14
        static let timelineSideInset: CGFloat = 24
        static let timelineGap: CGFloat = 3
        static let timelineHeightActive: CGFloat = 5
        static let timelineHeightInactive: CGFloat = 2
        static let timelineHitTargetHeight: CGFloat = 24
    }

    enum Opacity {
        static let phaseLabelColor: Double = 0.7
        static let textMuted: Double = 0.45
        static let grainOverlay: Double = 0.04
        static let timelineActive: Double = 1.0
        static let timelineCompleted: Double = 0.4
        static let timelineUpcoming: Double = 0.15
        static let timelineProgress: Double = 0.3
        static let buttonBackground: Double = 0.10
        static let underlineAccent: Double = 0.55
    }

    enum Animation {
        static let gradientTransition = SwiftUI.Animation.easeInOut(duration: 2.0)
        static let uiUpdate = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let buttonPress = SwiftUI.Animation.easeInOut(duration: 0.1)
        static let timelineHover = SwiftUI.Animation.easeInOut(duration: 0.15)
    }
}
