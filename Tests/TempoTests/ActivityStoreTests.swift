import CadenceKit
import Foundation
import Testing

@testable import Tempo

@MainActor
@Suite("ActivityStore")
struct ActivityStoreTests {

    private func makeStore() -> ActivityStore {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        return ActivityStore(storageURL: url)
    }

    // MARK: - Adding Activities

    @Test("Adding a focus activity appends to list")
    func addFocusActivity() {
        let store = makeStore()
        store.addFocusActivity("Deep work")

        #expect(store.focusActivities.count == 1)
        #expect(store.focusActivities[0].name == "Deep work")
        #expect(store.focusActivities[0].isRecurring == true)
    }

    @Test("Adding a break activity appends to list")
    func addBreakActivity() {
        let store = makeStore()
        store.addBreakActivity("Stretch")

        #expect(store.breakActivities.count == 1)
        #expect(store.breakActivities[0].name == "Stretch")
    }

    @Test("Adding whitespace-only name is ignored")
    func addWhitespaceIgnored() {
        let store = makeStore()
        store.addFocusActivity("   ")

        #expect(store.focusActivities.isEmpty)
    }

    @Test("Adding empty name is ignored")
    func addEmptyIgnored() {
        let store = makeStore()
        store.addBreakActivity("")

        #expect(store.breakActivities.isEmpty)
    }

    @Test("Name is trimmed on add")
    func nameIsTrimmed() {
        let store = makeStore()
        store.addFocusActivity("  Code review  ")

        #expect(store.focusActivities[0].name == "Code review")
    }

    // MARK: - Auto-Selection on First Add

    @Test("First focus activity auto-selected as current")
    func firstFocusAutoSelected() {
        let store = makeStore()
        store.addFocusActivity("Write tests")

        #expect(store.currentFocusActivity?.name == "Write tests")
    }

    @Test("First break activity auto-selected as current")
    func firstBreakAutoSelected() {
        let store = makeStore()
        store.addBreakActivity("Walk")

        #expect(store.currentBreakActivity?.name == "Walk")
    }

    @Test("Second add does not override current selection")
    func secondAddPreservesCurrent() {
        let store = makeStore()
        store.addFocusActivity("First")
        let firstActivity = store.currentFocusActivity
        store.addFocusActivity("Second")

        #expect(store.currentFocusActivity == firstActivity)
    }

    // MARK: - Removing Activities

    @Test("Remove activity removes from list")
    func removeFromList() {
        let store = makeStore()
        store.addFocusActivity("Temporary")
        let activity = store.focusActivities[0]
        store.removeActivity(activity)

        #expect(store.focusActivities.isEmpty)
    }

    @Test("Removing current focus activity re-picks")
    func removeCurrentFocusRepicks() {
        let store = makeStore()
        store.addFocusActivity("One")
        store.addFocusActivity("Two")
        let current = store.currentFocusActivity!
        store.removeActivity(current)

        #expect(store.focusActivities.count == 1)
        #expect(store.currentFocusActivity != nil)
    }

    @Test("Removing last activity sets current to nil")
    func removeLastSetsNil() {
        let store = makeStore()
        store.addFocusActivity("Only one")
        let activity = store.focusActivities[0]
        store.removeActivity(activity)

        #expect(store.currentFocusActivity == nil)
    }

    // MARK: - Toggle Recurring

    @Test("Toggle recurring flips isRecurring")
    func toggleRecurring() {
        let store = makeStore()
        store.addFocusActivity("Task", recurring: true)
        let activity = store.focusActivities[0]

        #expect(activity.isRecurring == true)
        store.toggleRecurring(activity)
        #expect(store.focusActivities[0].isRecurring == false)
    }

    @Test("Toggle syncs current activity cache")
    func toggleSyncsCurrentCache() {
        let store = makeStore()
        store.addFocusActivity("Task", recurring: true)

        #expect(store.currentFocusActivity?.isRecurring == true)
        store.toggleRecurring(store.focusActivities[0])
        #expect(store.currentFocusActivity?.isRecurring == false)
    }

    // MARK: - Completion Flow

    @Test("Complete one-off removes from list")
    func completeOneOffRemoves() {
        let store = makeStore()
        store.addFocusActivity("One-off task", recurring: false)

        store.completeCurrentActivity(for: .focus)

        #expect(store.focusActivities.isEmpty)
    }

    @Test("Complete recurring does not remove from list")
    func completeRecurringKeeps() {
        let store = makeStore()
        store.addFocusActivity("Daily standup", recurring: true)

        store.completeCurrentActivity(for: .focus)

        #expect(store.focusActivities.count == 1)
    }

    // MARK: - Phase Activity Lookup

    @Test("currentActivity returns focus for focus phase")
    func currentActivityFocusPhase() {
        let store = makeStore()
        store.addFocusActivity("Code")
        store.addBreakActivity("Rest")

        let activity = store.currentActivity(for: .focus)
        #expect(activity?.name == "Code")
    }

    @Test("currentActivity returns break for short break phase")
    func currentActivityBreakPhase() {
        let store = makeStore()
        store.addFocusActivity("Code")
        store.addBreakActivity("Rest")

        let activity = store.currentActivity(for: .shortBreak)
        #expect(activity?.name == "Rest")
    }

    // MARK: - Move Activities

    @Test("Move focus activity reorders list")
    func moveFocusActivity() {
        let store = makeStore()
        store.addFocusActivity("First")
        store.addFocusActivity("Second")
        store.addFocusActivity("Third")

        store.moveFocusActivity(from: IndexSet(integer: 0), to: 3)

        #expect(store.focusActivities[0].name == "Second")
        #expect(store.focusActivities[1].name == "Third")
        #expect(store.focusActivities[2].name == "First")
    }

    @Test("Move break activity reorders list")
    func moveBreakActivity() {
        let store = makeStore()
        store.addBreakActivity("A")
        store.addBreakActivity("B")

        store.moveBreakActivity(from: IndexSet(integer: 1), to: 0)

        #expect(store.breakActivities[0].name == "B")
        #expect(store.breakActivities[1].name == "A")
    }

    // MARK: - Pick Activity

    @Test("pickActivity selects from pool")
    func pickActivitySelects() {
        let store = makeStore()
        store.addFocusActivity("Only option")

        store.pickActivity(for: .focus)

        #expect(store.currentFocusActivity?.name == "Only option")
    }

    @Test("pickActivity with empty pool sets nil")
    func pickActivityEmptyPool() {
        let store = makeStore()

        store.pickActivity(for: .focus)

        #expect(store.currentFocusActivity == nil)
    }

    // MARK: - Persistence Round-Trip

    @Test("Activities persist and reload")
    func persistenceRoundTrip() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")

        let store1 = ActivityStore(storageURL: url)
        store1.addFocusActivity("Persisted task")
        store1.addBreakActivity("Persisted break")

        let store2 = ActivityStore(storageURL: url)
        #expect(store2.focusActivities.count == 1)
        #expect(store2.focusActivities[0].name == "Persisted task")
        #expect(store2.breakActivities.count == 1)
        #expect(store2.breakActivities[0].name == "Persisted break")

        try? FileManager.default.removeItem(at: url)
    }
}
