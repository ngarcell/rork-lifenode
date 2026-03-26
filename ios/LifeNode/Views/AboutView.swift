import SwiftUI

struct AboutView: View {
    @State private var animateLogo: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                logoSection

                taglineSection

                featureHighlights

                privacyBadge

                linksSection

                versionInfo
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    private var logoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                ForEach(0..<3, id: \.self) { ring in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.purple.opacity(0.4), .blue.opacity(0.2), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: CGFloat(70 + ring * 30), height: CGFloat(70 + ring * 30))
                        .scaleEffect(animateLogo ? 1.05 : 0.95)
                        .animation(
                            .easeInOut(duration: 2.0).delay(Double(ring) * 0.2).repeatForever(autoreverses: true),
                            value: animateLogo
                        )
                }

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 36, weight: .thin))
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            .frame(height: 140)

            Text(AppStoreMetadata.appName)
                .font(.title.bold())

            Text(AppStoreMetadata.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
        .onAppear { animateLogo = true }
    }

    private var taglineSection: some View {
        Text(AppStoreMetadata.shortDescription)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }

    private var featureHighlights: some View {
        VStack(spacing: 0) {
            featureRow(icon: "globe.americas.fill", title: "3D Memory Map", subtitle: "Explore memories on a satellite map", color: .blue)
            Divider().padding(.leading, 56)
            featureRow(icon: "film.fill", title: "Life Reels", subtitle: "Create shareable video compilations", color: .purple)
            Divider().padding(.leading, 56)
            featureRow(icon: "brain", title: "Smart Connections", subtitle: "AI discovers hidden memory links", color: .indigo)
            Divider().padding(.leading, 56)
            featureRow(icon: "lock.shield.fill", title: "100% Private", subtitle: "All data stays on your device", color: .green)
            Divider().padding(.leading, 56)
            featureRow(icon: "crown.fill", title: "Premium Available", subtitle: "Unlock unlimited nodes, reels & analytics", color: .orange)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func featureRow(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var privacyBadge: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.title2)
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text("Privacy Verified")
                    .font(.subheadline.weight(.semibold))
                Text("Zero data collection · No tracking · No ads")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(.green.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var linksSection: some View {
        VStack(spacing: 0) {
            NavigationLink {
                PrivacyPolicyView()
            } label: {
                linkRow(icon: "hand.raised.fill", title: "Privacy Policy", color: .purple)
            }

            Divider().padding(.leading, 56)

            NavigationLink {
                TransparencyReportView()
            } label: {
                linkRow(icon: "doc.text.magnifyingglass", title: "Transparency Report", color: .blue)
            }

            Divider().padding(.leading, 56)

            NavigationLink {
                UsageStatsView()
            } label: {
                linkRow(icon: "chart.bar.fill", title: "Your Usage Stats", color: .orange)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func linkRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
                .frame(width: 32)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var versionInfo: some View {
        VStack(spacing: 4) {
            Text("Version \(AppStoreMetadata.version) (\(AppStoreMetadata.buildNumber))")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Text("Made with privacy in mind")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}
