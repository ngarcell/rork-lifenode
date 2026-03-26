import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Binding var hasOnboarded: Bool
    @Environment(\.modelContext) private var modelContext
    @State private var currentPhase: OnboardingPhase = .welcome
    @State private var ingestionVM = DataIngestionViewModel()
    @State private var animatePulse: Bool = false
    @State private var particlePhase: Int = 0

    private enum OnboardingPhase {
        case welcome
        case permissions
        case scanning
        case tutorial
    }

    var body: some View {
        ZStack {
            backgroundGradient
            
            switch currentPhase {
            case .welcome:
                welcomePhase
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity.combined(with: .move(edge: .leading))
                    ))
            case .permissions:
                permissionsPhase
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity.combined(with: .move(edge: .leading))
                    ))
            case .scanning:
                scanningPhase
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity.combined(with: .scale(scale: 1.05).combined(with: .opacity))
                    ))
            case .tutorial:
                tutorialPhase
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .preferredColorScheme(.dark)
    }

    private var backgroundGradient: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ],
            colors: [
                .black, Color(.systemIndigo).opacity(0.3), .black,
                Color(.systemPurple).opacity(0.2), .black, Color(.systemBlue).opacity(0.2),
                .black, Color(.systemIndigo).opacity(0.15), .black
            ]
        )
        .ignoresSafeArea()
    }

    private var welcomePhase: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                ForEach(0..<3, id: \.self) { ring in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.purple.opacity(0.6), .blue.opacity(0.3), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: CGFloat(100 + ring * 50), height: CGFloat(100 + ring * 50))
                        .scaleEffect(animatePulse ? 1.1 : 0.9)
                        .opacity(animatePulse ? 0.8 : 0.3)
                        .animation(
                            .easeInOut(duration: 2.0).delay(Double(ring) * 0.3).repeatForever(autoreverses: true),
                            value: animatePulse
                        )
                }

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 56, weight: .thin))
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .symbolEffect(.breathe, isActive: animatePulse)
            }
            .padding(.bottom, 48)

            VStack(spacing: 16) {
                Text("LifeNode")
                    .font(.system(size: 42, weight: .bold, design: .default))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, .white.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    )

                Text("Your Digital Twin")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)

                Text("Transform your scattered memories into\nan interactive, private Memory Graph")
                    .font(.subheadline)
                    .foregroundStyle(.secondary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

            Spacer()
            Spacer()

            VStack(spacing: 16) {
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        currentPhase = .permissions
                    }
                } label: {
                    Text("Begin")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)

                HStack(spacing: 6) {
                    Image(systemName: "lock.shield.fill")
                        .font(.caption2)
                    Text("100% on-device. No accounts required.")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear { animatePulse = true }
    }

    private var permissionsPhase: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("Build Your Memory Graph")
                    .font(.title2.bold())

                Text("LifeNode needs access to your data to create\nyour personal Memory Graph on-device.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 60)
            .padding(.horizontal, 24)

            VStack(spacing: 0) {
                permissionCard(
                    icon: "photo.on.rectangle.angled",
                    color: .blue,
                    title: "Photos",
                    subtitle: "Location & date metadata from your photos to map memories geographically.",
                    isGranted: ingestionVM.photoKitService.isAuthorized
                )

                permissionCard(
                    icon: "heart.fill",
                    color: .red,
                    title: "Health & Fitness",
                    subtitle: "Workout history, heart rate, and activity data to capture fitness memories.",
                    isGranted: ingestionVM.healthKitService.isAuthorized
                )

                permissionCard(
                    icon: "music.note",
                    color: .purple,
                    title: "Apple Music",
                    subtitle: "Listening history to connect songs with moments in your life.",
                    isGranted: ingestionVM.musicKitService.isAuthorized
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)

            Spacer()

            dataFlowDiagram
                .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    Task {
                        await ingestionVM.requestAllPermissions()
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            currentPhase = .scanning
                        }
                        Task {
                            await ingestionVM.performInitialScan(modelContext: modelContext)
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                currentPhase = .tutorial
                            }
                        }
                    }
                } label: {
                    Text("Grant Access & Scan")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)

                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        currentPhase = .scanning
                    }
                    Task {
                        await ingestionVM.performInitialScan(modelContext: modelContext)
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            currentPhase = .tutorial
                        }
                    }
                } label: {
                    Text("Skip for Now")
                        .font(.subheadline)
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func permissionCard(icon: String, color: Color, title: String, subtitle: String, isGranted: Bool) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    if isGranted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(.vertical, 14)
    }

    private var dataFlowDiagram: some View {
        HStack(spacing: 12) {
            Image(systemName: "iphone")
                .font(.title3)
            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundStyle(.secondary)
            Image(systemName: "cpu")
                .font(.title3)
                .foregroundStyle(.purple)
            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundStyle(.secondary)
            Image(systemName: "brain.head.profile")
                .font(.title3)
                .foregroundStyle(.blue)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
        }
    }

    private var scanningPhase: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(.purple.opacity(0.2), lineWidth: 3)
                    .frame(width: 160, height: 160)

                Circle()
                    .trim(from: 0, to: scanProgress)
                    .stroke(
                        LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.smooth(duration: 0.5), value: scanProgress)

                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40, weight: .thin))
                        .foregroundStyle(.purple)
                        .symbolEffect(.pulse, isActive: ingestionVM.isIngesting)

                    Text("\(Int(scanProgress * 100))%")
                        .font(.title3.bold().monospacedDigit())
                        .contentTransition(.numericText())
                }
            }

            VStack(spacing: 12) {
                Text("Building Your Memory Graph")
                    .font(.title3.bold())

                Text(ingestionVM.ingestionProgress)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .animation(.smooth, value: ingestionVM.ingestionProgress)

                if ingestionVM.totalNodesIngested > 0 {
                    Text("\(ingestionVM.totalNodesIngested) memories discovered")
                        .font(.caption)
                        .foregroundStyle(.purple)
                        .contentTransition(.numericText())
                }
            }

            Spacer()
            Spacer()
        }
    }

    private var scanProgress: Double {
        if ingestionVM.ingestionProgress.contains("Scan complete") { return 1.0 }
        if ingestionVM.ingestionProgress.contains("graph") { return 0.85 }
        if ingestionVM.ingestionProgress.contains("photos") { return 0.6 }
        if ingestionVM.ingestionProgress.contains("music") { return 0.4 }
        if ingestionVM.ingestionProgress.contains("workouts") { return 0.2 }
        return 0.05
    }

    private var tutorialPhase: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(.purple.gradient.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: particlePhase)
            }
            .padding(.bottom, 32)

            VStack(spacing: 16) {
                Text("Your Memory Graph is Ready")
                    .font(.title2.bold())

                if ingestionVM.totalNodesIngested > 0 {
                    Text("\(ingestionVM.totalNodesIngested) memories · \(ingestionVM.totalLinksCreated) connections")
                        .font(.subheadline)
                        .foregroundStyle(.purple)
                }

                Text("Explore your memories on the 3D map.\nTap nodes to see details, pinch to zoom,\nand discover hidden connections.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

            Spacer()

            VStack(spacing: 24) {
                tutorialHint(icon: "hand.tap.fill", text: "Tap memory nodes to explore details")
                tutorialHint(icon: "hand.pinch.fill", text: "Pinch to zoom into clusters")
                tutorialHint(icon: "film.fill", text: "Generate Life Reels to share your story")
            }
            .padding(.horizontal, 32)

            Spacer()

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    hasOnboarded = true
                }
            } label: {
                Text("Explore My Memories")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear { particlePhase += 1 }
    }

    private func tutorialHint(icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.purple)
                .frame(width: 32)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}
