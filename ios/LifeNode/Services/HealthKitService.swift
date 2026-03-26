import Foundation
import HealthKit
import SwiftData

@Observable
@MainActor
final class HealthKitService {
    private let healthStore = HKHealthStore()
    var isAuthorized: Bool = false
    var authorizationError: String?

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async {
        guard isAvailable else {
            authorizationError = "HealthKit is not available on this device."
            return
        }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
        } catch {
            authorizationError = error.localizedDescription
        }
    }

    func fetchWorkouts(since startDate: Date) async -> [HKWorkout] {
        guard isAvailable else { return [] }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: .now)
        let workoutPredicate = HKSamplePredicate.workout(predicate)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [workoutPredicate],
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)],
            limit: 500
        )

        do {
            return try await descriptor.result(for: healthStore)
        } catch {
            return []
        }
    }

    func fetchHeartRateSamples(for workout: HKWorkout) async -> [Double] {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return [] }

        let predicate = HKQuery.predicateForSamples(
            withStart: workout.startDate,
            end: workout.endDate
        )

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, _ in
                let rates = (samples as? [HKQuantitySample])?.map {
                    $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                } ?? []
                continuation.resume(returning: rates)
            }
            self.healthStore.execute(query)
        }
    }

    func ingestWorkouts(modelContext: ModelContext, since startDate: Date) async -> Int {
        let workouts = await fetchWorkouts(since: startDate)
        var count = 0

        for workout in workouts {
            let heartRates = await fetchHeartRateSamples(for: workout)
            let activityType = workoutActivityName(workout.workoutActivityType)
            let calorieStats = workout.statistics(for: HKQuantityType(.activeEnergyBurned))
            let calories = calorieStats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
            let duration = workout.duration

            let node = MemoryNode(
                timestamp: workout.startDate,
                latitude: 0,
                longitude: 0,
                type: .workout
            )

            let workoutData = WorkoutData(
                activityType: activityType,
                duration: duration,
                caloriesBurned: calories,
                heartRateSamples: heartRates.isEmpty ? nil : heartRates
            )

            node.workoutData = workoutData
            modelContext.insert(node)
            count += 1
        }

        return count
    }

    private func workoutActivityName(_ type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: return "Running"
        case .walking: return "Walking"
        case .cycling: return "Cycling"
        case .swimming: return "Swimming"
        case .hiking: return "Hiking"
        case .yoga: return "Yoga"
        case .functionalStrengthTraining: return "Strength Training"
        case .traditionalStrengthTraining: return "Strength Training"
        case .highIntensityIntervalTraining: return "HIIT"
        case .dance: return "Dance"
        case .cooldown: return "Cooldown"
        case .coreTraining: return "Core Training"
        case .elliptical: return "Elliptical"
        case .rowing: return "Rowing"
        case .stairClimbing: return "Stair Climbing"
        default: return "Workout"
        }
    }
}
