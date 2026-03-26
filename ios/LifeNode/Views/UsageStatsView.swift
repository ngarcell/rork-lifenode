import SwiftUI

struct UsageStatsView: View {
    @State private var analytics = OnDeviceAnalyticsService()
    @State private var showClearAlert: Bool = false

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "internaldrive")
                            .font(.title3)
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("On-Device Only")
                                .font(.subheadline.weight(.semibold))
                            Text("These stats are stored locally and never leave your device.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Section {
                ForEach(AnalyticsEventType.allCases, id: \.rawValue) { eventType in
                    let event = analytics.events.first(where: { $0.type == eventType })
                    HStack {
                        Image(systemName: eventType.icon)
                            .font(.subheadline)
                            .foregroundStyle(.purple)
                            .frame(width: 24)

                        Text(eventType.displayName)
                            .font(.subheadline)

                        Spacer()

                        Text("\(event?.count ?? 0)")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Activity")
            }

            Section {
                Button(role: .destructive) {
                    showClearAlert = true
                } label: {
                    Label("Clear Usage Stats", systemImage: "trash")
                }
            } footer: {
                Text("This only clears local usage statistics. Your Memory Graph and other data are not affected.")
            }
        }
        .navigationTitle("Usage Stats")
        .alert("Clear Usage Stats?", isPresented: $showClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                analytics.clearAll()
            }
        } message: {
            Text("This will reset all local usage statistics to zero.")
        }
    }
}
