import SwiftUI
import MapKit
import SwiftData

struct MemoryMapView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = MapViewModel()
    @State private var engagementService = EngagementService()
    @State private var selectedNode: MemoryNode?
    @State private var showingCard: Bool = false
    @Namespace private var mapNamespace

    var body: some View {
        ZStack {
            Map(position: $viewModel.cameraPosition) {
                ForEach(viewModel.clusters) { cluster in
                    if cluster.isSingle, let node = cluster.nodes.first {
                        Annotation("", coordinate: cluster.coordinate) {
                            SingleNodeMarker(node: node)
                                .matchedTransitionSource(id: node.id, in: mapNamespace)
                                .onTapGesture {
                                    selectedNode = node
                                    showingCard = true
                                    engagementService.recordCardView()
                                }
                        }
                    } else {
                        Annotation("", coordinate: cluster.coordinate) {
                            ClusterMarker(cluster: cluster)
                        }
                    }
                }
            }
            .mapStyle(.imagery(elevation: .realistic))
            .mapControls {
                MapCompass()
                MapScaleView()
                MapPitchToggle()
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                viewModel.updateZoom(context.region.span)
                viewModel.loadNodes(modelContext: modelContext)
            }

            VStack {
                Spacer()
                filterBar
            }
        }
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
        .onAppear {
            engagementService.startSession()
            viewModel.loadNodes(modelContext: modelContext)
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    icon: "globe",
                    isSelected: viewModel.filterType == nil
                ) {
                    viewModel.filterType = nil
                    viewModel.loadNodes(modelContext: modelContext)
                }

                ForEach(MemoryNodeType.allCases, id: \.self) { type in
                    FilterChip(
                        title: type.displayName,
                        icon: type.icon,
                        isSelected: viewModel.filterType == type
                    ) {
                        viewModel.filterType = type
                        viewModel.loadNodes(modelContext: modelContext)
                    }
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
        .padding(.bottom, 8)
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? AnyShapeStyle(Color.white) : AnyShapeStyle(.ultraThinMaterial))
            .foregroundStyle(isSelected ? Color.black : Color.white)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}
