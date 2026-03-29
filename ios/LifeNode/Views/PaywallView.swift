import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subscriptionService = SubscriptionService.shared
    @State private var animateGlow: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    featuresSection
                    pricingCard
                    legalSection
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.purple.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(animateGlow ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateGlow)

                Image(systemName: "crown.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                    )
            }

            Text("Unlock LifeNode Premium")
                .font(.title2.bold())

            Text("Unlimited memories, unlimited reels,\nand deeper insights into your life.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
        .onAppear { animateGlow = true }
    }

    private var featuresSection: some View {
        VStack(spacing: 0) {
            premiumFeatureRow(
                icon: "infinity",
                title: "Unlimited Memory Nodes",
                subtitle: "Map your entire digital history",
                color: .purple
            )
            Divider().padding(.leading, 56)
            premiumFeatureRow(
                icon: "film.fill",
                title: "Unlimited Pro Reels",
                subtitle: "Custom music, themes & HD export",
                color: .blue
            )
            Divider().padding(.leading, 56)
            premiumFeatureRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "Advanced Analytics",
                subtitle: "Trends, patterns & deep insights",
                color: .green
            )
            Divider().padding(.leading, 56)
            premiumFeatureRow(
                icon: "heart.text.clipboard.fill",
                title: "Priority Support",
                subtitle: "Dedicated help when you need it",
                color: .orange
            )
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func premiumFeatureRow(icon: String, title: String, subtitle: String, color: Color) -> some View {
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

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var pricingCard: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text(subscriptionService.formattedPrice)
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                Text("per year")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("7-day free trial included")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.purple.opacity(0.1))
                    .clipShape(Capsule())
            }

            Button {
                Task { await subscriptionService.purchase() }
            } label: {
                HStack(spacing: 8) {
                    if subscriptionService.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("Start Free Trial")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .disabled(subscriptionService.isLoading)

            Button {
                Task { await subscriptionService.restorePurchases() }
            } label: {
                Text("Restore Purchases")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let error = subscriptionService.purchaseError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
    }

    private var legalSection: some View {
        VStack(spacing: 8) {
            Text("Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link("Terms of Use", destination: URL(string: "https://socialreporthq.com/lifenode/terms")!)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Link("Privacy Policy", destination: URL(string: "https://socialreporthq.com/lifenode/privacy/")!)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
