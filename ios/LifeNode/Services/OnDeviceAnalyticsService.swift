import Foundation

@Observable
@MainActor
final class OnDeviceAnalyticsService {
    private let storageKey = "onDeviceAnalytics"

    var events: [AnalyticsEvent] {
        get {
            guard let data = UserDefaults.standard.data(forKey: storageKey),
                  let decoded = try? JSONDecoder().decode([AnalyticsEvent].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: storageKey)
            }
        }
    }

    func track(_ eventType: AnalyticsEventType) {
        var current = events
        if let index = current.firstIndex(where: { $0.type == eventType }) {
            current[index].count += 1
            current[index].lastOccurred = Date()
        } else {
            current.append(AnalyticsEvent(type: eventType, count: 1, firstOccurred: Date(), lastOccurred: Date()))
        }
        events = current
    }

    func totalForEvent(_ type: AnalyticsEventType) -> Int {
        events.first(where: { $0.type == type })?.count ?? 0
    }

    var totalSessions: Int { totalForEvent(.appOpened) }
    var totalReelsGenerated: Int { totalForEvent(.reelGenerated) }
    var totalCardsViewed: Int { totalForEvent(.memoryCardViewed) }
    var totalScansPerformed: Int { totalForEvent(.dataScanCompleted) }

    func clearAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}

nonisolated struct AnalyticsEvent: Codable, Sendable, Identifiable {
    var id: String { type.rawValue }
    let type: AnalyticsEventType
    var count: Int
    var firstOccurred: Date
    var lastOccurred: Date
}

nonisolated enum AnalyticsEventType: String, Codable, Sendable, CaseIterable {
    case appOpened
    case memoryCardViewed
    case reelGenerated
    case reelShared
    case dataScanCompleted
    case achievementUnlocked
    case mapExplored
    case timelineViewed
    case insightsViewed

    var displayName: String {
        switch self {
        case .appOpened: return "App Opened"
        case .memoryCardViewed: return "Memory Cards Viewed"
        case .reelGenerated: return "Reels Generated"
        case .reelShared: return "Reels Shared"
        case .dataScanCompleted: return "Data Scans"
        case .achievementUnlocked: return "Achievements Unlocked"
        case .mapExplored: return "Map Explored"
        case .timelineViewed: return "Timeline Viewed"
        case .insightsViewed: return "Insights Viewed"
        }
    }

    var icon: String {
        switch self {
        case .appOpened: return "app.badge"
        case .memoryCardViewed: return "rectangle.portrait.on.rectangle.portrait"
        case .reelGenerated: return "film.fill"
        case .reelShared: return "square.and.arrow.up"
        case .dataScanCompleted: return "arrow.triangle.2.circlepath"
        case .achievementUnlocked: return "trophy.fill"
        case .mapExplored: return "globe.americas.fill"
        case .timelineViewed: return "clock.fill"
        case .insightsViewed: return "chart.bar.fill"
        }
    }
}
