import SwiftUI

struct HeartRateGraph: View {
    let samples: [Double]

    var body: some View {
        GeometryReader { geo in
            let minHR = (samples.min() ?? 60) - 5
            let maxHR = (samples.max() ?? 180) + 5
            let range = maxHR - minHR

            Path { path in
                for (index, sample) in samples.enumerated() {
                    let x = geo.size.width * CGFloat(index) / CGFloat(max(samples.count - 1, 1))
                    let y = geo.size.height * (1 - CGFloat((sample - minHR) / range))

                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(
                LinearGradient(colors: [.green, .yellow, .red], startPoint: .bottom, endPoint: .top),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )
        }
    }
}
