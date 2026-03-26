import SwiftUI
import SwiftData

struct TimelineView: View {
    @Query(sort: \MemoryNode.timestamp, order: .reverse) private var nodes: [MemoryNode]
    @State private var searchText: String = ""
    @State private var selectedNode: MemoryNode?
    @State private var showingCard: Bool = false
    @State private var engagementService = EngagementService()

    var filteredNodes: [MemoryNode] {
        guard !searchText.isEmpty else { return nodes }
        return nodes.filter { node in
            node.type.displayName.localizedStandardContains(searchText) ||
            (node.note?.localizedStandardContains(searchText) ?? false) ||
            (node.musicData?.songTitle.localizedStandardContains(searchText) ?? false) ||
            (node.musicData?.artistName.localizedStandardContains(searchText) ?? false) ||
            (node.workoutData?.activityType.localizedStandardContains(searchText) ?? false)
        }
    }

    var groupedNodes: [(key: String, nodes: [MemoryNode])] {
        let grouped = Dictionary(grouping: filteredNodes) { node in
            node.timestamp.formatted(date: .abbreviated, time: .omitted)
        }
        return grouped.map { (key: $0.key, nodes: $0.value) }
            .sorted { $0.nodes.first?.timestamp ?? .distantPast > $1.nodes.first?.timestamp ?? .distantPast }
    }

    var body: some View {
        NavigationStack {
            List {
                if filteredNodes.isEmpty {
                    ContentUnavailableView(
                        "No Memories",
                        systemImage: "brain.head.profile",
                        description: Text("Your memory graph is empty. Scan your data from Settings to populate it.")
                    )
                } else {
                    ForEach(groupedNodes, id: \.key) { group in
                        Section {
                            ForEach(group.nodes, id: \.id) { node in
                                Button {
                                    selectedNode = node
                                    showingCard = true
                                    engagementService.recordCardView()
                                } label: {
                                    TimelineRow(node: node)
                                }
                                .buttonStyle(.plain)
                            }
                        } header: {
                            Text(group.key)
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Timeline")
            .searchable(text: $searchText, prompt: "Search memories")
            .sheet(isPresented: $showingCard) {
                if let selectedNode {
                    MemoryCardView(node: selectedNode) {
                        showingCard = false
                    }
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
                }
            }
        }
    }
}

struct TimelineRow: View {
    let node: MemoryNode

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(colorForType.gradient)
                    .frame(width: 42, height: 42)

                Image(systemName: node.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(titleText)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text(node.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !node.linkedNodeIDs.isEmpty {
                HStack(spacing: 2) {
                    Image(systemName: "link")
                        .font(.caption2)
                    Text("\(node.linkedNodeIDs.count)")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.quaternary)
                .clipShape(Capsule())
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private var titleText: String {
        switch node.type {
        case .workout:
            return node.workoutData?.activityType ?? "Workout"
        case .music:
            if let music = node.musicData {
                return "\(music.songTitle) — \(music.artistName)"
            }
            return "Music"
        case .photo:
            return "Photo Memory"
        case .checkin:
            return node.note ?? "Check-in"
        }
    }

    private var colorForType: Color {
        switch node.type {
        case .photo: return .blue
        case .workout: return .green
        case .music: return .purple
        case .checkin: return .orange
        }
    }
}
