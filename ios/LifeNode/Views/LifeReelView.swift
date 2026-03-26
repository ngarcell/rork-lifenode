import SwiftUI
import SwiftData

struct LifeReelView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = LifeReelViewModel()
    @State private var engagementService = EngagementService()
    @State private var subscriptionService = SubscriptionService.shared
    @State private var showGenerating: Bool = false
    @State private var showPaywall: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    heroSection
                    smartTemplatesSection
                    customizeSection
                    generateButton
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .navigationTitle("Life Reel")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $viewModel.showPreview) {
                ReelPreviewView(viewModel: viewModel)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .fullScreenCover(isPresented: $showGenerating) {
                ReelGeneratingView(viewModel: viewModel) {
                    showGenerating = false
                }
            }
            .onAppear {
                viewModel.loadSmartTemplates(modelContext: modelContext)
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.6), .blue.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)

                VStack(spacing: 12) {
                    Image(systemName: "film.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)

                    Text("Create Your Life Reel")
                        .font(.title3.bold())
                        .foregroundStyle(.white)

                    Text("Turn your memories into shareable stories")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
    }

    @ViewBuilder
    private var smartTemplatesSection: some View {
        if !viewModel.smartTemplates.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Suggested For You")
                    .font(.headline)

                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.smartTemplates) { template in
                            Button {
                                withAnimation(.snappy) {
                                    viewModel.applyTemplate(template)
                                }
                            } label: {
                                smartTemplateCard(template)
                            }
                            .sensoryFeedback(.selection, trigger: viewModel.selectedTheme)
                        }
                    }
                }
                .contentMargins(.horizontal, 0)
                .scrollIndicators(.hidden)
            }
        }
    }

    private func smartTemplateCard(_ template: SmartTemplate) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: template.icon)
                .font(.title2)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 3) {
                Text(template.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(template.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
            }
        }
        .padding(16)
        .frame(width: 170, alignment: .leading)
        .background(
            LinearGradient(
                colors: themeColors(template.theme),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 16))
    }

    private var customizeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Customize")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Time Range")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(ReelTimeRange.allCases) { range in
                            Button {
                                withAnimation(.snappy) {
                                    viewModel.selectedTimeRange = range
                                }
                            } label: {
                                Text(range.rawValue)
                                    .font(.subheadline.weight(.medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        viewModel.selectedTimeRange == range
                                            ? AnyShapeStyle(Color.purple)
                                            : AnyShapeStyle(Color(.tertiarySystemFill))
                                    )
                                    .foregroundStyle(
                                        viewModel.selectedTimeRange == range ? .white : .primary
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .contentMargins(.horizontal, 0)
                .scrollIndicators(.hidden)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Theme")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                    ForEach(ReelTheme.allCases) { theme in
                        Button {
                            withAnimation(.snappy) {
                                viewModel.selectedTheme = theme
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: theme.icon)
                                    .font(.title3)
                                Text(theme.rawValue)
                                    .font(.caption.weight(.medium))
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                viewModel.selectedTheme == theme
                                    ? AnyShapeStyle(Color.purple.opacity(0.2))
                                    : AnyShapeStyle(Color(.tertiarySystemFill))
                            )
                            .foregroundStyle(
                                viewModel.selectedTheme == theme ? .purple : .primary
                            )
                            .clipShape(.rect(cornerRadius: 12))
                            .overlay {
                                if viewModel.selectedTheme == theme {
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(.purple, lineWidth: 1.5)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var generateButton: some View {
        VStack(spacing: 8) {
            Button {
                if subscriptionService.hasReachedReelLimit() {
                    showPaywall = true
                } else {
                    showGenerating = true
                    Task {
                        await viewModel.generateReel(modelContext: modelContext)
                        engagementService.incrementReelsGenerated()
                        subscriptionService.recordReelGenerated()
                        showGenerating = false
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "wand.and.stars")
                    Text("Generate Life Reel")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)

            if !subscriptionService.isPremium {
                Text("\(subscriptionService.remainingFreeReels) free reels remaining this month")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func themeColors(_ theme: ReelTheme) -> [Color] {
        switch theme {
        case .highlights: return [.purple, .blue]
        case .adventure: return [.orange, .red]
        case .relaxation: return [.green, .teal]
        case .fitness: return [.green, .yellow]
        case .musicMemories: return [.purple, .pink]
        case .photoAlbum: return [.blue, .cyan]
        }
    }
}

struct ReelGeneratingView: View {
    let viewModel: LifeReelViewModel
    let onComplete: () -> Void
    @State private var orbitAngle: Double = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                ZStack {
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(orbColor(i).gradient)
                            .frame(width: 16, height: 16)
                            .offset(x: cos(orbitAngle + Double(i) * .pi / 2) * 50,
                                    y: sin(orbitAngle + Double(i) * .pi / 2) * 50)
                            .blur(radius: 2)
                    }

                    Image(systemName: "film.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 12) {
                    Text(viewModel.generationStatus)
                        .font(.headline)
                        .foregroundStyle(.white)

                    ProgressView(value: viewModel.generationProgress)
                        .progressViewStyle(.linear)
                        .tint(.purple)
                        .frame(maxWidth: 260)

                    Text("\(Int(viewModel.generationProgress * 100))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.white.opacity(0.6))
                        .contentTransition(.numericText())
                }

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                orbitAngle = .pi * 2
            }
        }
        .onChange(of: viewModel.showPreview) { _, show in
            if show { onComplete() }
        }
    }

    private func orbColor(_ index: Int) -> Color {
        [Color.purple, .blue, .pink, .cyan][index % 4]
    }
}

struct ReelPreviewView: View {
    let viewModel: LifeReelViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int = 0
    @State private var showShareSheet: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if !viewModel.generatedImages.isEmpty {
                    TabView(selection: $currentIndex) {
                        ForEach(Array(viewModel.generatedImages.enumerated()), id: \.offset) { index, image in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(.white)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: viewModel.shareItems())
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
