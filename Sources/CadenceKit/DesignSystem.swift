import SwiftUI

public enum DesignSystem {
    public enum Colors {
        public static let focus = Color(red: 0.89, green: 0.41, blue: 0.04)
        public static let shortBreak = Color(red: 0.0, green: 0.58, blue: 0.53)
        public static let longBreak = Color(red: 0.38, green: 0.34, blue: 0.74)

        public static func primaryText(for scheme: ColorScheme) -> Color {
            switch scheme {
            case .light:
                return Color(red: 0.13, green: 0.12, blue: 0.10)
            case .dark:
                return Color(red: 0.94, green: 0.91, blue: 0.86)
            @unknown default:
                return Color.primary
            }
        }

        public static func secondaryText(for scheme: ColorScheme) -> Color {
            switch scheme {
            case .light:
                return Color(red: 0.37, green: 0.34, blue: 0.29)
            case .dark:
                return Color(red: 0.70, green: 0.66, blue: 0.59)
            @unknown default:
                return Color.secondary
            }
        }

        public static func controlSurface(for phase: TimerState.Phase, scheme: ColorScheme) -> Color {
            switch scheme {
            case .light:
                return phase.color
            case .dark:
                return phase.color.opacity(0.88)
            @unknown default:
                return phase.color
            }
        }

        public static func controlForeground(for phase: TimerState.Phase, scheme: ColorScheme) -> Color {
            switch scheme {
            case .light:
                return Color.white.opacity(0.96)
            case .dark:
                return Color.white.opacity(0.96)
            @unknown default:
                return Color.white
            }
        }
    }

    public enum Gradients {
        private static let focusLight: [Color] = [
            Color(red: 0.975, green: 0.958, blue: 0.930),
            Color(red: 0.982, green: 0.944, blue: 0.895),
            Color(red: 0.965, green: 0.946, blue: 0.918)
        ]
        private static let shortBreakLight: [Color] = [
            Color(red: 0.940, green: 0.970, blue: 0.958),
            Color(red: 0.900, green: 0.958, blue: 0.940),
            Color(red: 0.930, green: 0.965, blue: 0.952)
        ]
        private static let longBreakLight: [Color] = [
            Color(red: 0.950, green: 0.940, blue: 0.972),
            Color(red: 0.925, green: 0.910, blue: 0.958),
            Color(red: 0.952, green: 0.942, blue: 0.975)
        ]
        private static let focusDark: [Color] = [
            Color(red: 0.095, green: 0.074, blue: 0.052),
            Color(red: 0.190, green: 0.106, blue: 0.030),
            Color(red: 0.118, green: 0.088, blue: 0.060)
        ]
        private static let shortBreakDark: [Color] = [
            Color(red: 0.025, green: 0.095, blue: 0.090),
            Color(red: 0.000, green: 0.150, blue: 0.135),
            Color(red: 0.035, green: 0.105, blue: 0.100)
        ]
        private static let longBreakDark: [Color] = [
            Color(red: 0.065, green: 0.055, blue: 0.105),
            Color(red: 0.110, green: 0.086, blue: 0.175),
            Color(red: 0.080, green: 0.067, blue: 0.120)
        ]

        public static func colors(for phase: TimerState.Phase, scheme: ColorScheme) -> [Color] {
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

        public static func background(for phase: TimerState.Phase, scheme: ColorScheme) -> LinearGradient {
            LinearGradient(
                colors: colors(for: phase, scheme: scheme),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    public enum Typography {
        public static func phaseLabel() -> Font { Font.custom("Outfit-Medium", size: 11) }
        public static func timeDisplay() -> Font { Font.custom("Outfit-Regular", size: 86) }
        public static func buttonLabel() -> Font { Font.custom("Outfit-Medium", size: 14) }
        public static func activityLabel() -> Font { Font.custom("Outfit-Regular", size: 16) }
        public static func activityAction() -> Font { Font.custom("Outfit-Medium", size: 12) }
    }

    public enum Spacing {
        public static let windowWidth: CGFloat = 380
        public static let windowHeight: CGFloat = 480
        public static let headerTop: CGFloat = 30
        public static let headerSideInset: CGFloat = 32
        public static let timeTop: CGFloat = 108
        public static let timeRightPadding: CGFloat = 30
        public static let timeLeftInset: CGFloat = 22
        public static let timelineBottom: CGFloat = 72
        public static let timelineSideInset: CGFloat = 32
        public static let timelineGap: CGFloat = 2
        public static let timelineHeightActive: CGFloat = 8
        public static let timelineHeightInactive: CGFloat = 6
        public static let timelineHitTargetHeight: CGFloat = 18
        public static let editorWidth: CGFloat = 320
        public static let editorHeight: CGFloat = 440
    }

    public enum Opacity {
        public static let textMuted: Double = 0.68
        public static let grainOverlay: Double = 0.025
        public static let timelineActive: Double = 1.0
        public static let timelineCompleted: Double = 0.46
        public static let timelineUpcoming: Double = 0.18
        public static let timelineProgress: Double = 1.0
        public static let underlineAccent: Double = 0.8
    }

    public enum Animation {
        public static let gradientTransition = SwiftUI.Animation.easeInOut(duration: 2.0)
        public static let uiUpdate = SwiftUI.Animation.easeInOut(duration: 0.2)
        public static let buttonPress = SwiftUI.Animation.easeInOut(duration: 0.1)
        public static let timelineHover = SwiftUI.Animation.easeInOut(duration: 0.15)
    }
}
