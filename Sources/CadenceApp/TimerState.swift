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
            case .focus: return DesignSystem.Colors.focus
            case .shortBreak: return DesignSystem.Colors.shortBreak
            case .longBreak: return DesignSystem.Colors.longBreak
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

    // MARK: - Cycle

    private struct CycleStep {
        let phase: Phase
        let completedFocusSessions: Int
    }

    private static let cycleMap: [CycleStep] = [
        .init(phase: .focus, completedFocusSessions: 0),
        .init(phase: .shortBreak, completedFocusSessions: 1),
        .init(phase: .focus, completedFocusSessions: 1),
        .init(phase: .shortBreak, completedFocusSessions: 2),
        .init(phase: .focus, completedFocusSessions: 2),
        .init(phase: .shortBreak, completedFocusSessions: 3),
        .init(phase: .focus, completedFocusSessions: 3),
        .init(phase: .longBreak, completedFocusSessions: 0)
    ]

    var cycleIndex: Int {
        let maxIndex = Self.cycleMap.count - 1
        switch currentPhase {
        case .longBreak:
            return maxIndex
        case .shortBreak:
            let index = completedFocusSessions * 2 - 1
            return min(max(index, 0), maxIndex)
        case .focus:
            let index = completedFocusSessions * 2
            return min(max(index, 0), maxIndex)
        }
    }

    func jumpToPhase(_ index: Int) {
        guard Self.cycleMap.indices.contains(index) else { return }
        pause()
        let step = Self.cycleMap[index]
        currentPhase = step.phase
        completedFocusSessions = step.completedFocusSessions
        secondsRemaining = step.phase.duration
    }

    func resetCurrentPhase() {
        pause()
        secondsRemaining = currentPhase.duration
    }

    struct CycleSegment: Sendable {
        let phase: Phase
        let cycleIndex: Int
        var isActive: Bool
        var isCompleted: Bool
        var progressFraction: Double
    }

    var cycleSegments: [CycleSegment] {
        let current = cycleIndex
        return Self.cycleMap.enumerated().map { idx, entry in
            CycleSegment(
                phase: entry.phase,
                cycleIndex: idx,
                isActive: idx == current,
                isCompleted: idx < current,
                progressFraction: idx == current ? progress : (idx < current ? 1.0 : 0)
            )
        }
    }

    private var backgroundTimer: Timer?
    private let notificationManager: NotificationManager

    init(notificationManager: NotificationManager = NotificationManager()) {
        self.notificationManager = notificationManager
    }

    func start() {
        isRunning = true
        startBackgroundTimer()
    }

    func pause() {
        isRunning = false
        stopBackgroundTimer()
    }

    private func startBackgroundTimer() {
        stopBackgroundTimer()
        backgroundTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.tick(notificationManager: self.notificationManager)
            }
        }
    }

    private func stopBackgroundTimer() {
        backgroundTimer?.invalidate()
        backgroundTimer = nil
    }

    func toggle() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }

    func reset() {
        stopBackgroundTimer()
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
