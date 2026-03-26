import SwiftUI

struct PrivacyPolicyView: View {
    @State private var appeared: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection

                policySection(
                    icon: "iphone",
                    title: "On-Device Processing",
                    content: "All user data — including photos, health metrics, music preferences, and location information — is processed and stored exclusively on your device. LifeNode never transmits your personal data to any external server, cloud service, or third party."
                )

                policySection(
                    icon: "hand.raised.fill",
                    title: "Zero Data Collection",
                    content: "LifeNode does not collect, store, or share any personal data. We have no servers, no analytics dashboards, and no way to access your information. Your data is yours alone."
                )

                policySection(
                    icon: "heart.fill",
                    title: "HealthKit Data",
                    content: "Workout history, heart rate samples, and activity data accessed from HealthKit are used solely for on-device processing to enrich your Memory Graph. This data is never shared, transmitted, or stored outside of the app's local sandbox."
                )

                policySection(
                    icon: "music.note",
                    title: "MusicKit Data",
                    content: "Your listening history accessed from Apple Music is used exclusively to create music-related Memory Nodes on your device. Song titles, artists, and playback data remain entirely local."
                )

                policySection(
                    icon: "photo.fill",
                    title: "Photo Library",
                    content: "LifeNode reads photo metadata (location, date, and image characteristics) to build geographic memory nodes. Only metadata is processed — your actual photos remain in the Photos library. No image data leaves your device."
                )

                policySection(
                    icon: "location.fill",
                    title: "Location Data",
                    content: "Location information from your photos and check-ins is used to place Memory Nodes on your 3D map. Location data is stored locally and is never transmitted externally."
                )

                policySection(
                    icon: "bell.fill",
                    title: "Notifications",
                    content: "Local notifications are scheduled entirely on-device to remind you of past memories. No notification data is sent to external services."
                )

                policySection(
                    icon: "lock.shield.fill",
                    title: "Data Security",
                    content: "Your Memory Graph is stored using Apple's SwiftData framework within the app's sandboxed container, protected by iOS's built-in encryption and data protection mechanisms."
                )

                policySection(
                    icon: "person.fill.questionmark",
                    title: "No Account Required",
                    content: "LifeNode does not require any user account, login, or registration. There is no user tracking, advertising identifiers, or behavioral profiling of any kind."
                )

                policySection(
                    icon: "trash.fill",
                    title: "Data Deletion",
                    content: "You can delete all your data at any time from Settings. Uninstalling the app removes all locally stored data permanently. Since no data exists on any server, deletion is immediate and complete."
                )

                lastUpdated
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.purple.gradient.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.purple)
            }

            VStack(spacing: 6) {
                Text("Your Privacy Matters")
                    .font(.title2.bold())

                Text("LifeNode is built on a foundation of absolute privacy. No data ever leaves your device.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private func policySection(icon: String, title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.purple)
                    .frame(width: 24)

                Text(title)
                    .font(.headline)
            }

            Text(content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var lastUpdated: some View {
        VStack(spacing: 4) {
            Text("Last Updated: March 2026")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Text("LifeNode v\(AppStoreMetadata.version)")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}
