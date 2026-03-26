import Foundation
import SwiftData

@Model
class MemoryNode {
    var id: UUID
    var timestamp: Date
    var latitude: Double
    var longitude: Double
    var typeRaw: String
    var note: String?
    var linkedNodeIDs: [UUID]

    @Relationship(deleteRule: .cascade) var photoMetadata: PhotoMetadata?
    @Relationship(deleteRule: .cascade) var workoutData: WorkoutData?
    @Relationship(deleteRule: .cascade) var musicData: MusicData?

    var type: MemoryNodeType {
        get { MemoryNodeType(rawValue: typeRaw) ?? .checkin }
        set { typeRaw = newValue.rawValue }
    }

    init(
        timestamp: Date,
        latitude: Double,
        longitude: Double,
        type: MemoryNodeType,
        note: String? = nil
    ) {
        self.id = UUID()
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.typeRaw = type.rawValue
        self.note = note
        self.linkedNodeIDs = []
    }
}
