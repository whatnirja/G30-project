import SwiftUI

struct DiagonalOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            Path { path in
                path.move(to: CGPoint(x: 0, y: h * 0.55))
                path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.20))
                path.addLine(to: CGPoint(x: w, y: h * 0.20))
                path.addLine(to: CGPoint(x: w, y: h))
                path.addLine(to: CGPoint(x: 0, y: h))
                path.closeSubpath()
            }
            .fill(.white.opacity(0.10))
        }
    }
}
