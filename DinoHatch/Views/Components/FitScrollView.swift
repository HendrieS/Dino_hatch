import SwiftUI

/// A `ScrollView` that disables its own scrolling (and bounce) once its
/// content already fits within the visible area — e.g. a short screen on a
/// tall device, or fewer results after filtering. Compares the content's
/// natural height against the available viewport height via two
/// `PreferenceKey`s and flips `.scrollDisabled` accordingly, rather than
/// leaving scrolling (and the rubber-band bounce) enabled for content that
/// never actually needs to move. Drop-in replacement for a plain
/// `ScrollView { ... }` — same layout, just adds this behavior.
struct FitScrollView<Content: View>: View {
    @ViewBuilder var content: Content

    @State private var contentHeight: CGFloat = 0
    @State private var viewportHeight: CGFloat = 0

    /// A small tolerance (rather than a strict `>`) so a fraction-of-a-point
    /// rounding difference between the two measurements doesn't flip
    /// scrolling on for content that's actually an exact fit.
    private var isScrollable: Bool {
        contentHeight > viewportHeight + 1
    }

    var body: some View {
        ScrollView {
            content
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: FitScrollContentHeightKey.self, value: proxy.size.height)
                    }
                )
        }
        .background(
            GeometryReader { proxy in
                Color.clear.preference(key: FitScrollViewportHeightKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(FitScrollContentHeightKey.self) { contentHeight = $0 }
        .onPreferenceChange(FitScrollViewportHeightKey.self) { viewportHeight = $0 }
        .scrollDisabled(!isScrollable)
    }
}

private struct FitScrollContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct FitScrollViewportHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
