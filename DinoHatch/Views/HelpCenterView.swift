import SwiftUI

/// A parent-facing overview of what the app stores and how it works,
/// reachable from `SettingsView` (behind the same parental gate). Written
/// for an adult, not the child — plain and specific, since data privacy is
/// the most likely reason someone would open it.
struct HelpCenterView: View {
    var body: some View {
        Form {
            Section {
                Label("Just their age", systemImage: "number")
                Label("Which dinosaurs they've hatched, and when", systemImage: "clock")
                Label("Timer and alarm settings", systemImage: "gearshape")
            } header: {
                Text("What we store about your child")
            } footer: {
                Text("No name, birthday, email, photos, or location are ever asked for or stored.")
            }

            Section("Where it's stored") {
                Text("Everything lives only on this device. There's no account, no cloud sync, no analytics, and no ads — the app doesn't need an internet connection to work, and nothing is ever sent anywhere.")
            }

            Section("How the timer works") {
                Text("Set a countdown. When it reaches zero, an egg on screen hatches and adds a new dinosaur to the collection.")
            }

            Section("How the dino alarm works") {
                Text("Set a repeating wake-up time. Opening the app within 15 minutes of it hatches a bonus dinosaur — a small incentive to actually get up, rather than a reward for opening the app whenever.")
            }

            Section("The collection") {
                Text("Tap any hatched dinosaur to read kid-friendly facts about it. Press and hold to see an X-ray view — this unlocks after the first hatch for children 5 and under, or after two hatches for children 6 and up.")
            }

            Section("Managing this data") {
                Text("You can change the age or erase everything (collection, timer, and alarm settings) from Settings at any time. A quick math question keeps small children from getting into Settings by accident.")
            }

            Section("Why no dark mode?") {
                Text("Dino Hatch always uses its light look, even if your device is set to dark mode. It's a daytime app for kids — bright colors are easier for young eyes to read, and a dark, glowing screen isn't something we want to encourage at bedtime.")
            }

            // The address itself isn't linguistic content, so it's shown
            // verbatim rather than routed through localization — same
            // reasoning as `Dinosaur.length`/`weight`.
            Section {
                if let url = URL(string: "mailto:Dinohatch@spijker.pro?subject=Dino%20Hatch%20Bug%20Report") {
                    Link(destination: url) {
                        Label {
                            Text(verbatim: "Dinohatch@spijker.pro")
                        } icon: {
                            Image(systemName: "envelope.fill")
                        }
                    }
                }
            } header: {
                Text("Found a bug?")
            } footer: {
                Text("Send us an email and we'll take a look.")
            }
        }
        .navigationTitle("Help Center")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HelpCenterView()
    }
}
