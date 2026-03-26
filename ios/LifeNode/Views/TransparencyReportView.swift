import SwiftUI

struct TransparencyReportView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection

                architectureSection

                dataAccessSection

                networkSection

                thirdPartySection

                commitmentSection
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .navigationTitle("Transparency Report")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.blue.gradient.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 36))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 6) {
                Text("Full Transparency")
                    .font(.title2.bold())

                Text("A detailed look at exactly what LifeNode accesses, processes, and stores — and what it doesn't.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private var architectureSection: some View {
        reportCard(title: "Architecture", icon: "cpu") {
            VStack(alignment: .leading, spacing: 12) {
                bulletPoint("All computation runs on your device's CPU/GPU")
                bulletPoint("No network requests for core functionality")
                bulletPoint("No cloud accounts or remote databases")
                bulletPoint("SwiftData local storage within app sandbox")
                bulletPoint("CoreML inference runs entirely on-device")
                bulletPoint("Vision framework processing is local-only")
            }
        }
    }

    private var dataAccessSection: some View {
        reportCard(title: "Data Access Summary", icon: "list.clipboard") {
            VStack(spacing: 0) {
                dataRow(source: "Photos", access: "Metadata only", stored: "Location, date", shared: "Never")
                Divider().padding(.vertical, 8)
                dataRow(source: "HealthKit", access: "Read-only", stored: "Workouts, HR", shared: "Never")
                Divider().padding(.vertical, 8)
                dataRow(source: "MusicKit", access: "Read-only", stored: "Song titles", shared: "Never")
                Divider().padding(.vertical, 8)
                dataRow(source: "Location", access: "When in use", stored: "Coordinates", shared: "Never")
                Divider().padding(.vertical, 8)
                dataRow(source: "Notifications", access: "Optional", stored: "Schedules", shared: "Never")
            }
        }
    }

    private var networkSection: some View {
        reportCard(title: "Network Activity", icon: "network.slash") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Zero outbound network connections")
                        .font(.subheadline)
                }
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("No analytics or telemetry transmitted")
                        .font(.subheadline)
                }
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("No advertising or tracking SDKs")
                        .font(.subheadline)
                }
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("App functions fully offline")
                        .font(.subheadline)
                }
            }
        }
    }

    private var thirdPartySection: some View {
        reportCard(title: "Third-Party Code", icon: "shippingbox") {
            VStack(alignment: .leading, spacing: 8) {
                Text("LifeNode uses only Apple first-party frameworks:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    frameworkRow("SwiftUI", purpose: "User interface")
                    frameworkRow("SwiftData", purpose: "Local data persistence")
                    frameworkRow("MapKit", purpose: "3D map rendering")
                    frameworkRow("HealthKit", purpose: "Fitness data access")
                    frameworkRow("MusicKit", purpose: "Music history access")
                    frameworkRow("PhotoKit", purpose: "Photo metadata access")
                    frameworkRow("Vision", purpose: "On-device image analysis")
                    frameworkRow("CoreML", purpose: "On-device intelligence")
                    frameworkRow("AVFoundation", purpose: "Video export")
                    frameworkRow("BackgroundTasks", purpose: "Efficient updates")
                }
            }
        }
    }

    private var commitmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Our Commitment")
                .font(.headline)

            Text("LifeNode will never introduce tracking, advertising, or data collection. Our business model is simple: a free, powerful tool that respects your privacy. You are not the product.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [.purple.opacity(0.08), .blue.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 14))
    }

    private func reportCard(title: String, icon: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                    .frame(width: 24)

                Text(title)
                    .font(.headline)
            }

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(.secondary)
                .frame(width: 5, height: 5)
                .padding(.top, 6)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func dataRow(source: String, access: String, stored: String, shared: String) -> some View {
        HStack {
            Text(source)
                .font(.subheadline.weight(.medium))
                .frame(width: 80, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text("Access: \(access)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Stored: \(stored)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(shared)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.green)
        }
    }

    private func frameworkRow(_ name: String, purpose: String) -> some View {
        HStack(spacing: 8) {
            Text(name)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())

            Text(purpose)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
