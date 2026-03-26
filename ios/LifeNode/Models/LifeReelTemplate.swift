import Foundation

nonisolated enum ReelTimeRange: String, CaseIterable, Identifiable, Sendable {
    case lastWeek = "Last Week"
    case lastMonth = "Last Month"
    case last3Months = "Last 3 Months"
    case lastYear = "Last Year"
    case allTime = "All Time"

    nonisolated var id: String { rawValue }

    var startDate: Date {
        let calendar = Calendar.current
        switch self {
        case .lastWeek: return calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        case .lastMonth: return calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .last3Months: return calendar.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        case .lastYear: return calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        case .allTime: return .distantPast
        }
    }
}

nonisolated enum ReelTheme: String, CaseIterable, Identifiable, Sendable {
    case highlights = "Highlights"
    case adventure = "Adventure"
    case relaxation = "Relaxation"
    case fitness = "Fitness Journey"
    case musicMemories = "Music Memories"
    case photoAlbum = "Photo Album"

    nonisolated var id: String { rawValue }

    var icon: String {
        switch self {
        case .highlights: return "sparkles"
        case .adventure: return "map.fill"
        case .relaxation: return "leaf.fill"
        case .fitness: return "figure.run"
        case .musicMemories: return "music.note.list"
        case .photoAlbum: return "photo.on.rectangle.angled"
        }
    }

    var gradientColors: [String] {
        switch self {
        case .highlights: return ["purple", "blue"]
        case .adventure: return ["orange", "red"]
        case .relaxation: return ["green", "teal"]
        case .fitness: return ["green", "yellow"]
        case .musicMemories: return ["purple", "pink"]
        case .photoAlbum: return ["blue", "cyan"]
        }
    }
}

struct SmartTemplate: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let theme: ReelTheme
    let timeRange: ReelTimeRange
    let icon: String
    let nodeCount: Int
}
