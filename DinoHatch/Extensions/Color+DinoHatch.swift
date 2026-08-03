import SwiftUI
import UIKit

extension Color {
    static let dinoGreen = Color(red: 0.20, green: 0.62, blue: 0.42)
    /// For destructive actions styled as a full primary button (e.g.
    /// Cancel Timer) — a warm coral rather than the harsher system red, to
    /// match dinoGreen's softer illustrated-app tone.
    static let dinoRed = Color(red: 0.85, green: 0.34, blue: 0.32)
    static let dinoCardBackground = Color(uiColor: .secondarySystemBackground)
    /// Gradient stops for `View.dinoWarmBackground()` — a warm cream tone
    /// replacing the plain system white app-wide, in the same tone family
    /// as the egg-hatch art's nest. Approved from a background-only mockup
    /// before touching any view code, first on the Timer screens, then
    /// extended to Alarm/Collection for consistency across the app.
    static let dinoWarmBackgroundTop = Color(red: 0.984, green: 0.969, blue: 0.918)
    static let dinoWarmBackgroundBottom = Color(red: 0.945, green: 0.906, blue: 0.800)
}

extension View {
    /// The warm cream gradient background used behind every main tab
    /// (Timer, Alarm, Collection) in place of the plain system white.
    func dinoWarmBackground() -> some View {
        background(
            LinearGradient(
                colors: [Color.dinoWarmBackgroundTop, Color.dinoWarmBackgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}
