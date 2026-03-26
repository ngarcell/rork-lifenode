import Foundation
import BackgroundTasks
import SwiftData

@Observable
@MainActor
final class BackgroundTaskService {
    static let refreshTaskIdentifier = "app.rork.lifenode.refresh"
    static let processingTaskIdentifier = "app.rork.lifenode.processing"

    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.refreshTaskIdentifier,
            using: nil
        ) { task in
            Task { @MainActor in
                self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.processingTaskIdentifier,
            using: nil
        ) { task in
            Task { @MainActor in
                self.handleProcessingTask(task: task as! BGProcessingTask)
            }
        }
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.refreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Silently handle — background scheduling may not be available
        }
    }

    func scheduleProcessingTask() {
        let request = BGProcessingTaskRequest(identifier: Self.processingTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 60 * 60)
        request.requiresExternalPower = false
        request.requiresNetworkConnectivity = false

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Silently handle
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        task.setTaskCompleted(success: true)
    }

    private func handleProcessingTask(task: BGProcessingTask) {
        scheduleProcessingTask()
        task.setTaskCompleted(success: true)
    }
}
