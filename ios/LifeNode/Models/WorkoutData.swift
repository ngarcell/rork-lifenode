import Foundation
import SwiftData

@Model
class WorkoutData {
    var activityType: String
    var duration: TimeInterval
    var caloriesBurned: Double
    var heartRateSamples: [Double]?

    var memoryNode: MemoryNode?

    init(activityType: String, duration: TimeInterval, caloriesBurned: Double, heartRateSamples: [Double]? = nil) {
        self.activityType = activityType
        self.duration = duration
        self.caloriesBurned = caloriesBurned
        self.heartRateSamples = heartRateSamples
    }
}
