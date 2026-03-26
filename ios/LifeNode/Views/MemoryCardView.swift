import SwiftUI
import MapKit

struct MemoryCardView: View {
    let node: MemoryNode
    let onDismiss: () -> Void
    @State private var appeared: Bool = false
    @State private var currentCardIndex: Int = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroHeader
                    locationCard
                    dataContent
                    linkedMemories
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .presentationContentInteraction(.scrolls)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(node.type.displayName)
                        .font(.subheadline.weight(.semibold))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { onDismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private var heroHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(nodeColor.gradient)
                    .frame(width: 64, height: 64)
                    .shadow(color: nodeColor.opacity(0.4), radius: 12, y: 4)

                Image(systemName: node.type.icon)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(appeared ? 1 : 0.5)
            .opacity(appeared ? 1 : 0)

            VStack(alignment: .leading, spacing: 4) {
                Text(titleText)
                    .font(.title3.bold())
                    .lineLimit(2)

                Text(node.timestamp.formatted(date: .long, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !node.linkedNodeIDs.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.caption2)
                        Text("\(node.linkedNodeIDs.count) connections")
                            .font(.caption)
                    }
                    .foregroundStyle(.purple)
                    .padding(.top, 2)
                }
            }

            Spacer()
        }
    }

    @ViewBuilder
    private var locationCard: some View {
        if node.latitude != 0 || node.longitude != 0 {
            Map {
                Marker("", coordinate: CLLocationCoordinate2D(
                    latitude: node.latitude,
                    longitude: node.longitude
                ))
                .tint(nodeColor)
            }
            .mapStyle(.imagery(elevation: .realistic))
            .frame(height: 180)
            .clipShape(.rect(cornerRadius: 16))
            .allowsHitTesting(false)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.5).delay(0.1), value: appeared)
        }
    }

    @ViewBuilder
    private var dataContent: some View {
        Group {
            switch node.type {
            case .workout:
                if let workout = node.workoutData {
                    workoutContent(workout)
                }
            case .music:
                if let music = node.musicData {
                    musicContent(music)
                }
            case .photo:
                if let photo = node.photoMetadata {
                    photoContent(photo)
                }
            case .checkin:
                if let noteText = node.note {
                    checkinContent(noteText)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.5).delay(0.2), value: appeared)
    }

    private func workoutContent(_ workout: WorkoutData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(workout.activityType, systemImage: "figure.run")
                    .font(.headline)
                Spacer()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                metricTile(icon: "clock.fill", label: "Duration", value: formattedDuration(workout.duration), color: .blue)
                metricTile(icon: "flame.fill", label: "Calories", value: "\(Int(workout.caloriesBurned))", color: .orange)

                if let rates = workout.heartRateSamples, !rates.isEmpty {
                    let avg = rates.reduce(0, +) / Double(rates.count)
                    metricTile(icon: "heart.fill", label: "Avg HR", value: "\(Int(avg)) bpm", color: .red)
                    metricTile(icon: "heart.fill", label: "Max HR", value: "\(Int(rates.max() ?? 0)) bpm", color: .pink)
                }
            }

            if let rates = workout.heartRateSamples, rates.count > 2 {
                HeartRateGraph(samples: rates)
                    .frame(height: 80)
                    .padding(.top, 4)
                    .padding(.horizontal, 4)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func metricTile(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(value)
                .font(.headline.monospacedDigit())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.08))
        .clipShape(.rect(cornerRadius: 10))
    }

    private func musicContent(_ music: MusicData) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(colors: [.purple, .pink.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: .purple.opacity(0.3), radius: 8, y: 4)

                Image(systemName: "music.note")
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(music.songTitle)
                    .font(.headline)
                Text(music.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func photoContent(_ photo: PhotoMetadata) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(dominantColor(photo).gradient)
                    .frame(width: 72, height: 72)

                Image(systemName: "photo.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Photo Memory")
                    .font(.headline)
                Text("From your photo library")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func checkinContent(_ note: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Note", systemImage: "note.text")
                .font(.headline)
            Text(note)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    @ViewBuilder
    private var linkedMemories: some View {
        if !node.linkedNodeIDs.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Connected Memories", systemImage: "link")
                        .font(.headline)
                    Spacer()
                    Text("\(node.linkedNodeIDs.count)")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                Text("Linked by time & location proximity")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.5).delay(0.3), value: appeared)
        }
    }

    private var nodeColor: Color {
        switch node.type {
        case .photo: return .blue
        case .workout: return .green
        case .music: return .purple
        case .checkin: return .orange
        }
    }

    private var titleText: String {
        switch node.type {
        case .workout: return node.workoutData?.activityType ?? "Workout"
        case .music:
            if let m = node.musicData { return "\(m.songTitle) — \(m.artistName)" }
            return "Music"
        case .photo: return "Photo Memory"
        case .checkin: return node.note ?? "Check-in"
        }
    }

    private func formattedDuration(_ d: TimeInterval) -> String {
        let h = Int(d) / 3600
        let m = (Int(d) % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m) min"
    }

    private func dominantColor(_ photo: PhotoMetadata) -> Color {
        guard let hex = photo.dominantColorHex else { return .blue }
        return Color(hex: hex)
    }
}
