import Testing

@testable import CadenceApp

@Suite("TimerState")
@MainActor
struct TimerStateTests {
    private let notifications = NotificationManager()

    // MARK: - Initial State

    @Test func initialState() {
        let state = TimerState()
        #expect(state.currentPhase == .focus)
        #expect(state.secondsRemaining == 25 * 60)
        #expect(state.isRunning == false)
        #expect(state.completedFocusSessions == 0)
    }

    // MARK: - Start / Pause / Toggle

    @Test func startSetsRunning() {
        let state = TimerState()
        state.start()
        #expect(state.isRunning == true)
    }

    @Test func pauseClearsRunning() {
        let state = TimerState()
        state.start()
        state.pause()
        #expect(state.isRunning == false)
    }

    @Test func toggleFlipsRunning() {
        let state = TimerState()
        state.toggle()
        #expect(state.isRunning == true)
        state.toggle()
        #expect(state.isRunning == false)
    }

    // MARK: - Tick

    @Test func tickDecrementsWhenRunning() {
        let state = TimerState()
        state.start()
        let before = state.secondsRemaining
        state.tick(notificationManager: notifications)
        #expect(state.secondsRemaining == before - 1)
    }

    @Test func tickDoesNothingWhenPaused() {
        let state = TimerState()
        let before = state.secondsRemaining
        state.tick(notificationManager: notifications)
        #expect(state.secondsRemaining == before)
    }

    // MARK: - advancePhase: Focus -> Short Break (sessions 1-3)

