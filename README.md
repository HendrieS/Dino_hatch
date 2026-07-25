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
- **Duration picker**: `Views/Components/CircularDurationPicker.swift` sets
  any duration by dragging around the dial, or by tapping one of the
  5-minute numbers to jump straight to it (e.g. tapping "30" sets 30:00
  without starting the timer). Tap detection lives inside the same
  `updateFromDrag` handler as normal dragging (via `interactiveDiameter`
  growing the view's hit-testable area to cover the labels, and
  `nearestMinuteMark` checking proximity before falling back to the
  angle-based calculation) rather than a separate gesture on each label —
  an earlier version tried a competing `highPriorityGesture` per label,
  which turned out not to reliably win against the ring's own drag
  gesture at all.
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
- **Species-specific hatch art**: the illustrated 4-frame hatch sequence
  shares generic art for stages 1-2 (the egg hasn't visibly differentiated
  yet), but `Stores/EggHatchArt.swift` swaps stages 3-4 to body-plan-family
  art — pterosaur, sauropod, ceratopsid, raptor, armored, duckbill,
  sailback, theropod, domehead, or prosauropod — so the peeking silhouette
  actually resembles what's about to hatch instead of always looking like
  the same generic shape. All 30 catalog dinosaurs are mapped to a family
  now; the generic stage-3/4 frames stay as the fallback for whatever
  dinosaur is added next.
- **Cross-tab "egg ready" banner**: if the timer finishes while the kid is on
  the Alarm or Collection tab, `Views/TimerHomeView.swift` deliberately holds
  off playing the hatch animation (`advanceToHatching()`) until the Timer tab
  is actually on screen, instead of running it invisibly in the background.
  `Views/RootTabView.swift` polls the same `AppSettings.activeTimerEndDate`
  once a second (`isTimerReady`) and shows `Views/Components/TimerReadyBanner.swift`
  — a tap-to-jump banner — over whichever tab is active until the kid taps it
  or switches back manually, at which point the animation plays live.
- **Dino alarm**: `Views/AlarmView.swift` sets a repeating wake-up time
  (`Models/AlarmSettings.swift`). `Stores/AlarmScheduler.swift` schedules a
  local notification per selected weekday purely as an attention-getter —
  the actual reward doesn't depend on it firing or being tapped. Instead,
  `Stores/AlarmClaimer.swift` is a pure function checked every time the app
  becomes active (`RootTabView`'s `scenePhase` observer): if "now" is within
  `AlarmClaimer.responseWindow` (15 minutes) of today's alarm time on a
  selected day and nothing's been claimed yet today, it hatches a dinosaur
  via the same `HatchSelector` the timer uses. This means the reward works
  whether the kid taps the notification or just opens the app themselves,
  and whether or not notification permission was granted — the app can't
  run custom code at the exact moment a background notification fires
  anyway, so the design doesn't depend on it. Missing the 15-minute window
  means no dinosaur until the alarm's next scheduled occurrence — it's a
  deliberate "actually get up" incentive, not just a lenient catch-up
  reward. The header illustration on the Alarm tab reflects today's status
  (`AlarmView.headerImageName`): the plain `alarm-egg` art by default, the
  celebrating `alarm-reward` hatchling once `AlarmSettings.lastHatchDate`
  shows today's alarm was actually claimed in time, or the sad `alarm-sad`
  dino once `AlarmClaimer.wasMissedToday` says the window closed without a
  claim — alongside a short "Missed it today — try again tomorrow!" line.
  A missed window also puts a small "!" badge on the Alarm tab itself
  (`RootTabView.alarmWasMissedToday`, refreshed every minute and on every
  foreground transition via a `Timer.publish`), so it's noticeable without
  needing to open that tab. `AlarmSettings.streakCount` tracks consecutive
  *scheduled* claims via `Stores/AlarmStreak.swift` — not literal calendar
  days, so a weekdays-only alarm doesn't get its streak broken by a
  weekend it was never going to fire on. Shown as a "🔥 N day streak" line
  in the same spot the missed-window message would go.
- **Age onboarding & settings**: the first time the app is opened,
  `Views/AgeOnboardingView.swift` asks for the child's general age and
  gates the rest of the app (`Views/RootTabView.swift` shows it instead of
  the `TabView` whenever `AppSettings.childAge` is `nil`). A gear icon on
  the Collection tab opens `Views/ParentalGateView.swift` first — a quick
  random single-digit multiplication question (not real security, just
  enough friction to keep a small child out) that only then reveals
  `Views/SettingsView.swift`, where the age can be changed or all data
  (collection, timer, alarm, and the age itself) can be wiped, which
  re-triggers onboarding on next launch. Settings also links to
  `Views/HelpCenterView.swift`, a plain-language explainer for the adult —
  what's stored (just the age, unlock progress, and timer/alarm settings —
  no name, account, or contact info), that it's all local-only with no
  cloud sync/analytics/ads, and a short walkthrough of how the timer, dino
  alarm, and collection features work. It ends with a "Found a bug?"
  section — a `Link` to `mailto:Dinohatch@spijker.pro` (with a prefilled
  subject) that opens the device's Mail app.
