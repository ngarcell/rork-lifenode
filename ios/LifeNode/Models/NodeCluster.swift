import Foundation
import CoreLocation

struct NodeCluster: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let nodes: [MemoryNode]

    var count: Int { nodes.count }
    var isSingle: Bool { nodes.count == 1 }

    var primaryType: MemoryNodeType {
        let typeCounts = Dictionary(grouping: nodes, by: { $0.type })
        return typeCounts.max(by: { $0.value.count < $1.value.count })?.key ?? .checkin
    }

    var dateRange: String {
        guard let earliest = nodes.map(\.timestamp).min(),
              let latest = nodes.map(\.timestamp).max() else { return "" }
        if Calendar.current.isDate(earliest, inSameDayAs: latest) {
            return earliest.formatted(date: .abbreviated, time: .omitted)
        }
        return "\(earliest.formatted(date: .abbreviated, time: .omitted)) – \(latest.formatted(date: .abbreviated, time: .omitted))"
    }
}
