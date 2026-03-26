import Foundation
import StoreKit

@Observable
@MainActor
final class EngagementService {
    private let interactionTimeKey = "cumulativeInteractionTime"
    private let cardsViewedKey = "cardsViewedThisSession"
    private let totalCardsViewedKey = "totalCardsViewed"
    private let hasRequestedReviewKey = "hasRequestedReview"
    private let sessionStartKey = "sessionStart"
    private let achievementsKey = "unlockedAchievements"
    private let reelsGeneratedKey = "reelsGenerated"

    var sessionCardsViewed: Int = 0
    private var sessionStartDate: Date?

    func startSession() {
        sessionStartDate = Date()
        sessionCardsViewed = 0
    }

    func recordCardView() {
        sessionCardsViewed += 1
        let total = UserDefaults.standard.integer(forKey: totalCardsViewedKey) + 1
        UserDefaults.standard.set(total, forKey: totalCardsViewedKey)
        checkReviewPrompt()
    }

    func recordInteractionTime(_ seconds: TimeInterval) {
        let cumulative = UserDefaults.standard.double(forKey: interactionTimeKey) + seconds
        UserDefaults.standard.set(cumulative, forKey: interactionTimeKey)
        checkReviewPrompt()
    }

    func endSession() {
        guard let start = sessionStartDate else { return }
        let duration = Date().timeIntervalSince(start)
        recordInteractionTime(duration)
    }

    private func checkReviewPrompt() {
        guard !UserDefaults.standard.bool(forKey: hasRequestedReviewKey) else { return }

        let cumulativeTime = UserDefaults.standard.double(forKey: interactionTimeKey)
        let meetsTimeThreshold = cumulativeTime >= 300
        let meetsCardThreshold = sessionCardsViewed >= 5

        if meetsTimeThreshold && meetsCardThreshold {
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                requestReview()
            }
        }
    }

    private func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }

        SKStoreReviewController.requestReview(in: scene)
        UserDefaults.standard.set(true, forKey: hasRequestedReviewKey)
    }

    var reelsGenerated: Int {
        get { UserDefaults.standard.integer(forKey: reelsGeneratedKey) }
        set { UserDefaults.standard.set(newValue, forKey: reelsGeneratedKey) }
    }

    func incrementReelsGenerated() {
        reelsGenerated += 1
    }

    var unlockedAchievements: Set<String> {
        get {
            let arr = UserDefaults.standard.stringArray(forKey: achievementsKey) ?? []
            return Set(arr)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: achievementsKey)
        }
    }

    func checkAchievements(totalNodes: Int, totalLinks: Int, reels: Int) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []

        for achievement in Achievement.allCases {
            guard !unlockedAchievements.contains(achievement.id) else { continue }

            let earned: Bool
            switch achievement {
            case .firstMemory: earned = totalNodes >= 1
            case .memoryExplorer: earned = totalNodes >= 50
            case .memoryArchitect: earned = totalNodes >= 200
            case .firstLink: earned = totalLinks >= 1
            case .webWeaver: earned = totalLinks >= 25
            case .firstReel: earned = reels >= 1
            case .reelDirector: earned = reels >= 5
            case .centurion: earned = totalNodes >= 100
            }

            if earned {
                unlockedAchievements.insert(achievement.id)
                newlyUnlocked.append(achievement)
            }
        }

        return newlyUnlocked
    }
}

nonisolated enum Achievement: String, CaseIterable, Identifiable, Sendable {
    case firstMemory
    case memoryExplorer
    case memoryArchitect
    case firstLink
    case webWeaver
    case firstReel
    case reelDirector
    case centurion

    nonisolated var id: String { rawValue }

    var title: String {
        switch self {
        case .firstMemory: return "First Memory"
        case .memoryExplorer: return "Memory Explorer"
        case .memoryArchitect: return "Memory Architect"
        case .firstLink: return "First Connection"
        case .webWeaver: return "Web Weaver"
        case .firstReel: return "Director's Cut"
        case .reelDirector: return "Reel Director"
        case .centurion: return "Centurion"
        }
    }

    var subtitle: String {
        switch self {
        case .firstMemory: return "Created your first memory node"
        case .memoryExplorer: return "Collected 50 memories"
        case .memoryArchitect: return "Reached 200 memories"
        case .firstLink: return "Discovered your first connection"
        case .webWeaver: return "Woven 25 memory links"
        case .firstReel: return "Generated your first Life Reel"
        case .reelDirector: return "Created 5 Life Reels"
        case .centurion: return "100 memories strong"
        }
    }

    var icon: String {
        switch self {
        case .firstMemory: return "sparkle"
        case .memoryExplorer: return "binoculars.fill"
        case .memoryArchitect: return "building.columns.fill"
        case .firstLink: return "link"
        case .webWeaver: return "network"
        case .firstReel: return "film.fill"
        case .reelDirector: return "video.fill"
        case .centurion: return "shield.fill"
        }
    }

    var color: String {
        switch self {
        case .firstMemory: return "purple"
        case .memoryExplorer: return "blue"
        case .memoryArchitect: return "indigo"
        case .firstLink: return "green"
        case .webWeaver: return "teal"
        case .firstReel: return "orange"
        case .reelDirector: return "red"
        case .centurion: return "yellow"
        }
    }
}
