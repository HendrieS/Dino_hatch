import SwiftUI

extension Text {
    /// Looks `key` up in the localization tables using the English catalog
    /// text itself as the key — the standard String Catalog pattern —
    /// instead of showing it as literal, unlocalized text.
    ///
    /// Used for data-driven strings (dinosaur names/eras/fun facts from
    /// `DinosaurCatalog`) that arrive as a runtime `String` rather than a
    /// call-site literal, so SwiftUI's automatic `Text(String)` overload
    /// can't localize them on its own.
    init(localizedContent key: String) {
        self.init(LocalizedStringKey(key))
    }
}
