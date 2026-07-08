#if DEBUG
import SwiftUI

/// Simple vector "skin" and "skeleton" art used only to demo/tune the
/// press & hold x-ray interaction before real artwork is wired up. Not part
/// of the production dinosaur catalog — see `AnatomyDemoView`.
enum PlaceholderAnatomyArt {
    static func skin(color: Color = Color(red: 0.72, green: 0.42, blue: 0.20)) -> some View {
        DinoSilhouette()
            .fill(color)
    }

    static func skeleton() -> some View {
        ZStack {
            DinoSilhouette()
                .stroke(Color(white: 0.9), lineWidth: 2)
            DinoRibs()
                .stroke(Color(white: 0.85), lineWidth: 2)
        }
    }
}

private struct DinoSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.addEllipse(in: CGRect(x: w * 0.20, y: h * 0.30, width: w * 0.55, height: h * 0.40))
        path.addEllipse(in: CGRect(x: w * 0.55, y: h * 0.12, width: w * 0.30, height: h * 0.26))

        path.move(to: CGPoint(x: w * 0.82, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.98, y: h * 0.28))
        path.addLine(to: CGPoint(x: w * 0.80, y: h * 0.34))
        path.closeSubpath()

        path.move(to: CGPoint(x: w * 0.22, y: h * 0.45))
        path.addQuadCurve(to: CGPoint(x: w * 0.02, y: h * 0.65), control: CGPoint(x: w * 0.08, y: h * 0.38))
        path.addQuadCurve(to: CGPoint(x: w * 0.28, y: h * 0.58), control: CGPoint(x: w * 0.10, y: h * 0.62))
        path.closeSubpath()

        path.addRoundedRect(
            in: CGRect(x: w * 0.32, y: h * 0.62, width: w * 0.14, height: h * 0.32),
            cornerSize: CGSize(width: 8, height: 8)
        )
        path.addRoundedRect(
            in: CGRect(x: w * 0.54, y: h * 0.62, width: w * 0.14, height: h * 0.32),
            cornerSize: CGSize(width: 8, height: 8)
        )
        path.addRoundedRect(
            in: CGRect(x: w * 0.58, y: h * 0.38, width: w * 0.16, height: h * 0.06),
            cornerSize: CGSize(width: 4, height: 4)
        )

        return path
    }
}

private struct DinoRibs: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.24, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.66, y: h * 0.30))

        for i in 0..<5 {
            let x = w * (0.30 + Double(i) * 0.07)
            path.move(to: CGPoint(x: x, y: h * 0.35))
            path.addQuadCurve(to: CGPoint(x: x, y: h * 0.62), control: CGPoint(x: x + w * 0.05, y: h * 0.48))
        }

        return path
    }
}
#endif