- **X-ray age gating**: the press-and-hold x-ray view
  (`Views/DinoAnatomyView.swift`) only activates once
  `Stores/XRayEligibility.swift` — a pure, unit-tested function — says
  enough dinosaurs have been hatched, where "enough" depends on age:
  children 5 and under unlock it after their first hatch, everyone 6+
  needs at least 2. Below that, it silently falls back to the plain skin
  artwork with no hint x-ray exists, the same silent-gating pattern used
  for the secret dinosaurs.
- **Share a hatched dinosaur**: the detail screen's toolbar has a share
  button that renders `Views/Components/DinoShareCard.swift` (skin art,
  name, fun fact, a small "Dino Hatch" watermark) offscreen via
  `ImageRenderer`, writes it to a temp PNG, and presents it through
  `ShareLink` — works with Messages, Mail, Save Image, AirDrop, etc. with
  no custom plumbing. The card is a fixed white background regardless of
  the app's own theming, since it needs to look right once it's out of
  the app, not just inside it. It also carries a star-rank badge in the
  corner (`Dinosaur.rarity` — common/uncommon/rare/secret rare, already
  stored in `Data/DinosaurCatalog.swift` but unused elsewhere in the UI
  until now) for a trading-card feel. The four `isSecret` dinosaurs sit
  in their own `secretRare` tier (4 stars, purple) above the regular
  `rare` tier (3 stars, gold), so they stand apart once unlocked instead
  of blending into the rest of the rare pool.
- **Alternate app icons**: `Views/SettingsView.swift` has an "App Icon"
  section (`Components/AppIconPicker.swift`) offering the default icon
  plus one per `AppIconOption` (T. Rex, Triceratops, Pteranodon,
  Patagotitan) — each locked behind having hatched that specific
  dinosaur (`AppIconOption.isUnlocked`), shown dimmed with a lock badge
  rather than hidden, so it doubles as a small collection goal. Picking
  one calls `AppIconOption.apply`, a thin wrapper around
  `UIApplication.setAlternateIconName`. The four alternates are declared
  as ordinary single-size `.appiconset` entries in `Assets.xcassets` plus
  `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES` in `project.yml` — no
  manual `Info.plist` `CFBundleIcons` entries needed.
- **Found-in region maps**: `Views/DinosaurDetailView.swift` shows a
  "Found in" card whenever `Dinosaur.rangeMapAssetName`/`rangeLabel` are
  set — a shared world map (6 reusable region images, not one per
  dinosaur) with the relevant area highlighted, plus a short caption. All
  30 catalog entries are mapped to one of the 6 regions in
  `Data/DinosaurCatalog.swift`, grouped by real fossil-discovery
  geography (e.g. T-Rex/Triceratops → North America, Velociraptor/
  Oviraptor → Mongolia & China).
- **Estimated weight**: `Dinosaur.weight` is an optional measurement
  notation like `length` (e.g. "8,000 kg (17,600 lb)"), shown as its own
  fact row on the detail screen and, like `length`, displayed verbatim in
  every language rather than localized. All 30 catalog entries have one.
- **Light mode only**: the app is aimed at kids and isn't designed with a
  dark palette in mind, so dark mode is disabled at both levels —
  `UIUserInterfaceStyle: Light` in `project.yml` forces system chrome
  (status bar, system alerts) light, and `.preferredColorScheme(.light)`
  on the root view in `DinoHatchApp.swift` forces the SwiftUI hierarchy.
  `Views/HelpCenterView.swift` has a "Why no dark mode?" section explaining
  the reasoning to the adult (bright colors for young eyes, not
  encouraging bedtime screen use).
- **Notification permission**: `Stores/NotificationAuthorization.swift` is
  a small shared helper for requesting local-notification permission,
  used by both `AlarmScheduler` (the dino alarm) and
  `TimerNotificationScheduler` (the timer) — extracted once both needed
  the exact same request/completion logic.
