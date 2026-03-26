import Foundation
import SwiftData

@Model
class MusicData {
    var songTitle: String
    var artistName: String
    var albumArtURL: String?

    var memoryNode: MemoryNode?

    init(songTitle: String, artistName: String, albumArtURL: String? = nil) {
        self.songTitle = songTitle
        self.artistName = artistName
        self.albumArtURL = albumArtURL
    }
}
