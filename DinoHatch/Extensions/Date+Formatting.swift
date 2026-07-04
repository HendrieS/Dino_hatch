import Foundation

extension TimeInterval {
    var minutesSecondsString: String {
        let totalSeconds = Int(rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
