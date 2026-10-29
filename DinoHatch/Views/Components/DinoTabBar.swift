import SwiftUI

/// Layout facts about the bottom tab bar that the tab screens themselves
/// need — `RootTabView` measures them once and hands them down through the
/// environment, rather than each screen guessing at the bar's height or the
/// device's home-indicator inset on its own.
struct DinoTabBarMetrics: Equatable {
    /// How far the bottom fern corners sit above the screen's bottom edge.
    /// The home-indicator strip plus 8pt, so the ferns grow up from behind
    /// the bar instead of being mostly hidden by it — picked from the
    /// approved mockup (8pt rather than 12–24 so Collection still fits two
    /// full rows of cards above its fade on a 13 mini). 0 while the bar is
    /// hidden (a pushed detail view, the hatch celebration).
    var fernLift: CGFloat = 0
    /// The bar's full height, home-indicator strip included. 0 while hidden.
    var barHeight: CGFloat = 0
    /// True when the space between the status bar and the tab bar is too
    /// short for the regular Timer layout (sign + 260pt ring + time + Start
    /// button) — iPhone SE and iPad mini in landscape. Screens shrink the
    /// sign and ring a little instead of pushing Start behind the bar.
    var isCompact = false
}

private struct DinoTabBarMetricsKey: EnvironmentKey {
    static let defaultValue = DinoTabBarMetrics()
}

extension EnvironmentValues {
    var dinoTabBarMetrics: DinoTabBarMetrics {
        get { self[DinoTabBarMetricsKey.self] }
        set { self[DinoTabBarMetricsKey.self] = newValue }
    }
}

/// The app's bottom navigation, replacing the earlier paw button + pop-up
/// menu after tester feedback that a second tap to reach a screen felt like
/// a sub-menu. A plain cream bar with a straight top edge (approved over a
/// leafy-garland edge, a wooden plank, stones and a moss bank in the
/// mockup), with the selected tab marked by a leaf-shaped highlight rather
/// than a circle. On iPad the three tabs stay grouped in the middle instead
/// of spreading across the full width.
struct DinoTabBar: View {
    @Binding var selectedTab: RootTabView.Tab
    var showAlarmBadge: Bool

    /// The bar's height above the home-indicator strip — `RootTabView` adds
    /// the strip on top of this for `DinoTabBarMetrics.barHeight`.
    static let contentHeight: CGFloat = 68

    private static let cream = Color(red: 1.0, green: 0.984, blue: 0.941)
    private static let edge = Color(red: 0.890, green: 0.847, blue: 0.737)
    private static let leafFill = Color(red: 0.847, green: 0.933, blue: 0.851)
    private static let unselectedLabel = Color(red: 0.361, green: 0.322, blue: 0.255)

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            item(.timer, image: "menu-icon-timer", label: Text("Timer"))
            item(.alarm, image: "menu-icon-alarm", label: Text("Alarm"), showBadge: showAlarmBadge)
            item(.collection, image: "menu-icon-collection", label: Text("Collection"))
        }
        .frame(maxWidth: 480)
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
        .frame(height: Self.contentHeight, alignment: .top)
        .background {
            Self.cream
                .overlay(alignment: .top) {
                    Self.edge.frame(height: 1)
                }
                .shadow(color: Color(red: 0.24, green: 0.16, blue: 0.04).opacity(0.10), radius: 8, y: -4)
                .ignoresSafeArea(edges: .bottom)
        }
        .sensoryFeedback(.selection, trigger: selectedTab)
    }

    private func item(_ tab: RootTabView.Tab, image: String, label: Text, showBadge: Bool = false) -> some View {
        let isSelected = selectedTab == tab
        let leaf = UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: 19,
            bottomTrailingRadius: 0,
            topTrailingRadius: 19
        )

        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 2) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 54, height: 38)
                    .background(isSelected ? Self.leafFill : .clear, in: leaf)
                    .overlay {
                        if isSelected {
                            leaf.stroke(Color.dinoGreen, lineWidth: 2)
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        if showBadge {
                            Circle()
                                .fill(Color.dinoRed)
                                .frame(width: 10, height: 10)
                                .overlay(Circle().stroke(.white, lineWidth: 1.5))
                                .offset(x: -2, y: -3)
                        }
                    }

                label
                    .font(.system(size: 12, weight: isSelected ? .heavy : .bold, design: .rounded))
                    .foregroundStyle(isSelected ? Color.dinoGreenShadow : Self.unselectedLabel)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    VStack {
        Spacer()
        DinoTabBar(selectedTab: .constant(.timer), showAlarmBadge: true)
    }
    .background(Color.dinoWarmBackgroundTop)
}
