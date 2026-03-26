import Foundation
import Photos
import SwiftData

@Observable
@MainActor
final class PhotoKitService {
    var isAuthorized: Bool = false
    var authorizationError: String?

    func requestAuthorization() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        switch status {
        case .authorized, .limited:
            isAuthorized = true
        case .denied, .restricted:
            authorizationError = "Photo library access was denied."
        case .notDetermined:
            authorizationError = "Photo library authorization not determined."
        @unknown default:
            authorizationError = "Unknown authorization status."
        }
    }

    func ingestPhotos(modelContext: ModelContext, since startDate: Date, batchSize: Int = 200) async -> Int {
        guard isAuthorized else { return 0 }

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "creationDate >= %@", startDate as NSDate)
        options.fetchLimit = batchSize

        let assets = PHAsset.fetchAssets(with: .image, options: options)
        var count = 0

        assets.enumerateObjects { asset, _, _ in
            guard let creationDate = asset.creationDate else { return }

            let lat = asset.location?.coordinate.latitude ?? 0
            let lon = asset.location?.coordinate.longitude ?? 0

            let node = MemoryNode(
                timestamp: creationDate,
                latitude: lat,
                longitude: lon,
                type: .photo
            )

            let metadata = PhotoMetadata(
                photoLibraryIdentifier: asset.localIdentifier,
                blurhash: "",
                dominantColorHex: nil
            )

            node.photoMetadata = metadata
            modelContext.insert(node)
            count += 1
        }

        return count
    }
}
