import Foundation
import SwiftData

@Observable
@MainActor
final class DataIngestionViewModel {
    let healthKitService = HealthKitService()
    let musicKitService = MusicKitService()
    let photoKitService = PhotoKitService()
    let imageAnalysisService = ImageAnalysisService()
    let memoryGraphLinker = MemoryGraphLinker()
    let backgroundTaskService = BackgroundTaskService()

    var isIngesting: Bool = false
    var ingestionProgress: String = ""
    var totalNodesIngested: Int = 0
    var totalLinksCreated: Int = 0

    var hasCompletedInitialScan: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedInitialScan") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedInitialScan") }
    }

    func requestAllPermissions() async {
        await healthKitService.requestAuthorization()
        await musicKitService.requestAuthorization()
        await photoKitService.requestAuthorization()
    }

    func performInitialScan(modelContext: ModelContext) async {
        guard !isIngesting else { return }
        isIngesting = true
        totalNodesIngested = 0

        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()

        if healthKitService.isAuthorized {
            ingestionProgress = "Scanning workouts..."
            let workoutCount = await healthKitService.ingestWorkouts(modelContext: modelContext, since: sixMonthsAgo)
            totalNodesIngested += workoutCount
        }

        if musicKitService.isAuthorized {
            ingestionProgress = "Scanning music history..."
            let musicCount = await musicKitService.ingestRecentMusic(modelContext: modelContext)
            totalNodesIngested += musicCount
        }

        if photoKitService.isAuthorized {
            ingestionProgress = "Scanning photos..."
            let photoCount = await photoKitService.ingestPhotos(modelContext: modelContext, since: sixMonthsAgo)
            totalNodesIngested += photoCount
        }

        ingestionProgress = "Building memory graph..."
        totalLinksCreated = await memoryGraphLinker.linkNodes(modelContext: modelContext)

        ingestionProgress = "Scan complete"
        hasCompletedInitialScan = true
        isIngesting = false

        backgroundTaskService.scheduleAppRefresh()
        backgroundTaskService.scheduleProcessingTask()
    }
}
