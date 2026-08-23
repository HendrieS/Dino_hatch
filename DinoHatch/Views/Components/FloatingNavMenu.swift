import SwiftUI

/// Replaces the system tab bar. A paw button stays anchored between the
/// bottom fern corners in both states — tapping it reveals a compact panel
/// of destination icons above it, clear of that art, rather than the paw
/// itself growing into a pill or fading out while open. Both of those
/// alternatives were tried in an approved preview mockup and rejected:
/// growing the paw in place put the expanded row right over the ferns, and
/// hiding the paw while open meant an accidental tap had no obvious way to
/// back out. Keeping it fixed and always tappable makes closing an
/// accidental open exactly as easy as opening it.
///
/// The panel's own fill is a small "iris" — modeled on a Pokémon GO menu
/// clip the user shared, where the trigger button's color radiates out to
/// reveal the menu, anchored at one fixed point the whole time. A full-
/// screen version of that (matching the clip exactly) was previewed first
/// and set aside as too theatrical for only 3 destinations; this keeps the
/// same "color grows from the button" feel scaled down to a small panel.
struct FloatingNavMenu: View {
    @Binding var selectedTab: RootTabView.Tab
    var showAlarmBadge: Bool

    @State private var isOpen = false

    private let triggerDiameter: CGFloat = 90
    private let itemDiameter: CGFloat = 44
    private let panelWidth: CGFloat = 220
    private let panelHeight: CGFloat = 150
    private let panelCornerRadius: CGFloat = 26

    var body: some View {
        ZStack {
            panel
            trigger
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.72), value: isOpen)
    }

    private var trigger: some View {
        Button {
            isOpen.toggle()
        } label: {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.dinoGreen)
                .frame(width: triggerDiameter, height: triggerDiameter)
                .background(isOpen ? Color.dinoGreen.opacity(0.18) : Color.clear, in: Circle())
                .background(.ultraThinMaterial, in: Circle())
                .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 30)
        .accessibilityLabel(Text("Menu"))
        .accessibilityHint(Text("Shows Timer, Alarm, and Collection"))
    }

    private var panel: some View {
        ZStack {
            iris

            VStack(spacing: 10) {
                Text("Where to?")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.85))

                HStack(spacing: 14) {
                    item(.timer, image: "menu-icon-timer", label: Text("Timer"))
                    item(.alarm, image: "menu-icon-alarm", label: Text("Alarm"), showBadge: showAlarmBadge)
                    item(.collection, image: "menu-icon-collection", label: Text("Collection"))
                }
            }
            // Fades in on its own delay, after the iris has had a moment to
            // grow — matches the reference clip's own staggered timing
            // (fill first, icons a beat later) rather than popping in with
            // the panel itself.
            .opacity(isOpen ? 1 : 0)
            .animation(.easeOut(duration: 0.22).delay(isOpen ? 0.15 : 0), value: isOpen)
        }
        .frame(width: panelWidth, height: panelHeight)
        .clipShape(RoundedRectangle(cornerRadius: panelCornerRadius))
        .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
        .opacity(isOpen ? 1 : 0)
        .scaleEffect(isOpen ? 1 : 0.6, anchor: .bottom)
        .allowsHitTesting(isOpen)
        .accessibilityHidden(!isOpen)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        // Clears the 200pt-tall fern corners rather than sitting over them
        // — see the trigger's own 30pt for comparison, matching the
        // approved mockup's "separate row above, not on top of" layout.
        // Lowered from 190 -> 160 -> 130 per feedback that it sat too high.
        .padding(.bottom, 130)
    }

    /// The panel's fill: a big circle anchored at the panel's own
    /// bottom-center (right above the paw below it) that scales up from
    /// nearly nothing to cover the panel when open — the "color radiates
    /// from the button" look, just clipped to a small rounded rect instead
    /// of the whole screen. `panelHeight / 2` offsets the circle so its own
    /// bottom edge (the `.bottom` anchor `scaleEffect` scales around) lands
    /// exactly on the panel's bottom edge at every scale, not just at 1.
    private var iris: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Color.dinoGreen, Color.dinoGreenShadow],
                    center: .center,
                    startRadius: 0,
                    endRadius: panelWidth
                )
            )
            .frame(width: panelWidth * 2, height: panelWidth * 2)
            .offset(y: panelHeight / 2)
            .scaleEffect(isOpen ? 1 : 0.0001, anchor: .bottom)
    }

    private func item(_ tab: RootTabView.Tab, image: String, label: Text, showBadge: Bool = false) -> some View {
        Button {
            selectedTab = tab
            isOpen = false
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding((itemDiameter - 24) / 2)
                        .background(.white, in: Circle())
                        .overlay(Circle().stroke(Color.dinoGreen, lineWidth: selectedTab == tab ? 2 : 0))

                    if showBadge {
                        Circle()
                            .fill(Color.dinoRed)
                            .frame(width: 9, height: 9)
                            .overlay(Circle().stroke(.white, lineWidth: 1.5))
                            .offset(x: 2, y: -2)
                    }
                }

                label
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
    }
}

#Preview {
    ZStack {
        Color.dinoWarmBackgroundTop.ignoresSafeArea()
        FloatingNavMenu(selectedTab: .constant(.timer), showAlarmBadge: true)
    }
}
