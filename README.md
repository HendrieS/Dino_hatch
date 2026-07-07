# Dino Hatch

A kids' timer app: an adult sets a countdown, and when it finishes a dinosaur
egg on screen hatches, revealing a new dinosaur that's added to a persistent
collection ("Dino-pedia") the kid can explore for facts.

This is an **alpha build** — functional end-to-end, with placeholder emoji
art and a hand-rolled (no external library) hatch animation. See
[Known alpha limitations](#known-alpha-limitations) below.

## Requirements

- A Mac with Xcode 15+ (targets iOS 17+)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) — the `.xcodeproj` is not
  committed to the repo; it's generated from `project.yml`.
  ```
  brew install xcodegen
  ```

## Getting started

```
xcodegen generate
open DinoHatch.xcodeproj
```

Then in Xcode:

1. Select the `DinoHatch` target → **Signing & Capabilities** → set your
   Team. Xcode will offer to fix the bundle identifier / provisioning
   automatically — you can also change `PRODUCT_BUNDLE_IDENTIFIER` in
   `project.yml` (search for `com.dinohatch.app`), then re-run
   `xcodegen generate`.
2. Build and run (`Cmd+R`) on an iPhone or iPad simulator.
3. Run the unit tests with `Cmd+U`.

Persistence is **local-only for this alpha** (plain SwiftData, no iCloud) —
see [Re-enabling iCloud sync](#re-enabling-icloud-sync-optional) below if you
have a paid Apple Developer account and want cross-device sync.

## How it works

- **Timer**: `Stores/TimerEngine.swift` stores an absolute end date (not an
  elapsed-tick counter) in the `AppSettings` SwiftData model, so a running
  timer survives backgrounding *and* a full app kill/relaunch — on relaunch
  it just compares `Date.now` to the stored end date.
- **Dinosaur catalog**: `Data/DinosaurCatalog.swift` is a static, bundled
  list of 14 dinosaurs — no backend, no JSON parsing, just a Swift array.
- **Collection**: `Models/UnlockedDinosaur.swift` is the only thing that
  actually persists — a tiny record of which catalog IDs have been unlocked
  and when.
- **Hatch selection**: `Stores/HatchSelector.swift` randomly picks a
  not-yet-unlocked dinosaur; once the whole catalog is unlocked it replays a
  random existing one rather than dead-ending the reward loop.
- **Animation**: `Views/HatchAnimationView.swift` and `Views/EggView.swift`
  build the crack/wobble/burst/confetti sequence from plain SwiftUI shapes
  and animations — no image assets or third-party animation library.

## Re-enabling iCloud sync (optional)

Apple doesn't allow the iCloud capability on personal/free developer teams —
Xcode will show "Cannot create a iOS App Development provisioning profile...
Personal development teams... do not support the iCloud capability" if you
try. If you enroll in the paid Apple Developer Program ($99/year) and want
the collection to sync across a kid's devices:

1. In `project.yml`, add back an `entitlements` block under the `DinoHatch`
   target:
   ```yaml
   entitlements:
     path: DinoHatch/DinoHatch.entitlements
     properties:
       com.apple.developer.icloud-container-identifiers:
         - iCloud.com.dinohatch.app
       com.apple.developer.icloud-services:
         - CloudKit
   ```
2. In `DinoHatch/DinoHatchApp.swift`, change the `ModelConfiguration` call to
   pass `cloudKitDatabase: .automatic`.
3. Run `xcodegen generate`, select your paid Team under **Signing &
   Capabilities**, and sign into iCloud on the Simulator/device to test sync.

## Known alpha limitations

- **Placeholder art**: dinosaurs are represented with emoji (🦖🦕 etc.), not
  illustrations. `Dinosaur.imageAssetName` exists specifically so real
  artwork can be dropped into `Assets.xcassets` later without touching any
  view code — `DinoImageView` already prefers it when present.
- **Foreground-only timer**: no local notifications, no background modes.
  If the app is killed mid-countdown it resumes correctly on relaunch (see
  above), but there's no push when the egg hatches while the app is closed.
- **No parental gate, no multiple kid profiles, no accounts** — by design,
  kept as simple as possible for v1.
- **Animation is basic**: functional and self-contained, but tuned for
  "works, is charming enough for an alpha" rather than fully polished timing
  — expect to want to tweak spring/duration values once you see it running.

## Manual verification checklist

This project was authored without access to Xcode/Simulator, so please
verify on your Mac:

- [ ] `xcodegen generate` succeeds and the project opens without errors
- [ ] Builds and runs on iPhone + iPad simulators
- [ ] Full loop: start a short timer (e.g. 1 min) → egg hatches → dinosaur
      appears in the Collection tab → tap it to see facts
- [ ] Background the app mid-countdown, then foreground — countdown is
      still correct
- [ ] Force-quit the app mid-countdown, relaunch — timer resumes or
      immediately shows the hatch if time already elapsed
- [ ] `Cmd+U` unit tests pass
