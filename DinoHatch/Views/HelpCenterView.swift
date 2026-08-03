import SwiftUI

/// A parent-facing overview of what the app stores and how it works,
/// reachable from `SettingsView` (behind the same parental gate). Written
/// for an adult, not the child — plain and specific, since data privacy is
/// the most likely reason someone would open it. Ordered around the app's
/// three core principles (privacy-first, kid-safe, a little educational),
/// most-likely-reason-to-open first, rather than an arbitrary feature list.
struct HelpCenterView: View {
    var body: some View {
        Form {
            Section {
                Text("Dino Hatch is built to be private, safe, and a little bit educational. Here's exactly what that means.")
            }

            Section {
                Label("Just their age", systemImage: "number")
                Label("Which dinosaurs they've hatched, and when", systemImage: "clock")
                Label("Timer and alarm settings", systemImage: "gearshape")
                Text("Everything is stored on this device, and syncs privately through your iCloud account to your family's other devices — so the same collection, timer, and alarm show up whether your child uses an iPhone or an iPad. There's no separate account, no analytics, and no ads. This uses your own iCloud storage, not ours — nothing is ever sent to us.")
            } header: {
                Text("Privacy")
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("No name, birthday, email, photos, or location are ever asked for or stored.")
                    Text("To turn this off: open the Settings app on your device → tap your name at the top → iCloud → Saved to iCloud (tap See All if Dino Hatch isn't shown right away) → turn off Dino Hatch.")
                }
            }

            Section("Keeping it kid-safe") {
                Text("You can change the age or erase everything (collection, timer, and alarm settings) from Settings at any time. A quick math question keeps small children from getting into Settings by accident.")
                if FeatureFlags.supporterDonationsEnabled {
                    Text("The heart-shaped badge kids might tap on the main screens only ever shows a thank-you message. Buying support only happens from Settings, behind that same math check.")
                }
            }

            Section("How the timer works") {
                Text("Set a countdown. When it reaches zero, an egg on screen hatches and adds a new dinosaur to the collection.")
            }

            Section("How the dino alarm works") {
                Text("Set a repeating wake-up time. Opening the app within 15 minutes of it hatches a bonus dinosaur — a small incentive to actually get up, rather than a reward for opening the app whenever.")
            }

            Section("The collection") {
                Text("Tap any hatched dinosaur for kid-friendly facts — when it lived, what it ate, how big it really was, and where in the world it was found. Press and hold to see an X-ray view of its skeleton, which unlocks after the first hatch for children 5 and under, or after two hatches for children 6 and up.")
            }

            Section("Dinosaur rarity") {
                Text("Every dinosaur has a rarity — Common, Uncommon, Rare, or Secret Rare — shown as a colored border and star count on its card, like a trading card. This is just for fun and doesn't change the odds: every not-yet-hatched dinosaur has an equal chance of being the next one, regardless of rarity. Secret Rare is reserved for the collection's three hidden dinosaurs, which only become hatchable after every other dinosaur has been found.")
            }

            Section("App icons") {
                Text("Settings → App Icon lets you change the Home Screen icon. The default is always available. Four of the dinosaur icons unlock once you've hatched that specific dinosaur — Tyrannosaurus Rex, Triceratops, and Pteranodon are regular hatches, while the fourth, Patagotitan, is one of the collection's secret dinosaurs, so it only unlocks after every other dinosaur has been hatched first. The other two work differently: the brown dino icon unlocks once you've hatched 5 dinosaurs in total, and the green dino icon once you've hatched 10.")
            }

            Section("Why no dark mode?") {
                Text("Dino Hatch always uses its light look, even if your device is set to dark mode. It's a daytime app for kids — bright colors are easier for young eyes to read, and a dark, glowing screen isn't something we want to encourage at bedtime.")
            }

            if FeatureFlags.supporterDonationsEnabled {
                Section("Supporting Dino Hatch") {
                    Text("Settings → Support Dino Hatch offers an optional one-time purchase, in four tiers, for families who'd like to support development. It never unlocks anything in the game — it only adds a small heart-shaped badge (colored gray, green, gold, or purple depending on the tier) shown in the corner of the main screens and Home Screen widgets. Dino Hatch stays completely free either way.")
                }
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
