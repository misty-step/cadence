import CadenceKit
import Foundation
import Observation

@MainActor
@Observable
final class ActivityStore {
    var focusActivities: [Activity] = []
    var breakActivities: [Activity] = []

    init() { load() }

    // MARK: - Current Activity

    private(set) var currentFocusActivity: Activity?
    private(set) var currentBreakActivity: Activity?

    func currentActivity(for phase: TimerState.Phase) -> Activity? {
        phase.isFocus ? currentFocusActivity : currentBreakActivity
    }

    // MARK: - Phase Transitions

    func phaseCompleted(_ phase: TimerState.Phase) {
        // One-offs survive phase transitions — require explicit completion
        save()
    }

    func completeCurrentActivity(for phase: TimerState.Phase) {
        if phase.isFocus, let done = currentFocusActivity, !done.isRecurring {
            focusActivities.removeAll { $0.id == done.id }
            save()
        } else if !phase.isFocus, let done = currentBreakActivity, !done.isRecurring {
            breakActivities.removeAll { $0.id == done.id }
            save()
        }
        pickActivity(for: phase)
    }

    func pickActivity(for phase: TimerState.Phase) {
        if phase.isFocus {
            currentFocusActivity = focusActivities.randomElement()
        } else {
            currentBreakActivity = breakActivities.randomElement()
        }
    }

    // MARK: - Mutations

    func addFocusActivity(_ name: String, recurring: Bool = true) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        focusActivities.append(Activity(name: trimmed, isRecurring: recurring))
        save()
    }

    func addBreakActivity(_ name: String, recurring: Bool = true) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        breakActivities.append(Activity(name: trimmed, isRecurring: recurring))
        save()
    }

    func removeActivity(_ activity: Activity) {
        focusActivities.removeAll { $0.id == activity.id }
        breakActivities.removeAll { $0.id == activity.id }
        save()
    }

    func toggleRecurring(_ activity: Activity) {
        if let idx = focusActivities.firstIndex(where: { $0.id == activity.id }) {
            focusActivities[idx].isRecurring.toggle()
        } else if let idx = breakActivities.firstIndex(where: { $0.id == activity.id }) {
            breakActivities[idx].isRecurring.toggle()
        }
        save()
    }

    func moveFocusActivity(from source: IndexSet, to destination: Int) {
        focusActivities.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func moveBreakActivity(from source: IndexSet, to destination: Int) {
        breakActivities.move(fromOffsets: source, toOffset: destination)
        save()
    }

    // MARK: - Persistence

    private static var fileURL: URL {
        guard let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first else {
            fatalError("Could not locate Application Support directory.")
        }
        let dir = appSupport.appendingPathComponent("Tempo", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("activities.json")
    }

    private struct StoredData: Codable {
        var focusActivities: [Activity]
        var breakActivities: [Activity]
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(
                StoredData(focusActivities: focusActivities, breakActivities: breakActivities)
            )
            try data.write(to: Self.fileURL, options: .atomic)
        } catch {
            #if DEBUG
            print("ActivityStore save error: \(error.localizedDescription)")
            #endif
        }
    }

    private func load() {
        let url = Self.fileURL
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            let stored = try JSONDecoder().decode(StoredData.self, from: data)
            focusActivities = stored.focusActivities
            breakActivities = stored.breakActivities
            currentFocusActivity = focusActivities.randomElement()
            currentBreakActivity = breakActivities.randomElement()
        } catch {
            #if DEBUG
            print("ActivityStore load error: \(error.localizedDescription)")
            #endif
        }
    }
}
