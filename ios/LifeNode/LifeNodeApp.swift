import SwiftUI
import SwiftData

@main
struct LifeNodeApp: App {
    @State private var backgroundTaskService = BackgroundTaskService()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MemoryNode.self,
            PhotoMetadata.self,
            WorkoutData.self,
            MusicData.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    backgroundTaskService.registerBackgroundTasks()
                    backgroundTaskService.scheduleAppRefresh()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
