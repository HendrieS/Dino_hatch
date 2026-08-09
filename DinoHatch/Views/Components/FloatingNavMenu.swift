import SwiftUI

/// Replaces the system tab bar. A paw button stays anchored between the
/// bottom fern corners in both states — tapping it reveals a separate row
/// of destination icons floating above it, clear of that art, rather than
/// the paw itself growing into a pill or fading out while open. Both of
/// those alternatives were tried in an approved preview mockup and
/// rejected: growing the paw in place put the expanded row right over the
/// ferns, and hiding the paw while open meant an accidental tap had no
/// obvious way to back out. Keeping it fixed and always tappable makes
/// closing an accidental open exactly as easy as opening it.
struct FloatingNavMenu: View {
    @Binding var selectedTab: RootTabView.Tab
    var showAlarmBadge: Bool

    @State private var isOpen = false

    private let triggerDiameter: CGFloat = 60
    private let itemDiameter: CGFloat = 44

    var body: some View {
        ZStack {
            if isOpen {
                itemsRow
                    .transition(.scale(scale: 0.85, anchor: .bottom).combined(with: .opacity))
            }
            trigger
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.72), value: isOpen)
    }

    private var trigger: some View {
        Button {
            isOpen.toggle()
        } label: {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 22))
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

    private var itemsRow: some View {
        HStack(spacing: 12) {
            item(.timer, image: "menu-icon-timer", label: Text("Timer"))
            item(.alarm, image: "menu-icon-alarm", label: Text("Alarm"), showBadge: showAlarmBadge)
            item(.collection, image: "menu-icon-collection", label: Text("Collection"))
        }
        .padding(.horizontal, 14)
        .frame(height: triggerDiameter)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: triggerDiameter / 2))
        .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        // Clears the 200pt-tall fern corners rather than sitting over them
        // — see the trigger's own 30pt for comparison, matching the
        // approved mockup's "separate row above, not on top of" layout.
        .padding(.bottom, 190)
    }

    private func item(_ tab: RootTabView.Tab, image: String, label: Text, showBadge: Bool = false) -> some View {
        Button {
            selectedTab = tab
            isOpen = false
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .padding((itemDiameter - 26) / 2)
                    .background(selectedTab == tab ? Color.dinoGreen.opacity(0.16) : Color.clear, in: Circle())

                if showBadge {
                    Circle()
                        .fill(Color.dinoRed)
                        .frame(width: 9, height: 9)
                        .overlay(Circle().stroke(.ultraThinMaterial, lineWidth: 1.5))
                        .offset(x: 2, y: -2)
                }
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
