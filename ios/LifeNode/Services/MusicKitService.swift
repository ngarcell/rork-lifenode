import Foundation
import MusicKit
import SwiftData

@Observable
@MainActor
final class MusicKitService {
    var isAuthorized: Bool = false
    var authorizationError: String?

    func requestAuthorization() async {
        let status = await MusicAuthorization.request()
        switch status {
        case .authorized:
            isAuthorized = true
        case .denied, .restricted:
            authorizationError = "Music access was denied."
        case .notDetermined:
            authorizationError = "Music authorization not determined."
        @unknown default:
            authorizationError = "Unknown authorization status."
        }
    }

    func fetchRecentlyPlayed() async -> [(song: String, artist: String, artworkURL: String?, date: Date)] {
        guard isAuthorized else { return [] }

        do {
            var request = MusicRecentlyPlayedRequest<Song>()
            request.limit = 100
            let response = try await request.response()

            return response.items.compactMap { song in
                let artURL = song.artwork?.url(width: 300, height: 300)?.absoluteString
                return (
                    song: song.title,
                    artist: song.artistName,
                    artworkURL: artURL,
                    date: song.lastPlayedDate ?? Date()
                )
            }
        } catch {
            return []
        }
    }

    func ingestRecentMusic(modelContext: ModelContext) async -> Int {
        let items = await fetchRecentlyPlayed()
        var count = 0

        for item in items {
            let node = MemoryNode(
                timestamp: item.date,
                latitude: 0,
                longitude: 0,
                type: .music
            )

            let musicData = MusicData(
                songTitle: item.song,
                artistName: item.artist,
                albumArtURL: item.artworkURL
            )

            node.musicData = musicData
            modelContext.insert(node)
            count += 1
        }

        return count
    }
}
