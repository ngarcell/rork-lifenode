import Foundation
import UserNotifications
import CoreLocation
import SwiftData

@Observable
@MainActor
final class NotificationService {
    var isAuthorized: Bool = false

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
        } catch {
            isAuthorized = false
        }
    }

    func scheduleDailyMemoryHighlight(nodes: [MemoryNode]) {
        guard isAuthorized else { return }

        let calendar = Calendar.current
        let today = Date()

        let pastMemories = nodes.filter { node in
            let nodeDay = calendar.dateComponents([.month, .day], from: node.timestamp)
            let todayDay = calendar.dateComponents([.month, .day], from: today)
            return nodeDay.month == todayDay.month &&
                   nodeDay.day == todayDay.day &&
                   !calendar.isDate(node.timestamp, inSameDayAs: today)
        }

        guard let memory = pastMemories.randomElement() else { return }

        let content = UNMutableNotificationContent()
        content.title = "On This Day"

        let yearsAgo = calendar.dateComponents([.year], from: memory.timestamp, to: today).year ?? 0

        switch memory.type {
        case .photo:
            content.body = "You captured a photo \(yearsAgo) year\(yearsAgo == 1 ? "" : "s") ago"
        case .workout:
            let activity = memory.workoutData?.activityType ?? "workout"
            content.body = "You completed a \(activity) \(yearsAgo) year\(yearsAgo == 1 ? "" : "s") ago"
        case .music:
            let song = memory.musicData?.songTitle ?? "a song"
            content.body = "You were listening to \(song) \(yearsAgo) year\(yearsAgo == 1 ? "" : "s") ago"
        case .checkin:
            content.body = "You checked in \(yearsAgo) year\(yearsAgo == 1 ? "" : "s") ago"
        }

        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_memory_highlight",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleLocationReminder(for node: MemoryNode) {
        guard isAuthorized,
              node.latitude != 0 || node.longitude != 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Memory Nearby"
        content.body = "You have a \(node.type.displayName.lowercased()) memory from \(node.timestamp.formatted(date: .abbreviated, time: .omitted)) near here."
        content.sound = .default

        let center = CLLocationCoordinate2D(latitude: node.latitude, longitude: node.longitude)
        let region = CLCircularRegion(center: center, radius: 200, identifier: node.id.uuidString)
        region.notifyOnEntry = true
        region.notifyOnExit = false

        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        let request = UNNotificationRequest(
            identifier: "location_\(node.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
