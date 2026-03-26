import SwiftUI

struct SingleNodeMarker: View {
    let node: MemoryNode

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(colorForType.gradient)
                    .frame(width: 40, height: 40)
                    .shadow(color: colorForType.opacity(0.6), radius: 8, y: 2)

                Image(systemName: node.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Triangle()
                .fill(colorForType)
                .frame(width: 12, height: 8)
                .offset(y: -1)
        }
    }

    private var colorForType: Color {
        switch node.type {
        case .photo: return .blue
        case .workout: return .green
        case .music: return .purple
        case .checkin: return .orange
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