- **Accessibility & iPad pass**: `Views/DinoAnatomyView.swift`'s
  press-and-hold x-ray gesture (a raw `DragGesture`) had no VoiceOver
  equivalent, since VoiceOver intercepts touches instead of passing
  through press-and-hold — it now exposes a single accessibility element
  with a label/value describing skin vs. skeleton and an
  `accessibilityAction` that toggles the same state a double-tap would
  trigger. `Components/WeekdayToggle.swift`'s on-screen glyph comes from
  `veryShortWeekdaySymbols` (ambiguous for VoiceOver — English has two
  "T"s and two "S"s), so its accessible name now uses the full
  `standaloneWeekdaySymbols` day name instead, plus `.isSelected` when a
  day is on. Several headline-style labels that were hardcoded
  `.font(.system(size:...))` (the dinosaur name on the detail and
  hatch-reveal screens, the parental-gate math question and answer field)
  now use scalable text styles (`.largeTitle`/`.title` + `.fontDesign(.rounded)`)
  so they grow with Dynamic Type instead of staying pinned at one size;
  purely decorative/graphical sizes (the countdown digits, the circular
  duration picker's dial numbers, the share card meant for export) were
  left fixed on purpose. On iPad, the single-column forms
  (`TimerSetupView`, `AlarmView`, `DinosaurDetailView`,
  `ParentalGateView`, `AgeOnboardingView`, `HatchRevealView`) now cap
  their content at 500pt wide and center it, instead of stretching
  buttons and text edge-to-edge on a big screen; `CollectionView`'s grid
  already used `GridItem(.adaptive(...))` so it reflows into more columns
  on iPad with no changes needed.

## Localization

The app supports English, German, Spanish, French, Dutch, and Russian via a
single String Catalog at `DinoHatch/Localizable.xcstrings`. Two patterns are
used, depending on where the text comes from:

- **Static UI text** (buttons, labels, hints) is written as ordinary string
  literals (`Text("Start Timer")`) — SwiftUI automatically looks these up in
  the catalog by treating the literal as the key.
- **Data-driven text** (dinosaur names/eras/fun facts, which come from
  `DinosaurCatalog.swift` at runtime rather than a call-site literal) uses
  the `Text(localizedContent:)` helper in `Extensions/Text+LocalizedContent.swift`,
  which explicitly looks the English catalog string up as a key. The
  `DinosaurCatalog.swift` content itself is unchanged — the English strings
  double as the translation keys, so no restructuring was needed there.
- `Dinosaur.length` (e.g. `"12 m (40 ft)"`) is intentionally shown as-is in
  every language via `Text(verbatim:)` — it's a measurement notation, not
  linguistic content.
- The app's own name ("Dino Hatch") and the "Dino-pedia" nickname are kept
  the same across languages, same as most apps don't translate their brand
  name.

**Adding another language**: open `Localizable.xcstrings` in Xcode (or edit
the JSON directly), add the new language code to every key's
`localizations`, and add it to the project's supported locales under
**Project → Info → Localizations**.

**Adding new dinosaurs/UI text**: add the English string to the Swift source
as usual, then add a matching entry (with all six languages) to
`Localizable.xcstrings` — anything missing silently falls back to the
English source string, so the app won't break if a translation is missing,
it'll just show English for that string.

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
- **Timer has no background modes**, but does schedule a one-shot local
  notification for when the egg finishes (`Stores/TimerNotificationScheduler.swift`,
  best-effort like the dino alarm's — permission denied just means no
  notification, everything else still works). If the app is killed
  mid-countdown it resumes correctly on relaunch (see above) regardless of
  whether the notification was tapped.
- **No parental gate, no multiple kid profiles, no accounts** — by design,
  kept as simple as possible for v1.
- **Dino alarm is a notification, not a real alarm**: iOS doesn't let
  third-party apps ring a continuous/escalating alarm like the built-in
  Clock app (that needs a special critical-alerts entitlement Apple
  reserves for health & safety apps) — it's a single notification sound a
  few seconds long. It's meant as a fun morning incentive layered on top of
  a real alarm clock, not a replacement for one.
- **Alarm reward has one known gap**: the reward triggers on every
  foreground transition (app launch, unlock-and-reopen, etc.), which
  covers the realistic "phone was locked overnight" case. It won't fire if
  the app happens to already be open and stays open through the exact
  alarm moment without ever backgrounding — a rare case, not handled for
  this alpha.
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
- [ ] Alarm tab: set a wake-up time ~2 minutes out, enable a weekday that
      matches today, accept the notification permission prompt
- [ ] Lock the phone before the alarm time, wait for the notification, then
      unlock — the notification shows, and reopening the app immediately
      presents the hatch animation/reveal for a new dinosaur
- [ ] Set another near-future alarm, this time deny notification permission
      (or leave the phone unlocked/app foregrounded) — confirm the hatch
      still triggers the next time you background and reforeground the app
      within 15 minutes of the alarm time
- [ ] Confirm only one dinosaur is awarded per day even if you foreground
      the app multiple times within the window
- [ ] Set an alarm, then wait more than 15 minutes before opening the app —
      confirm no dinosaur is awarded (window missed)
- [ ] `Cmd+U` unit tests pass
