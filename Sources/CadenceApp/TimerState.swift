import Foundation
import Observation

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
    }

    var currentPhase: Phase = .focus
    var secondsRemaining: Int = Phase.focus.duration
    var isRunning: Bool = false
    var completedFocusSessions: Int = 0

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
