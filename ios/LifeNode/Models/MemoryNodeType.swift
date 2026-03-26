import Foundation

nonisolated enum MemoryNodeType: String, Codable, CaseIterable, Sendable {
    case photo
    case workout
    case music
    case checkin
    
    var icon: String {
        switch self {
        case .photo: return "camera.fill"
        case .workout: return "figure.run"
        case .music: return "music.note"
        case .checkin: return "mappin.and.ellipse"
        }
    }
    
    var displayName: String {
        switch self {
        case .photo: return "Photo"
        case .workout: return "Workout"
        case .music: return "Music"
        case .checkin: return "Check-in"
        }
    }
}
