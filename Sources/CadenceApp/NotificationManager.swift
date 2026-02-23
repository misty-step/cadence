import AppKit
import Foundation
@preconcurrency import UserNotifications

@MainActor
final class NotificationManager {
    private var center: UNUserNotificationCenter? {
        guard Bundle.main.bundleIdentifier != nil else { return nil }
        return UNUserNotificationCenter.current()
    }

    func requestAuthorizationIfNeeded() {
        guard let center = center else { return }
        Task {
            let settings = await center.notificationSettings()
            if settings.authorizationStatus == .notDetermined {
                _ = try? await center.requestAuthorization(options: [.alert, .sound])
            }
        }
    }

    func notify(phase: TimerState.Phase) {
        NSSound(named: NSSound.Name(phase.systemSound))?.play()

        guard let center = center else { return }
        let content = UNMutableNotificationContent()
        content.title = phase.name
        content.body = phase.notificationBody
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        center.add(request)
    }
}
