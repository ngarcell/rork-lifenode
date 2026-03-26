import Foundation
import SwiftData
import CoreLocation

@Observable
@MainActor
final class MemoryGraphLinker {
    private let timeThresholdSeconds: TimeInterval = 30 * 60
    private let distanceThresholdMeters: Double = 500

    func linkNodes(modelContext: ModelContext) async -> Int {
        let descriptor = FetchDescriptor<MemoryNode>(
            sortBy: [SortDescriptor(\.timestamp)]
        )

        guard let allNodes = try? modelContext.fetch(descriptor) else { return 0 }

        var linkCount = 0

        for i in 0..<allNodes.count {
            for j in (i + 1)..<allNodes.count {
                let nodeA = allNodes[i]
                let nodeB = allNodes[j]

                let timeDiff = abs(nodeA.timestamp.timeIntervalSince(nodeB.timestamp))
                if timeDiff > timeThresholdSeconds * 2 { break }

                if timeDiff <= timeThresholdSeconds && areProximate(nodeA, nodeB) {
                    if !nodeA.linkedNodeIDs.contains(nodeB.id) {
                        nodeA.linkedNodeIDs.append(nodeB.id)
                    }
                    if !nodeB.linkedNodeIDs.contains(nodeA.id) {
                        nodeB.linkedNodeIDs.append(nodeA.id)
                    }
                    linkCount += 1
                }
            }
        }

        return linkCount
    }

    private func areProximate(_ a: MemoryNode, _ b: MemoryNode) -> Bool {
        guard a.latitude != 0 || a.longitude != 0,
              b.latitude != 0 || b.longitude != 0 else {
            return abs(a.timestamp.timeIntervalSince(b.timestamp)) <= timeThresholdSeconds
        }

        let locationA = CLLocation(latitude: a.latitude, longitude: a.longitude)
        let locationB = CLLocation(latitude: b.latitude, longitude: b.longitude)
        return locationA.distance(from: locationB) <= distanceThresholdMeters
    }

    func getLinkedNodes(for node: MemoryNode, modelContext: ModelContext) -> [MemoryNode] {
        guard !node.linkedNodeIDs.isEmpty else { return [] }

        let linkedIDs = node.linkedNodeIDs
        let descriptor = FetchDescriptor<MemoryNode>()

        guard let allNodes = try? modelContext.fetch(descriptor) else { return [] }
        return allNodes.filter { linkedIDs.contains($0.id) }
    }
}
