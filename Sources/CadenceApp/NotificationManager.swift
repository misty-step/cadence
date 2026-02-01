import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorizationIfNeeded() {
        Task {
            let settings = await center.notificationSettings()
            if settings.authorizationStatus == .notDetermined {
                _ = try? await center.requestAuthorization(options: [.alert, .sound])
            }
        }
    }

    func notify(phase: TimerState.Phase) {
        let content = UNMutableNotificationContent()
        content.title = phase.name
        content.body = phase.isFocus ? "Time to focus." : "Time for a break."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        center.add(request)
    }
}
