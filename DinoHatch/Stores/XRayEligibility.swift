import Foundation

/// Gates the press & hold x-ray interaction (see `DinoAnatomyView`) behind
/// two conditions: the child's set age is old enough, and the collection
/// has grown past a small starting threshold. Kept as a pure, independently
/// testable function rather than inlined in the view.
enum XRayEligibility {
    static let minimumAge = 6
    static let minimumHatchCount = 2

    static func isUnlocked(childAge: Int?, totalHatched: Int) -> Bool {
        guard let childAge, childAge >= minimumAge else { return false }
        return totalHatched >= minimumHatchCount
    }
}
