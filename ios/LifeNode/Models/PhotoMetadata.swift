import Foundation
import SwiftData

@Model
class PhotoMetadata {
    var photoLibraryIdentifier: String
    var blurhash: String
    var dominantColorHex: String?

    var memoryNode: MemoryNode?

    init(photoLibraryIdentifier: String, blurhash: String = "", dominantColorHex: String? = nil) {
        self.photoLibraryIdentifier = photoLibraryIdentifier
        self.blurhash = blurhash
        self.dominantColorHex = dominantColorHex
    }
}
