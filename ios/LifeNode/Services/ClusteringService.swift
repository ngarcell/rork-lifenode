import Foundation
import CoreLocation

@Observable
@MainActor
final class ClusteringService {

    func clusterNodes(_ nodes: [MemoryNode], zoomLevel: Double) -> [NodeCluster] {
        let threshold = clusteringThreshold(for: zoomLevel)
        var clustered: [NodeCluster] = []
        var assigned = Set<UUID>()

        for node in nodes {
            guard !assigned.contains(node.id) else { continue }

            var clusterNodes: [MemoryNode] = [node]
            assigned.insert(node.id)

            let nodeLocation = CLLocation(latitude: node.latitude, longitude: node.longitude)

            for other in nodes {
                guard !assigned.contains(other.id) else { continue }
                let otherLocation = CLLocation(latitude: other.latitude, longitude: other.longitude)
                if nodeLocation.distance(from: otherLocation) < threshold {
                    clusterNodes.append(other)
                    assigned.insert(other.id)
                }
            }

            let avgLat = clusterNodes.map(\.latitude).reduce(0, +) / Double(clusterNodes.count)
            let avgLon = clusterNodes.map(\.longitude).reduce(0, +) / Double(clusterNodes.count)

            clustered.append(NodeCluster(
                id: UUID(),
                coordinate: CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon),
                nodes: clusterNodes
            ))
        }

        return clustered
    }

    private func clusteringThreshold(for zoomLevel: Double) -> Double {
        let baseThreshold: Double = 50000
        return baseThreshold / pow(2, zoomLevel)
    }
}
