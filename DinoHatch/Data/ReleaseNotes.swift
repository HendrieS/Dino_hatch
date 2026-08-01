import Foundation

/// One entry per app version that has something worth telling a returning
/// parent about — not every build needs one. `WhatsNewGate` shows these in a
/// sheet the first time the app opens after updating; a version with no
/// entry here just updates `AppSettings.lastSeenAppVersion` silently.
///
/// To add one for a new release: append a `ReleaseNote` below with the exact
/// `CFBundleShortVersionString` you're about to ship (the "Version" field in
/// Xcode's target settings / App Store Connect, not the build number), and
/// register `highlights`' strings in Localizable.xcstrings like any other
/// data-driven string (see `Text(localizedContent:)`).
struct ReleaseNote {
    let version: String
    let highlights: [String]
}

enum ReleaseNotes {
    /// Oldest first — order doesn't affect behavior (`WhatsNewGate` sorts by
    /// version number), but keeps this list readable as a changelog.
    static let all: [ReleaseNote] = []
}

extension String {
    /// Numeric, dot-separated version compare (`"1.10"` > `"1.9"`), since a
    /// plain string compare would get that backwards. Missing components
    /// compare as 0, so `"1.2"` == `"1.2.0"`.
    func compareVersion(_ other: String) -> ComparisonResult {
        let lhs = split(separator: ".").map { Int($0) ?? 0 }
        let rhs = other.split(separator: ".").map { Int($0) ?? 0 }
        for i in 0..<max(lhs.count, rhs.count) {
            let l = i < lhs.count ? lhs[i] : 0
            let r = i < rhs.count ? rhs[i] : 0
            if l != r { return l < r ? .orderedAscending : .orderedDescending }
        }
        return .orderedSame
    }
}
