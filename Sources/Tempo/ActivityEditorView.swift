import CadenceKit
import SwiftUI

struct ActivityEditorView: View {
    var store: ActivityStore
    @State private var newFocusName = ""
    @State private var newBreakName = ""

    var body: some View {
        List {
            Section {
                ForEach(store.focusActivities) { activity in
                    ActivityRow(activity: activity) {
                        store.toggleRecurring(activity)
                    } onDelete: {
                        store.removeActivity(activity)
                    }
                }
                .onMove { store.moveFocusActivity(from: $0, to: $1) }

                TextField("Add focus activity...", text: $newFocusName)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        store.addFocusActivity(newFocusName)
                        newFocusName = ""
                    }
            } header: {
                Label("Focus", systemImage: "circle.fill")
                    .foregroundStyle(DesignSystem.Colors.focus)
            }

            Section {
                ForEach(store.breakActivities) { activity in
                    ActivityRow(activity: activity) {
                        store.toggleRecurring(activity)
                    } onDelete: {
                        store.removeActivity(activity)
                    }
                }
                .onMove { store.moveBreakActivity(from: $0, to: $1) }

                TextField("Add break activity...", text: $newBreakName)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        store.addBreakActivity(newBreakName)
                        newBreakName = ""
                    }
            } header: {
                Label("Break", systemImage: "circle.bottomhalf.filled")
                    .foregroundStyle(DesignSystem.Colors.shortBreak)
            }
        }
        .frame(width: DesignSystem.Spacing.editorWidth, height: DesignSystem.Spacing.editorHeight)
    }
}

// MARK: - Activity Row

struct ActivityRow: View {
    let activity: Activity
    let onToggleRecurring: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onToggleRecurring) {
                Image(systemName: activity.isRecurring
                    ? "arrow.trianglehead.2.clockwise"
                    : "1.circle")
                    .foregroundStyle(.secondary)
                    .frame(width: 18)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(activity.isRecurring ? "Make one-off" : "Make recurring")
            .help(activity.isRecurring ? "Recurring" : "One-off")

            Text(activity.name)
                .lineLimit(1)

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete \(activity.name)")
        }
    }
}
