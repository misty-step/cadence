import Foundation
import Observation
import os

@MainActor
@Observable
public final class ActivityStore {
    private static let logger = Logger(subsystem: "com.cadence.tempo", category: "ActivityStore")

    public var focusActivities: [Activity] = []
    public var breakActivities: [Activity] = []
    private let storageURL: URL

    public init(storageURL: URL? = nil) {
        self.storageURL = storageURL ?? Self.defaultFileURL
        load()
    }

    // MARK: - Current Activity

    public private(set) var currentFocusActivity: Activity?
    public private(set) var currentBreakActivity: Activity?

    public func currentActivity(for phase: TimerState.Phase) -> Activity? {
        phase.isFocus ? currentFocusActivity : currentBreakActivity
    }

    // MARK: - Phase Transitions

    public func phaseCompleted(_ phase: TimerState.Phase) {
        // One-offs survive phase transitions — require explicit completion
        save()
    }

    public func completeCurrentActivity(for phase: TimerState.Phase) {
        if phase.isFocus, let done = currentFocusActivity, !done.isRecurring {
            focusActivities.removeAll { $0.id == done.id }
            save()
        } else if !phase.isFocus, let done = currentBreakActivity, !done.isRecurring {
            breakActivities.removeAll { $0.id == done.id }
            save()
        }
        pickActivity(for: phase)
    }

    public func pickActivity(for phase: TimerState.Phase) {
        if phase.isFocus {
            currentFocusActivity = focusActivities.randomElement()
        } else {
            currentBreakActivity = breakActivities.randomElement()
        }
    }

    // MARK: - Mutations

    public func addFocusActivity(_ name: String, recurring: Bool = true) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let activity = Activity(name: trimmed, isRecurring: recurring)
        focusActivities.append(activity)
        if currentFocusActivity == nil {
            currentFocusActivity = activity
        }
        save()
    }

    public func addBreakActivity(_ name: String, recurring: Bool = true) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let activity = Activity(name: trimmed, isRecurring: recurring)
        breakActivities.append(activity)
        if currentBreakActivity == nil {
            currentBreakActivity = activity
        }
        save()
    }

    public func removeActivity(_ activity: Activity) {
        let removedFocus = currentFocusActivity?.id == activity.id
        let removedBreak = currentBreakActivity?.id == activity.id
        focusActivities.removeAll { $0.id == activity.id }
        breakActivities.removeAll { $0.id == activity.id }
        if removedFocus {
            currentFocusActivity = focusActivities.randomElement()
        }
        if removedBreak {
            currentBreakActivity = breakActivities.randomElement()
        }
        save()
    }

    public func toggleRecurring(_ activity: Activity) {
        if let idx = focusActivities.firstIndex(where: { $0.id == activity.id }) {
            focusActivities[idx].isRecurring.toggle()
            if currentFocusActivity?.id == activity.id {
                currentFocusActivity = focusActivities[idx]
            }
        } else if let idx = breakActivities.firstIndex(where: { $0.id == activity.id }) {
            breakActivities[idx].isRecurring.toggle()
            if currentBreakActivity?.id == activity.id {
                currentBreakActivity = breakActivities[idx]
            }
        }
        save()
    }

    public func moveFocusActivity(from source: IndexSet, to destination: Int) {
        focusActivities.move(fromOffsets: source, toOffset: destination)
        save()
    }

    public func moveBreakActivity(from source: IndexSet, to destination: Int) {
        breakActivities.move(fromOffsets: source, toOffset: destination)
        save()
    }

    // MARK: - Persistence

    private static var defaultFileURL: URL {
        guard let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first else {
            fatalError("Could not locate Application Support directory.")
        }
        let dir = appSupport.appendingPathComponent("Cadence", isDirectory: true)
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
            try data.write(to: storageURL, options: .atomic)
        } catch {
            Self.logger.error("Failed to save activities: \(error.localizedDescription)")
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        do {
            let data = try Data(contentsOf: storageURL)
            let stored = try JSONDecoder().decode(StoredData.self, from: data)
            focusActivities = stored.focusActivities
            breakActivities = stored.breakActivities
            currentFocusActivity = focusActivities.randomElement()
            currentBreakActivity = breakActivities.randomElement()
        } catch {
            Self.logger.error("Failed to load activities: \(error.localizedDescription)")
        }
    }
}
