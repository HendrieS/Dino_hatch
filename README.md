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
- A paid Apple Developer Program membership ($99/year). The project has
  iCloud/CloudKit sync enabled by default (see
  [iCloud sync](#icloud-sync) below) — personal/free teams can't provision
  the iCloud capability at all, so the build won't sign without one. If you
  don't have one, see that section for the two-line revert to local-only.

## Getting started

```
xcodegen generate
open DinoHatch.xcodeproj
```

Then in Xcode:

1. Select the `DinoHatch` target → **Signing & Capabilities** → set your
   (paid) Team, then repeat for the `DinoHatchWidget` target. Xcode will
   offer to fix the bundle identifiers / provisioning automatically — you
   can also change `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml` (search for
   `com.dinohatchtimer.app`), then re-run `xcodegen generate`. Both targets share
   the `group.com.dinohatchtimer.app` App Group (see
   [Home Screen widget](#home-screen-widget) below) — it backs the app's
   actual SwiftData store, not just widget data, so the app won't launch at
   all without it — and the `iCloud.com.dinohatchtimer.app` container (see
   [iCloud sync](#icloud-sync) below). With automatic signing both should
   provision themselves; if Xcode complains, add the **App Groups** and
   **iCloud** (with **CloudKit** checked) capabilities manually on each
   target and confirm the same group/container are checked on both.
2. Build and run (`Cmd+R`) on an iPhone or iPad simulator. Sign into iCloud
   on the simulator/device (Settings → sign in) to actually exercise sync —
   the app works fine without it, it just stays local-only on that device.
3. Run the unit tests with `Cmd+U`.
4. To see the widget, long-press the Home Screen → **Edit Home Screen** →
   **+** → search "Dino Hatch" → add it.

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
  and animations — no image assets or third-party animation library. The
  hand-off into `Views/HatchRevealView.swift` is no longer an instant cut:
  `Views/TimerHomeView.swift` and `Views/AlarmHatchView.swift` both wrap
  their `.hatching` -> `.reveal` state change in `withAnimation` and give
  the two views a `.transition(.opacity)`, and `HatchRevealView` itself
  pops its contents in with a spring (`hasAppeared`) plus a `.success`
  `sensoryFeedback` haptic, so the reward actually lands with a beat
  instead of the whole card just appearing on the first frame.
  `Views/CollectionCompleteView.swift` (the bigger, whole-catalog
  celebration) got the same `hasAppeared` pop-plus-haptic treatment so it
  doesn't land with less flourish than the per-dinosaur reveal. A few
  smaller motion/haptic touches followed the same pass: the favorite heart
  on `Views/DinosaurDetailView.swift` morphs and bounces
  (`.contentTransition(.symbolEffect(.replace))` + `.symbolEffect(.bounce)`)
  with a `.selection` haptic instead of just swapping SF Symbols;
  `Views/AlarmView.swift`'s wake-time picker and weekday row now fade in/out
  with the alarm toggle instead of snapping; and
  `Views/ParentalGateView.swift` shakes the equation
  (a small custom `ShakeEffect: GeometryEffect`) and plays an `.error`
  haptic on a wrong answer. `Views/Components/AppIconPicker.swift`'s
  checkmark now transitions/springs between rows instead of jumping, and
  `Views/Components/WeekdayToggle.swift` animates its own color swap. Both
  of those, plus the weekday row, route their `.selection` haptic through a
  private tap counter rather than tying it directly to the selected/on
  value — tying it directly to the value would also fire the haptic the
  instant the screen loads already-saved state (icon choice, enabled
  weekdays) rather than only on an actual tap.
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
  needing to open that tab. `AlarmSettings.enabledAt` is stamped whenever
  the alarm toggles from off to on, so turning it on after today's window
  has already closed doesn't show the sad "missed it" state — there was
  never a real chance to catch it. `AlarmClaimer.isPendingFirstChance`
  detects that case and `AlarmView` shows an encouraging "Get ready to wake
  up on time tomorrow!" line (plain egg art, no "!" badge) instead.
  `AlarmSettings.streakCount` tracks consecutive
  *scheduled* claims via `Stores/AlarmStreak.swift` — not literal calendar
  days, so a weekdays-only alarm doesn't get its streak broken by a
  weekend it was never going to fire on. Shown as a "🔥 N day streak" line
  in the same spot the missed-window message would go.
- **Age onboarding & settings**: the first time the app is opened,
  `Views/AgeOnboardingView.swift` asks for the child's general age and
  gates the rest of the app (`Views/RootTabView.swift` shows it instead of
  the `TabView` whenever `AppSettings.childAge` is `nil`). Its header image
  is `alarm-egg` (the same hatching-egg-with-baby-dino illustration
  `AlarmView`'s default state uses) rather than a plain emoji. A gear icon on
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
  until now) for a trading-card feel. The `isSecret` dinosaurs sit
  in their own `secretRare` tier (4 stars, purple) above the regular
  `rare` tier (3 stars, gold), so they stand apart once unlocked instead
  of blending into the rest of the rare pool.
- **Alternate app icons**: `Views/SettingsView.swift` has an "App Icon"
  section (`Components/AppIconPicker.swift`) — a native-styled list (icon,
  name, and an unlock hint or art credit as a subtitle, a checkmark on the
  selected row) rather than a bare row of thumbnails, so the unlock
  condition is visible up front. Offers the default icon plus one per
  `AppIconOption` (T. Rex, Triceratops, Pteranodon, Patagotitan, plus two
  illustrated by Alexis: a brown dino and a green dino), each gated behind
  an `AppIconOption.UnlockRequirement` (`AppIconOption.isUnlocked`) — shown
  dimmed with a lock badge rather than hidden, so it doubles as a small
  collection goal. Four use `.hatch(dinosaurID:)` (locked behind hatching
  that specific dinosaur); the brown and green dino icons instead use
  `.collectionSize(_:)` — unlocked once 5 and 10 dinosaurs (any species)
  have been hatched in total, rather than one particular one.
  `AppIconOption.pickerTitle`/`pickerSubtitle` supply the row text, and
  deliberately don't name Patagotitan (a secret dinosaur) in its locked
  hint — same "no UI hints it exists" rule the Collection grid follows,
  showing "???" until it's actually unlocked. Picking an icon calls
  `AppIconOption.apply`, a thin wrapper around
  `UIApplication.setAlternateIconName`. The alternates are declared as
  ordinary single-size `.appiconset` entries in `Assets.xcassets` plus
  `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES` in `project.yml` — no
  manual `Info.plist` `CFBundleIcons` entries needed. `.appiconset`-typed
  entries aren't reliably loadable through `Image(_:)` for an in-app
  preview, so each one has a plain duplicate `*-thumb` `.imageset` (same
  artwork, ordinary content type) that `AppIconPicker` reads from instead
  — `AppIconOption.thumbnailAssetName` points at those.
- **Collection search/filter/sort**: `Views/CollectionView.swift` adds a
  `.searchable` field (matched against `Dinosaur.localizedName`, a new
  `String`-returning counterpart to `Text(localizedContent:)` for
  contexts a `Text` view won't work in) plus a toolbar filter/sort menu
  (diet, rarity, and sort by collection order/name/rarity — reusing the
  existing `Diet`/`Rarity` enums and labels rather than inventing new
  ones). All three operate on the full catalog, including locked
  entries — species names were never secret, only their art/facts are
  (via `DinoSilhouetteView`), so a locked match still renders as a plain
  silhouette rather than revealing anything. An empty result shows a
  `ContentUnavailableView` rather than a blank grid.
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
- **Home Screen widget**: see [Home Screen widget](#home-screen-widget)
  below.

## Home Screen widget

`DinoHatchWidget` is a WidgetKit extension with three widgets in one
`DinoHatchWidgetBundle`: a Dino Collection widget (below), a Quick Timer
widget, and a Dino Alarm widget (both further down this section).

The Dino Collection widget (small/medium) shows collection progress
("X / Y discovered") and, at medium size, the most recently hatched
dinosaur's emoji and name. It's read-only and static — no live countdown —
so it uses a single-entry `TimelineProvider` with `policy: .never` rather
than polling on a schedule.

Since the widget runs in its own process, it can't query the main app's
SwiftData store directly. Instead:

- `DinoHatchShared/WidgetSnapshot.swift` (compiled into both targets) defines
  a small `Codable` struct plus a `UserDefaults(suiteName:)` read/write pair,
  using the `group.com.dinohatchtimer.app` App Group.
- `Stores/WidgetSnapshotBuilder.swift` (main app only, unit-tested) turns the
  unlocked collection into a `WidgetSnapshot` — resolving the most recent
  dinosaur's localized name, emoji, and `imageAssetName` *in the app*, so
  the widget target doesn't need `DinosaurCatalog` or (beyond its own
  couple of UI strings) the localization catalog. It does share the real
  artwork itself — see [Custom art in the widgets](#custom-art-in-the-widgets)
  below.
- `RootTabView` calls `WidgetSnapshotBuilder`/`WidgetSnapshotStore.save` and
  `WidgetCenter.shared.reloadTimelines` on every launch/foreground and
  whenever the unlocked count changes, covering both the timer's and the
  alarm's unlock paths without the widget needing to know which one fired.

The App Group is declared identically on both targets' entitlements in
`project.yml`; with automatic signing this provisions itself, but see step 1
in [Getting started](#getting-started) if Xcode asks for it manually.

### Quick Timer widget

A second, medium-only widget (`DinoHatchQuickTimerWidget`, added to the same
`DinoHatchWidgetBundle`) has three states:

- **No timer running**: four duration buttons — 5/10/15/30 minutes. Each is
  an `AppIntent`-backed `Button` (`StartTimerIntent`, interactive widgets,
  iOS 17+) rather than a `Link` — tapping one starts the timer **without
  opening the app**, running entirely in the widget extension's process.
- **Timer running**: the buttons are replaced by a live countdown —
  `Text(endDate, style: .timer)`, the same system-rendered date style the
  Alarm widget and `CountdownView` use — plus the hatching dinosaur's emoji.
  This region has no `Link`/`Button` of its own, so it falls back to
  WidgetKit's default behavior: tapping it opens the app.
- **Timer finished, not yet opened**: an "egg is ready to hatch!" state
  instead of a countdown ticking past zero, also tappable to open the app.

Making the buttons a true background action (rather than the deep link an
earlier version of this feature used) meant `StartTimerIntent` needs to do
everything `TimerEngine.start()` normally does — pick a dinosaur, write
`AppSettings`, schedule the hatch notification — from a process that never
launches the app. That's only possible if the widget extension can open the
*exact same* SwiftData store the app uses, which took a bigger change than
the button itself:

- The app's `ModelContainer` now lives inside the `group.com.dinohatchtimer.app`
  App Group container (`DinoHatchShared/SharedModelContainer.swift`) instead
  of its own default location, so both processes can open the same file.
  **This resets any local data from before this change** — the store moved,
  it didn't migrate.
- `AppSettings`, `UnlockedDinosaur`, `AlarmSettings`, `Dinosaur`,
  `DinosaurCatalog`, `HatchSelector`, `TimerNotificationScheduler`, and
  `NotificationAuthorization` all moved from `DinoHatch/` into
  `DinoHatchShared/`, so the widget target can construct an identical
  `Schema` (SwiftData rejects a store as incompatible if the schema doesn't
  include every entity it was created with, even ones a given process never
  touches) and pick/schedule a dinosaur the same way the app does.
- `StartTimerIntent` writes `AppSettings` through the shared container,
  updates `WidgetSnapshot` directly (so the countdown appears immediately,
  without waiting for the app to run `refreshWidgetSnapshot()`), and calls
  `WidgetCenter.reloadTimelines` itself.
- `TimerHomeView` now also re-syncs from `AppSettings` on every foreground
  (not just first appearance), guarded to only do so while still on the
  setup screen — a timer can now start while the app was merely
  backgrounded rather than relaunched, so it needs to notice the change
  itself rather than relying on `.onAppear` firing again.

If a future Xcode build reports the widget's cross-process `AppSettings`
write isn't showing up promptly when resuming the app from the background
(as opposed to a fresh launch), that's the one part of this that couldn't be
verified without a real device/simulator — worth an explicit test after
building.

### Alarm widget

A third, small-only widget (`DinoHatchAlarmWidget`) shows a live countdown to
the next dino alarm once one's set — `Text(fireDate, style: .timer)`, the
same system-rendered date style `CountdownView` already uses for the running
timer, so it ticks down on its own with no per-second app/widget work. With
no alarm enabled it just shows "No alarm set".

`Stores/AlarmNextFireDate.swift` (pure, unit-tested) is the mirror image of
`AlarmStreak.previousScheduledDay` — given an hour/minute/weekdays and now,
it walks forward up to 7 days to find the next matching occurrence.
`WidgetSnapshotBuilder` calls it when building the snapshot, and
`RootTabView` keeps that snapshot's `nextAlarmFireDate` fresh by reloading
on: any alarm settings change (`alarmFingerprint`, a cheap string stand-in
for `.onChange` since `AlarmSettings` is a SwiftData reference type and
in-place property edits don't reliably trigger `.onChange(of:)` on the
array itself), and every foreground (covers the fire date having simply
passed, with no settings change to key off of).

### Lock Screen / Dynamic Island Live Activity

While a timer's running, `DinoTimerLiveActivity.swift` shows it on the Lock
Screen and, on supported devices, in the Dynamic Island — a live countdown
(`Text(endDate, style: .timer)`, same technique as everywhere else) plus the
hatching dinosaur's emoji. Tapping it anywhere opens the app, the default
behavior for a Live Activity with no `Link` of its own.

- `DinoHatchShared/DinoTimerActivityAttributes.swift` defines the
  `ActivityAttributes`/`ContentState` (just `endDate` and an optional
  emoji) — compiled into both targets since either side can start one.
- `DinoHatchShared/DinoTimerActivityController.swift` wraps
  `Activity<DinoTimerActivityAttributes>.request`/`.end` — best-effort,
  same philosophy as `NotificationAuthorization` (a timer works identically
  whether or not the activity could start; Live Activities can be turned
  off system-wide in Settings).
- `TimerEngine.start()`/`cancel()` (in-app path) and `StartTimerIntent.
  perform()` (Quick Timer widget path — see below) both call it, so a Live
  Activity shows up regardless of where the timer was started.
- `NSSupportsLiveActivities` is set on the `DinoHatch` target in
  `project.yml` — required for Live Activities to work at all.

Once the countdown reaches zero the Live Activity keeps showing (ticking
past zero, same accepted limitation as the Quick Timer widget's countdown)
until the app is actually opened and the hatch plays through —
`TimerEngine.cancel()`/`completeHatch()` is what ends it.

### Custom art in the widgets

The Collection widget, Quick Timer widget, Alarm widget, and Live Activity
all originally used plain emoji (🥚, 🦖, ⏰) as placeholders. They now use
the app's real illustrated art instead:

- `DinoHatch/Assets.xcassets` is shared into the `DinoHatchWidget` target
  via `project.yml` (the same pattern already used for
  `Localizable.xcstrings`), so the widget/Live Activity can render the same
  skin illustrations the app itself uses — every dinosaur already has one,
  so no new art was needed for this. Sharing the whole catalog (rather than
  a curated subset) also means any art added to it later is automatically
  available in the widgets too, with no extra wiring.
- `WidgetSnapshot` carries `lastDinosaurImageAssetName` alongside the
  existing `lastDinosaurEmoji` — the emoji field stays as a fallback, not
  dead weight — `DinoWidgetImage.swift` (widget target only) renders the
  real image when the asset name resolves to a bundled one and falls back
  to the emoji otherwise, the same graceful-degradation shape as
  `DinoImageView` in the main app.
- The generic (non-dinosaur-specific) icons use existing art rather than
  new uploads: the Collection and Quick Timer widgets' header icon is
  `egg-hatch-1` (the plain speckled egg, stage 1 of the hatch animation);
  the Alarm widget's header icon is `alarm-egg` (the same illustration
  `AlarmView`'s default state already uses).
- The Live Activity uses real art only where it's large enough to actually
  read — the Lock Screen banner and the Dynamic Island's *expanded*
  leading region. The compact/minimal Dynamic Island regions (rendered in
  the status bar at ~16-20pt) stay plain emoji on purpose, since a
  scaled-down illustration would blur there while the system's own emoji
  rendering stays crisp at any size.
- **Neither the Live Activity nor the Quick Timer widget ever show the
  hatching dinosaur's identity while a timer is running or ready** — both
  always render the generic `egg-hatch-1`/🥚 regardless of which dinosaur
  `HatchSelector` already picked when the timer started. `WidgetSnapshot`
  and `DinoTimerActivityAttributes.ContentState` deliberately have no
  "active timer's dinosaur" fields at all, only `lastDinosaur*` (which
  reflects a dinosaur that's already been unlocked and revealed in-app).
  This was a real spoiler bug early on: the species was baked into the
  Live Activity/widget the moment the timer started, visible on the Lock
  Screen or Home Screen for the entire countdown, well before the in-app
  hatch animation played. There's also no reliable way to reveal it
  exactly when the countdown hits zero while the app is backgrounded (no
  push/server infra here), so rather than sometimes reveal early depending
  on timing, it just never reveals outside the app at all.

## Supporting the app

Dino Hatch is free with no ads, no tracking, and nothing paywalled — but a
parent can optionally leave a small one-time tip from **Settings → Support
Dino Hatch** (behind the same `ParentalGateView` math check that already
guards Settings). It only ever unlocks a small heart-shaped badge shown in
the corner of the main screens (`Views/Components/SupporterBadgeView.swift`)
— never gameplay content.

- **Apple In-App Purchase only, non-consumable.** Four separate
  non-consumable products (`SupporterTier`: `gray`/`green`/`gold`/`purple`,
  IDs `com.dinohatchtimer.app.support.{tier}`), one per badge color.
  Non-consumable rather than consumable because a badge is a permanent
  unlock, not something spent — this also means StoreKit itself tracks
  ownership and `Restore Purchases`, so there's no custom purchase ledger to
  get wrong. A parent can "upgrade" later by buying a higher tier's product;
  `SupportUsView` always shows whichever owned tier ranks highest.
- **The badge is never a path to StoreKit.** `SupporterBadgeView` is
  reachable from the Timer/Alarm/Collection tabs, which a child can tap
  unsupervised, so tapping it opens `SupporterThankYouView` — a pure
  thank-you message with no purchase UI at all — rather than
  `SupportUsView`. The only way to reach the actual purchase flow is
  Settings → Support Dino Hatch, behind `ParentalGateView`'s math check.
- **`Stores/SupporterStore.swift`** wraps StoreKit 2: loads the four
  `Product`s, handles `purchase(_:)`, and rebuilds the owned tier from
  `Transaction.currentEntitlements` (both on launch and whenever
  `Transaction.updates` reports something completed outside the purchase
  flow, e.g. Ask to Buy approval) rather than keeping its own ledger. The
  result is cached into `AppSettings.supporterTier` — already synced via
  [iCloud sync](#icloud-sync) — purely so the badge renders instantly
  instead of waiting on a StoreKit round trip; StoreKit's own entitlements
  (tied to the Apple ID, not iCloud) remain the actual source of truth, so
  the badge recovers via **Restore Purchases** even with iCloud sync off.
- **Also shown on the Home Screen widgets and the Lock Screen Live
  Activity** (`DinoHatchWidget/WidgetSupporterBadge.swift`) — a
  non-interactive version of the same badge, since widgets/Live Activities
  can't present a sheet. The Collection/Alarm/Quick Timer widgets get it via
  `WidgetSnapshot.supporterTierRawValue` (written by
  `RootTabView.refreshWidgetSnapshot()`, same path as everything else those
  widgets display); the Live Activity gets it via
  `DinoTimerActivityAttributes.ContentState.supporterTierRawValue`, captured
  once when the timer starts (same as `dinosaurEmoji`/
  `dinosaurImageAssetName` — it doesn't update mid-countdown if a purchase
  happens while a timer's already running). **Deliberately not shown in the
  Dynamic Island** — its compact/minimal regions are too small (~16-20pt)
  for another visual element without compromising the existing "stay plain
  emoji" design there (see [Custom art in the
  widgets](#custom-art-in-the-widgets)).
- `SupporterTier`'s colors intentionally match `Dinosaur.Rarity.tint`'s
  palette (gray/green/gold/purple) but are a separate enum — donor status
  isn't dinosaur game data, kept decoupled even though today's palette is
  shared.
- **Badge placement**: `.topBarLeading` toolbar item on `AlarmView`/
  `CollectionView` (each already has its own `NavigationStack`). The Timer
  tab has no nav bar of its own, so there it's a plain `.overlay(alignment:
  .topLeading)` corner badge on `TimerHomeView` instead — noted in-code as a
  spot that may need a position tweak once seen on a real device.
- **Local testing**: `Products.storekit` (repo root) is a StoreKit
  Configuration file with all four products, wired into the `DinoHatch`
  scheme's run options via `project.yml`'s `storeKitConfiguration` key — so
  the whole purchase flow (including simulated purchase sheets) works in
  Simulator with zero App Store Connect setup. If a given XcodeGen version
  doesn't support that key, set it manually once in Xcode: **Product → Scheme
  → Edit Scheme → Run → Options → StoreKit Configuration**.
- **Manual App Store Connect steps before shipping** (can't be scripted):
  sign Apple's Paid Applications Agreement (required for any IAP, even
  giving away a free app), then create the four products there with real
  pricing/localized display names, matching the product IDs above exactly.

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

## iCloud sync

The collection, timer, and alarm settings sync across a kid's devices via
CloudKit — `DinoHatchShared/SharedModelContainer.swift` passes
`cloudKitDatabase: .automatic` to the shared `ModelConfiguration`, and both
the `DinoHatch` and `DinoHatchWidget` targets carry identical
`com.apple.developer.icloud-container-identifiers`/`-services` entitlements
(alongside the `com.apple.security.application-groups` entitlement they
already needed — see [Home Screen widget](#home-screen-widget) — both
targets need matching entitlements since the widget's `StartTimerIntent`
opens the same CloudKit-mirrored store directly). `DinoHatch`'s
`Info.plist` also declares `UIBackgroundModes: remote-notification` — a
plain Info.plist entry, no extra entitlement or portal registration
needed — since CloudKit relies on silent push notifications to know when
to fetch remote changes promptly; without it, SwiftData throws "BUG IN
CLIENT OF CLOUDKIT: CloudKit push notifications require the
'remote-notification' background mode" at runtime.

This requires a paid Apple Developer Program membership — Apple doesn't
allow the iCloud capability on personal/free teams at all (Xcode shows
"Cannot create an iOS App Development provisioning profile... Personal
development teams... do not support the iCloud capability" and refuses to
sign). It degrades gracefully at *runtime* with no code changes if iCloud
just isn't available on a given device (not signed in, sync disabled in
Settings) — the app stays local-only on that device rather than failing.
The *build-time* provisioning requirement is the hard blocker, not runtime
availability.

The SwiftData models (`AppSettings`, `UnlockedDinosaur`, `AlarmSettings`)
were written CloudKit-compatible from the start — no `@Attribute(.unique)`
constraints, every stored property either optional or defaulted, no
relationships between them — so no model changes were needed to turn this
on.

**If you're on a personal/free team** and want to build this without a paid
membership, revert to local-only:

1. Remove the `com.apple.developer.icloud-container-identifiers`/
   `com.apple.developer.icloud-services` entries from both targets'
   `entitlements` blocks in `project.yml` (and re-run `xcodegen generate`).
2. In `DinoHatchShared/SharedModelContainer.swift`, drop the
   `cloudKitDatabase: .automatic` argument (or set it to `.none`).

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

## Before you release

Steps that only make sense once, right before shipping to the App Store —
not needed for day-to-day development:

- [ ] For TestFlight phase 1, `Stores/FeatureFlags.swift` has
      `supporterDonationsEnabled = false` — the purchase flow's entry points
      (Settings → Support Dino Hatch, the Help Center section) are hidden so
      phase 1 doesn't need the Paid Applications Agreement or the IAP
      products set up first. `SupportUsView`/`SupporterStore` and the badge
      display are untouched, so re-enabling for phase 2 is flipping that one
      flag back to `true`. Once it's back on:
  - [ ] Sign Apple's Paid Applications Agreement in App Store Connect
        (required for any In-App Purchase, even though Dino Hatch itself
        stays free) — see [Supporting the app](#supporting-the-app)
  - [ ] Create the four supporter IAP products in App Store Connect with real
        pricing and localized display names, matching
        `com.dinohatchtimer.app.support.{gray,green,gold,purple}` exactly
  - [ ] Test a real (sandbox) purchase and Restore Purchases on a physical
        device via TestFlight, not just the local `Products.storekit`
        Simulator config
