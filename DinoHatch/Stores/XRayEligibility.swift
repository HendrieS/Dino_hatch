import Foundation

/// Gates the press & hold x-ray interaction (see `DinoAnatomyView`) behind
/// how many dinosaurs have been hatched so far, with the required count
/// depending on the child's age: younger children (5 and under) unlock it
/// after their very first hatch, everyone older needs at least two. Kept as
/// a pure, independently testable function rather than inlined in the view.
enum XRayEligibility {
    static let youngAgeThreshold = 5
    static let youngMinimumHatchCount = 1
    static let olderMinimumHatchCount = 2

    static func isUnlocked(childAge: Int?, totalHatched: Int) -> Bool {
        guard let childAge else { return false }
        let requiredHatchCount = childAge <= youngAgeThreshold ? youngMinimumHatchCount : olderMinimumHatchCount
        return totalHatched >= requiredHatchCount
    }
}
