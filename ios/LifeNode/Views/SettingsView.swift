import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var ingestionVM = DataIngestionViewModel()
    @State private var mapVM = MapViewModel()
    @State private var notificationService = NotificationService()
    @State private var analytics = OnDeviceAnalyticsService()
    @State private var showingResetAlert: Bool = false
    @State private var notificationsEnabled: Bool = false
    @State private var showPaywall: Bool = false
    @State private var subscriptionService = SubscriptionService.shared
    @Query private var allNodes: [MemoryNode]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    statsRow(icon: "brain.head.profile", title: "Total Memories", value: "\(allNodes.count)", color: .purple)
                    statsRow(icon: "link", title: "Graph Links", value: "\(totalLinks)", color: .blue)
                    statsRow(icon: "camera.fill", title: "Photos", value: "\(countFor(.photo))", color: .blue)
                    statsRow(icon: "figure.run", title: "Workouts", value: "\(countFor(.workout))", color: .green)
                    statsRow(icon: "music.note", title: "Music", value: "\(countFor(.music))", color: .purple)
                    statsRow(icon: "mappin.and.ellipse", title: "Check-ins", value: "\(countFor(.checkin))", color: .orange)
                } header: {
                    Text("Memory Graph")
                }

                Section {
                    permissionRow(
                        icon: "heart.fill",
                        title: "HealthKit",
                        isAuthorized: ingestionVM.healthKitService.isAuthorized,
                        color: .red
                    )
                    permissionRow(
                        icon: "music.note",
                        title: "MusicKit",
                        isAuthorized: ingestionVM.musicKitService.isAuthorized,
                        color: .purple
                    )
                    permissionRow(
                        icon: "photo.fill",
                        title: "Photo Library",
                        isAuthorized: ingestionVM.photoKitService.isAuthorized,
                        color: .blue
                    )
                } header: {
                    Text("Data Sources")
                } footer: {
                    Text("All data is processed and stored entirely on your device. Nothing leaves your phone.")
                }

                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Daily Memory Highlights", systemImage: "bell.fill")
                    }
                    .onChange(of: notificationsEnabled) { _, enabled in
                        if enabled {
                            Task {
                                await notificationService.requestAuthorization()
                                notificationService.scheduleDailyMemoryHighlight(nodes: allNodes)
                            }
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get reminded of memories from the past — \"On this day\" style.")
                }

                Section {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: subscriptionService.isPremium ? "crown.fill" : "crown")
                                .foregroundStyle(subscriptionService.isPremium ? .yellow : .purple)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(subscriptionService.isPremium ? "Premium Active" : "Upgrade to Premium")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text(subscriptionService.isPremium ? "All features unlocked" : "Unlimited nodes, reels & analytics")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if !subscriptionService.isPremium {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .disabled(subscriptionService.isPremium)
                } header: {
                    Text("Subscription")
                }

                Section {
                    NavigationLink {
                        AchievementsView()
                    } label: {
                        Label("Achievements", systemImage: "trophy.fill")
                    }
                } header: {
                    Text("Engagement")
                }

                Section {
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }

                    NavigationLink {
                        TransparencyReportView()
                    } label: {
                        Label("Transparency Report", systemImage: "doc.text.magnifyingglass")
                    }

                    NavigationLink {
                        UsageStatsView()
                    } label: {
                        Label("Usage Statistics", systemImage: "chart.bar.fill")
                    }
                } header: {
                    Text("Privacy & Compliance")
                } footer: {
                    Text("LifeNode collects zero data. All processing happens on-device.")
                }

                Section {
                    Button {
                        Task {
                            await ingestionVM.requestAllPermissions()
                            await ingestionVM.performInitialScan(modelContext: modelContext)
                            analytics.track(.dataScanCompleted)
                        }
                    } label: {
                        HStack {
                            Label("Scan Data Sources", systemImage: "arrow.triangle.2.circlepath")
                            Spacer()
                            if ingestionVM.isIngesting {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(ingestionVM.isIngesting)

                    if ingestionVM.isIngesting {
                        HStack {
                            Text(ingestionVM.ingestionProgress)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                } header: {
                    Text("Actions")
                }

                Section {
                    Button {
                        mapVM.generateSampleData(modelContext: modelContext)
                    } label: {
                        Label("Generate Sample Data", systemImage: "wand.and.stars")
                    }

                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                    }
                } header: {
                    Text("Debug")
                }

                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            colors: [.purple, .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 40, height: 40)

                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(.white)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(AppStoreMetadata.appName)
                                    .font(.subheadline.weight(.semibold))
                                Text("v\(AppStoreMetadata.version) · Private & On-Device")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .alert("Reset All Data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all memory nodes and their associated data.")
            }
        }
    }

    private func statsRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(title)
            Spacer()
            Text(value)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }

    private func permissionRow(icon: String, title: String, isAuthorized: Bool, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(title)
            Spacer()
            Image(systemName: isAuthorized ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundStyle(isAuthorized ? .green : .secondary)
        }
    }

    private var totalLinks: Int {
        allNodes.reduce(0) { $0 + $1.linkedNodeIDs.count } / 2
    }

    private func countFor(_ type: MemoryNodeType) -> Int {
        allNodes.filter { $0.type == type }.count
    }

    private func resetAllData() {
        do {
            try modelContext.delete(model: MemoryNode.self)
            try modelContext.delete(model: PhotoMetadata.self)
            try modelContext.delete(model: WorkoutData.self)
            try modelContext.delete(model: MusicData.self)
            try modelContext.save()
        } catch {}
    }
}
