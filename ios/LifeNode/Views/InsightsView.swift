import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query(sort: \MemoryNode.timestamp, order: .reverse) private var nodes: [MemoryNode]
    @State private var subscriptionService = SubscriptionService.shared
    @State private var showPaywall: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    overviewCard
                    activityHeatmap
                    typeBreakdown

                    if subscriptionService.isPremium {
                        recentConnections
                    } else {
                        premiumUpsell
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Insights")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var overviewCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Digital Twin")
                    .font(.title3.bold())
                Spacer()
                Image(systemName: "brain.head.profile")
                    .font(.title3)
                    .foregroundStyle(.purple)
            }

            HStack(spacing: 0) {
                insightMetric(value: "\(nodes.count)", label: "Memories", color: .blue)
                Spacer()
                insightMetric(value: "\(uniqueDays)", label: "Days", color: .green)
                Spacer()
                insightMetric(value: "\(totalLinks)", label: "Links", color: .purple)
                Spacer()
                insightMetric(value: "\(uniqueLocations)", label: "Places", color: .orange)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 20))
    }

    private func insightMetric(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title.bold().monospacedDigit())
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var activityHeatmap: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 7 Days")
                .font(.headline)

            HStack(spacing: 4) {
                ForEach(last7Days, id: \.self) { date in
                    let count = nodesOnDay(date)
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(heatColor(for: count))
                            .frame(height: 40)

                        Text(dayLabel(date))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var typeBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Memory Types")
                .font(.headline)

            ForEach(MemoryNodeType.allCases, id: \.self) { type in
                let count = nodes.filter { $0.type == type }.count
                let ratio = nodes.isEmpty ? 0 : Double(count) / Double(nodes.count)

                HStack(spacing: 12) {
                    Image(systemName: type.icon)
                        .font(.subheadline)
                        .foregroundStyle(colorFor(type))
                        .frame(width: 24)

                    Text(type.displayName)
                        .font(.subheadline)

                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(colorFor(type).gradient)
                            .frame(width: geo.size.width * ratio)
                    }
                    .frame(height: 8)

                    Text("\(count)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 30, alignment: .trailing)
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var recentConnections: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Multi-Sensory Memories")
                .font(.headline)

            let linked = nodes.filter { !$0.linkedNodeIDs.isEmpty }.prefix(5)
            if linked.isEmpty {
                Text("No linked memories yet. Run a data scan to discover connections between your photos, workouts, and music.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(linked), id: \.id) { node in
                    HStack(spacing: 12) {
                        Image(systemName: node.type.icon)
                            .font(.subheadline)
                            .foregroundStyle(colorFor(node.type))
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(node.type.displayName)
                                .font(.subheadline.weight(.medium))
                            Text("\(node.linkedNodeIDs.count) connections")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(node.timestamp.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var uniqueDays: Int {
        Set(nodes.map { Calendar.current.startOfDay(for: $0.timestamp) }).count
    }

    private var totalLinks: Int {
        nodes.reduce(0) { $0 + $1.linkedNodeIDs.count } / 2
    }

    private var uniqueLocations: Int {
        let geoNodes = nodes.filter { $0.latitude != 0 || $0.longitude != 0 }
        var locations: [(Double, Double)] = []
        for node in geoNodes {
            let roundedLat = (node.latitude * 100).rounded() / 100
            let roundedLon = (node.longitude * 100).rounded() / 100
            if !locations.contains(where: { $0.0 == roundedLat && $0.1 == roundedLon }) {
                locations.append((roundedLat, roundedLon))
            }
        }
        return locations.count
    }

    private var last7Days: [Date] {
        (0..<7).map { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
        }.reversed()
    }

    private func nodesOnDay(_ date: Date) -> Int {
        nodes.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }.count
    }

    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }

    private func heatColor(for count: Int) -> Color {
        switch count {
        case 0: return Color(.tertiarySystemFill)
        case 1...2: return .purple.opacity(0.3)
        case 3...5: return .purple.opacity(0.5)
        case 6...10: return .purple.opacity(0.7)
        default: return .purple
        }
    }

    private var premiumUpsell: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 36))
                .foregroundStyle(.purple)

            Text("Advanced Analytics")
                .font(.headline)

            Text("Unlock deeper insights into your Memory Graph with trend analysis, multi-sensory connections, and personalized patterns.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showPaywall = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                    Text("Unlock Premium")
                        .font(.subheadline.weight(.semibold))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
        .padding(24)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func colorFor(_ type: MemoryNodeType) -> Color {
        switch type {
        case .photo: return .blue
        case .workout: return .green
        case .music: return .purple
        case .checkin: return .orange
        }
    }
}
