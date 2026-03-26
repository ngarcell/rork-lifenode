import SwiftUI
import SwiftData
import MapKit
import CoreLocation

@Observable
@MainActor
final class MapViewModel {
    var cameraPosition: MapCameraPosition = .camera(MapCamera(
        centerCoordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        distance: 50000,
        heading: 0,
        pitch: 45
    ))
    var clusters: [NodeCluster] = []
    var selectedCluster: NodeCluster?
    var isLoading: Bool = false
    var zoomLevel: Double = 10
    var filterType: MemoryNodeType?

    private let clusteringService = ClusteringService()

    func loadNodes(modelContext: ModelContext) {
        var descriptor = FetchDescriptor<MemoryNode>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 5000

        guard let nodes = try? modelContext.fetch(descriptor) else { return }

        let filtered: [MemoryNode]
        if let filterType {
            filtered = nodes.filter { $0.type == filterType }
        } else {
            filtered = nodes
        }

        let validNodes = filtered.filter { $0.latitude != 0 || $0.longitude != 0 }
        clusters = clusteringService.clusterNodes(validNodes, zoomLevel: zoomLevel)

        if let first = validNodes.first, clusters.count > 0 {
            cameraPosition = .camera(MapCamera(
                centerCoordinate: CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude),
                distance: 50000,
                heading: 0,
                pitch: 45
            ))
        }
    }

    func updateZoom(_ span: MKCoordinateSpan) {
        let latZoom = log2(360.0 / span.latitudeDelta)
        zoomLevel = max(1, min(20, latZoom))
    }

    func generateSampleData(modelContext: ModelContext) {
        let sampleLocations: [(lat: Double, lon: Double, name: String)] = [
            (37.7749, -122.4194, "San Francisco"),
            (37.7849, -122.4094, "Nob Hill"),
            (37.7694, -122.4862, "Golden Gate Park"),
            (37.8024, -122.4058, "Fisherman's Wharf"),
            (37.7956, -122.3933, "Ferry Building"),
            (37.7599, -122.4148, "Mission District"),
            (37.7879, -122.4074, "Union Square"),
            (37.8083, -122.4156, "Ghirardelli Square"),
            (34.0522, -118.2437, "Los Angeles"),
            (34.0195, -118.4912, "Santa Monica"),
            (40.7128, -74.0060, "New York"),
            (40.7580, -73.9855, "Times Square"),
            (51.5074, -0.1278, "London"),
            (48.8566, 2.3522, "Paris"),
            (35.6762, 139.6503, "Tokyo"),
        ]

        let now = Date()

        for (index, loc) in sampleLocations.enumerated() {
            let daysAgo = Double(index * 3 + Int.random(in: 0...5))
            let timestamp = now.addingTimeInterval(-daysAgo * 86400)

            let types: [MemoryNodeType] = [.photo, .workout, .music, .checkin]
            let type = types[index % types.count]

            let node = MemoryNode(
                timestamp: timestamp,
                latitude: loc.lat + Double.random(in: -0.005...0.005),
                longitude: loc.lon + Double.random(in: -0.005...0.005),
                type: type,
                note: "Memory at \(loc.name)"
            )

            switch type {
            case .photo:
                node.photoMetadata = PhotoMetadata(
                    photoLibraryIdentifier: "sample_\(index)",
                    blurhash: "4A7BC3",
                    dominantColorHex: "#4A7BC3"
                )
            case .workout:
                let activities = ["Running", "Cycling", "Swimming", "Hiking", "Yoga"]
                node.workoutData = WorkoutData(
                    activityType: activities[index % activities.count],
                    duration: Double.random(in: 1200...7200),
                    caloriesBurned: Double.random(in: 150...800),
                    heartRateSamples: (0..<20).map { _ in Double.random(in: 80...180) }
                )
            case .music:
                let songs = [
                    ("Bohemian Rhapsody", "Queen"),
                    ("Blinding Lights", "The Weeknd"),
                    ("Shape of You", "Ed Sheeran"),
                    ("Starboy", "The Weeknd"),
                    ("Levitating", "Dua Lipa")
                ]
                let song = songs[index % songs.count]
                node.musicData = MusicData(songTitle: song.0, artistName: song.1)
            case .checkin:
                break
            }

            modelContext.insert(node)
        }

        for i in 0..<30 {
            let baseLoc = sampleLocations[i % sampleLocations.count]
            let timestamp = now.addingTimeInterval(-Double(i) * 43200)

            let node = MemoryNode(
                timestamp: timestamp,
                latitude: baseLoc.lat + Double.random(in: -0.02...0.02),
                longitude: baseLoc.lon + Double.random(in: -0.02...0.02),
                type: MemoryNodeType.allCases.randomElement() ?? .checkin
            )
            modelContext.insert(node)
        }

        loadNodes(modelContext: modelContext)
    }
}
