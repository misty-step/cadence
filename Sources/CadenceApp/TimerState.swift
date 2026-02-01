import AppKit
import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class TimerState {
    enum Phase {
        case focus
        case shortBreak
        case longBreak

        var name: String {
            switch self {
            case .focus: return "Focus"
            case .shortBreak: return "Short Break"
            case .longBreak: return "Long Break"
            }
        }

        var duration: Int {
            switch self {
            case .focus: return 25 * 60
            case .shortBreak: return 5 * 60
            case .longBreak: return 15 * 60
            }
        }

        var isFocus: Bool {
            switch self {
            case .focus: return true
            case .shortBreak, .longBreak: return false
            }
        }

        var sfSymbol: String {
            switch self {
            case .focus: return "circle.fill"
            case .shortBreak: return "circle.bottomhalf.filled"
            case .longBreak: return "circle.dashed"
            }
        }

        var color: Color {
            switch self {
            case .focus: return Color(red: 1.0, green: 0.58, blue: 0.0)
            case .shortBreak: return Color(red: 0.19, green: 0.84, blue: 0.78)
            case .longBreak: return Color(red: 0.35, green: 0.34, blue: 0.84)
            }
        }

        var nsColor: NSColor {
            switch self {
            case .focus: return NSColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0)
            case .shortBreak: return NSColor(red: 0.19, green: 0.84, blue: 0.78, alpha: 1.0)
            case .longBreak: return NSColor(red: 0.35, green: 0.34, blue: 0.84, alpha: 1.0)
            }
        }

        var notificationBody: String {
            switch self {
            case .focus: return "Time to focus."
            case .shortBreak: return "Quick break. Stretch."
            case .longBreak: return "Cycle complete. Step away."
            }
        }

        var systemSound: String {
            switch self {
            case .focus: return "Ping"
            case .shortBreak: return "Glass"
            case .longBreak: return "Hero"
            }
        }
    }

    var currentPhase: Phase = .focus
    var secondsRemaining: Int = Phase.focus.duration
    var isRunning: Bool = false
    var completedFocusSessions: Int = 0
    var displayCompletedSessions: Int {
        if currentPhase == .longBreak {
            return 4
        }
        return completedFocusSessions
    }

    var totalSeconds: Int { currentPhase.duration }
    var progress: Double {
        let elapsed = totalSeconds - secondsRemaining
        if totalSeconds == 0 { return 0 }
        return min(max(Double(elapsed) / Double(totalSeconds), 0), 1)
    }

    func start() { isRunning = true }
    func pause() { isRunning = false }
    func toggle() { isRunning ? pause() : start() }

    func reset() {
        isRunning = false
        currentPhase = .focus
        secondsRemaining = Phase.focus.duration
        completedFocusSessions = 0
    }

    #if DEBUG
    func skipPhase(notificationManager: NotificationManager) {
        secondsRemaining = 0
        advancePhase(notificationManager: notificationManager)
    }
    #endif

    func tick(notificationManager: NotificationManager) {
        guard isRunning else { return }
        if secondsRemaining > 0 {
            secondsRemaining -= 1
        }
        if secondsRemaining == 0 {
            advancePhase(notificationManager: notificationManager)
        }
    }

    private func advancePhase(notificationManager: NotificationManager) {
        let next: Phase
        switch currentPhase {
        case .focus:
            completedFocusSessions += 1
            if completedFocusSessions >= 4 {
                next = .longBreak
                completedFocusSessions = 0
            } else {
                next = .shortBreak
            }
        case .shortBreak, .longBreak:
            next = .focus
        }

        currentPhase = next
        secondsRemaining = next.duration
        notificationManager.notify(phase: next)
        isRunning = true
    }
}
