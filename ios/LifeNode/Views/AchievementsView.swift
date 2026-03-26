import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Query private var allNodes: [MemoryNode]
    @State private var engagementService = EngagementService()
    @State private var appeared: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                statsHeader

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Achievement.allCases) { achievement in
                        achievementCard(achievement)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .navigationTitle("Achievements")
        .background(Color(.systemGroupedBackground))
        .onAppear {
            let totalLinks = allNodes.reduce(0) { $0 + $1.linkedNodeIDs.count } / 2
            let _ = engagementService.checkAchievements(
                totalNodes: allNodes.count,
                totalLinks: totalLinks,
                reels: engagementService.reelsGenerated
            )
            withAnimation(.spring(response: 0.5).delay(0.2)) {
                appeared = true
            }
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 0) {
            statItem(value: "\(allNodes.count)", label: "Memories", color: .blue)
            Spacer()
            statItem(value: "\(engagementService.unlockedAchievements.count)", label: "Unlocked", color: .purple)
            Spacer()
            statItem(value: "\(Achievement.allCases.count)", label: "Total", color: .secondary)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 20))
    }

    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold().monospacedDigit())
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func achievementCard(_ achievement: Achievement) -> some View {
        let isUnlocked = engagementService.unlockedAchievements.contains(achievement.id)

        return VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? achievementColor(achievement).gradient : Color(.tertiarySystemFill).gradient)
                    .frame(width: 52, height: 52)

                Image(systemName: achievement.icon)
                    .font(.title3)
                    .foregroundStyle(isUnlocked ? .white : .secondary)
            }

            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)

                Text(achievement.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            isUnlocked
                ? AnyShapeStyle(achievementColor(achievement).opacity(0.08))
                : AnyShapeStyle(Color(.secondarySystemGroupedBackground))
        )
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.9)
    }

    private func achievementColor(_ achievement: Achievement) -> Color {
        switch achievement.color {
        case "purple": return .purple
        case "blue": return .blue
        case "indigo": return .indigo
        case "green": return .green
        case "teal": return .teal
        case "orange": return .orange
        case "red": return .red
        case "yellow": return .yellow
        default: return .blue
        }
    }
}

struct AchievementToast: View {
    let achievement: Achievement
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            HStack(spacing: 14) {
                Image(systemName: achievement.icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.purple.gradient)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("Achievement Unlocked!")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(achievement.title)
                        .font(.subheadline.weight(.bold))
                }

                Spacer()

                Button {
                    withAnimation(.spring) { isVisible = false }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 16))
            .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
            .padding(.horizontal, 16)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                Task {
                    try? await Task.sleep(for: .seconds(4))
                    withAnimation(.spring) { isVisible = false }
                }
            }
        }
    }
}
