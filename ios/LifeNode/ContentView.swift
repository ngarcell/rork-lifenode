import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false

    var body: some View {
        if hasOnboarded {
            MainTabView()
        } else {
            OnboardingView(hasOnboarded: $hasOnboarded)
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @State private var engagementService = EngagementService()
    @State private var analytics = OnDeviceAnalyticsService()
    @Query private var allNodes: [MemoryNode]
    @State private var achievementToast: Achievement?
    @State private var showToast: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                Tab("Map", systemImage: "globe.americas.fill", value: 0) {
                    MemoryMapView()
                }

                Tab("Timeline", systemImage: "clock.fill", value: 1) {
                    TimelineView()
                }

                Tab("Life Reel", systemImage: "film.fill", value: 2) {
                    LifeReelView()
                }

                Tab("Insights", systemImage: "chart.bar.fill", value: 3) {
                    InsightsView()
                }

                Tab("Settings", systemImage: "gearshape.fill", value: 4) {
                    SettingsView()
                }
            }
            .tint(.purple)

            AchievementToast(
                achievement: achievementToast ?? .firstMemory,
                isVisible: $showToast
            )
            .padding(.top, 8)
        }
        .onAppear {
            engagementService.startSession()
            analytics.track(.appOpened)
            checkForNewAchievements()
        }
        .onChange(of: selectedTab) { _, newTab in
            switch newTab {
            case 0: analytics.track(.mapExplored)
            case 1: analytics.track(.timelineViewed)
            case 3: analytics.track(.insightsViewed)
            default: break
            }
        }
        .onChange(of: allNodes.count) { _, _ in
            checkForNewAchievements()
        }
    }

    private func checkForNewAchievements() {
        let totalLinks = allNodes.reduce(0) { $0 + $1.linkedNodeIDs.count } / 2
        let newAchievements = engagementService.checkAchievements(
            totalNodes: allNodes.count,
            totalLinks: totalLinks,
            reels: engagementService.reelsGenerated
        )
        if let first = newAchievements.first {
            achievementToast = first
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showToast = true
            }
        }
    }
}