    @Test func focusToShortBreakOnSessions1Through3() {
        for session in 0..<3 {
            let state = TimerState()
            state.completedFocusSessions = session
            state.start()
            state.secondsRemaining = 1
            state.tick(notificationManager: notifications)

            #expect(state.currentPhase == .shortBreak,
                    "After session \(session + 1), expected shortBreak")
            #expect(state.secondsRemaining == 5 * 60)
            #expect(state.completedFocusSessions == session + 1)
            #expect(state.isRunning == true)
        }
    }

    // MARK: - advancePhase: Focus -> Long Break (4th session)

    @Test func focusToLongBreakAfter4thSession() {
        let state = TimerState()
        state.completedFocusSessions = 3
        state.start()
        state.secondsRemaining = 1
        state.tick(notificationManager: notifications)

        #expect(state.currentPhase == .longBreak)
        #expect(state.secondsRemaining == 15 * 60)
        #expect(state.completedFocusSessions == 0, "Should reset after long break")
        #expect(state.isRunning == true)
    }

    // MARK: - advancePhase: Short Break -> Focus

    @Test func shortBreakToFocus() {
        let state = TimerState()
        state.completedFocusSessions = 1
        state.start()
        state.secondsRemaining = 1
        state.tick(notificationManager: notifications) // focus -> shortBreak

        state.secondsRemaining = 1
        state.tick(notificationManager: notifications) // shortBreak -> focus

        #expect(state.currentPhase == .focus)
        #expect(state.secondsRemaining == 25 * 60)
    }

    // MARK: - advancePhase: Long Break -> Focus

    @Test func longBreakToFocus() {
        let state = TimerState()
        state.completedFocusSessions = 3
        state.start()
        state.secondsRemaining = 1
        state.tick(notificationManager: notifications) // focus -> longBreak

        state.secondsRemaining = 1
        state.tick(notificationManager: notifications) // longBreak -> focus

        #expect(state.currentPhase == .focus)
        #expect(state.secondsRemaining == 25 * 60)
        #expect(state.completedFocusSessions == 0)
    }

    // MARK: - Full Pomodoro Cycle

    @Test func fullCycleOf4SessionsReachesLongBreak() {
        let state = TimerState()
        state.start()

        for session in 1...4 {
            state.secondsRemaining = 1
            state.tick(notificationManager: notifications)

            if session < 4 {
                #expect(state.currentPhase == .shortBreak,
                        "Session \(session): expected shortBreak")
                state.secondsRemaining = 1
                state.tick(notificationManager: notifications)
                #expect(state.currentPhase == .focus,
                        "After break \(session): expected focus")
            } else {
                #expect(state.currentPhase == .longBreak,
                        "Session 4: expected longBreak")
            }
        }

        #expect(state.completedFocusSessions == 0, "Reset after long break")
    }

    // MARK: - Reset

    @Test func resetRestoresInitialState() {
        let state = TimerState()
        state.start()
        state.secondsRemaining = 1
        state.tick(notificationManager: notifications)
        state.completedFocusSessions = 2

        state.reset()

        #expect(state.currentPhase == .focus)
        #expect(state.secondsRemaining == 25 * 60)
        #expect(state.isRunning == false)
        #expect(state.completedFocusSessions == 0)
    }

    // MARK: - Progress

    @Test func progressCalculation() {
        let state = TimerState()
        #expect(state.progress == 0.0)

        state.start()
        state.secondsRemaining = state.totalSeconds / 2
        let halfway = state.progress
        #expect(halfway > 0.49 && halfway < 0.51)
    }

    // MARK: - Display Sessions

    @Test func displaySessionsShowsFourDuringLongBreak() {
        let state = TimerState()
        state.completedFocusSessions = 3
        state.start()
        state.secondsRemaining = 1
        state.tick(notificationManager: notifications)

        #expect(state.currentPhase == .longBreak)
        #expect(state.displayCompletedSessions == 4,
                "During long break, display should show 4")
    }

    @Test func displaySessionsMatchesCompletedOutsideLongBreak() {
        let state = TimerState()
        state.completedFocusSessions = 2
        #expect(state.displayCompletedSessions == 2)
    }

    // MARK: - Phase Properties

    @Test func phaseDurations() {
        #expect(TimerState.Phase.focus.duration == 25 * 60)
        #expect(TimerState.Phase.shortBreak.duration == 5 * 60)
        #expect(TimerState.Phase.longBreak.duration == 15 * 60)
    }

    @Test func phaseIsFocus() {
        #expect(TimerState.Phase.focus.isFocus == true)
        #expect(TimerState.Phase.shortBreak.isFocus == false)
        #expect(TimerState.Phase.longBreak.isFocus == false)
    }

    // MARK: - Cycle Index

    @Test func cycleIndexComputedCorrectly() {
        let state = TimerState()
        state.currentPhase = .focus
        state.completedFocusSessions = 0
        #expect(state.cycleIndex == 0)

        state.currentPhase = .shortBreak
        state.completedFocusSessions = 1
        #expect(state.cycleIndex == 1)

        state.currentPhase = .focus
        state.completedFocusSessions = 1
        #expect(state.cycleIndex == 2)

        state.currentPhase = .shortBreak
        state.completedFocusSessions = 2
        #expect(state.cycleIndex == 3)

        state.currentPhase = .focus
        state.completedFocusSessions = 3
        #expect(state.cycleIndex == 6)

        state.currentPhase = .longBreak
        state.completedFocusSessions = 0
        #expect(state.cycleIndex == 7)
    }

    @Test func jumpToPhaseUpdatesState() {
        let state = TimerState()
        state.jumpToPhase(3)
        #expect(state.currentPhase == .shortBreak)
        #expect(state.completedFocusSessions == 2)
        #expect(state.secondsRemaining == TimerState.Phase.shortBreak.duration)
        #expect(state.isRunning == false)
    }

    @Test func jumpToPhaseOutOfBoundsIsNoOp() {
        let state = TimerState()
        let phase = state.currentPhase
        let seconds = state.secondsRemaining
        state.jumpToPhase(-1)
        #expect(state.currentPhase == phase)
        #expect(state.secondsRemaining == seconds)
        state.jumpToPhase(8)
        #expect(state.currentPhase == phase)
        #expect(state.secondsRemaining == seconds)
    }

    @Test func resetCurrentPhaseResetsSeconds() {
        let state = TimerState()
        state.start()
        state.secondsRemaining = 100
        state.resetCurrentPhase()
        #expect(state.secondsRemaining == TimerState.Phase.focus.duration)
        #expect(state.isRunning == false)
    }

    @Test func cycleSegmentsCount() {
        let state = TimerState()
        #expect(state.cycleSegments.count == 8)
    }

    @Test func cycleSegmentsActiveIsCurrentIndex() throws {
        let state = TimerState()
        let segments = state.cycleSegments
        let active = segments.filter { $0.isActive }
        try #require(active.count == 1)
        #expect(active[0].cycleIndex == state.cycleIndex)
    }
}
