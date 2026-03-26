import SwiftUI

struct ClusterMarker: View {
    let cluster: NodeCluster

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: markerSize, height: markerSize)
                .overlay {
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: uniqueColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                }
                .shadow(color: .black.opacity(0.4), radius: 6, y: 3)

            VStack(spacing: 1) {
                Text("\(cluster.count)")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                if cluster.count < 20 {
                    Image(systemName: cluster.primaryType.icon)
                        .font(.system(size: iconSize))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
    }

    private var markerSize: CGFloat {
        let base: CGFloat = 44
        let scale = min(CGFloat(cluster.count) / 10.0, 2.0)
        return base + scale * 16
    }

    private var fontSize: CGFloat {
        cluster.count >= 100 ? 14 : 16
    }

    private var iconSize: CGFloat {
        cluster.count >= 100 ? 8 : 10
    }

    private var uniqueColors: [Color] {
        let types = Set(cluster.nodes.map(\.type))
        return types.map { type in
            switch type {
            case .photo: return Color.blue
            case .workout: return Color.green
            case .music: return Color.purple
            case .checkin: return Color.orange
            }
        }
    }
}
