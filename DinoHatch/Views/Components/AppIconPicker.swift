import SwiftUI

/// List of tappable Home Screen icon choices — the default plus one row per
/// `AppIconOption` — styled like a native list (icon, name, an unlock hint
/// or art credit as a subtitle, a checkmark on the selected row) rather
/// than a bare row of thumbnails, so the unlock condition is visible
/// without having to guess from a dimmed icon alone. Locked rows are shown
/// dimmed with a lock badge rather than hidden, since seeing what's still
/// to unlock is part of the reward — `AppIconOption.pickerTitle`/
/// `pickerSubtitle` are responsible for not naming a locked secret
/// dinosaur (Patagotitan) in that hint.
///
/// `body` is a bare `ForEach`/`Group` rather than a `List` of its own —
/// this view is meant to be placed directly inside the caller's `Form`
/// `Section` (see `SettingsView`), so each row gets that Section's native
/// row insets and separators instead of nesting a second scroll surface.
struct AppIconPicker: View {
    let unlockedIDs: Set<String>

    @State private var selected: AppIconOption?
    // Bumped only from `select(_:)` — a plain `trigger: selected` would also
    // fire the haptic from `onAppear`'s initial sync below, buzzing on
    // every visit to this screen instead of only on an actual tap.
    @State private var selectionFeedback = 0

    private let thumbnailSize: CGFloat = 52

    var body: some View {
        Group {
            defaultRow
            ForEach(AppIconOption.allCases) { option in
                row(for: option)
            }
        }
        .onAppear { selected = AppIconOption.current }
        .sensoryFeedback(.selection, trigger: selectionFeedback)
    }

    private var defaultRow: some View {
        Button {
            select(nil)
        } label: {
            HStack(spacing: 14) {
                Image("app-icon-thumb")
                    .resizable()
                    .scaledToFit()
                    .frame(width: thumbnailSize, height: thumbnailSize)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text("Default")
                    .foregroundStyle(.primary)

                Spacer()

                if selected == nil {
                    checkmark
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Default icon"))
        .accessibilityAddTraits(selected == nil ? .isSelected : [])
    }

    private func row(for option: AppIconOption) -> some View {
        let isUnlocked = AppIconOption.isUnlocked(option, unlockedIDs: unlockedIDs)
        return Button {
            select(option)
        } label: {
            HStack(spacing: 14) {
                thumbnail(for: option, isUnlocked: isUnlocked)

                VStack(alignment: .leading, spacing: 2) {
                    option.pickerTitle(isUnlocked: isUnlocked)
                        .foregroundStyle(.primary)
                    if let subtitle = option.pickerSubtitle(isUnlocked: isUnlocked) {
                        subtitle
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if isUnlocked {
                    if selected == option {
                        checkmark
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
        .accessibilityLabel(accessibilityLabel(for: option, isUnlocked: isUnlocked))
        .accessibilityAddTraits(selected == option ? .isSelected : [])
    }

    private func thumbnail(for option: AppIconOption, isUnlocked: Bool) -> some View {
        Image(option.thumbnailAssetName)
            .resizable()
            .scaledToFit()
            .frame(width: thumbnailSize, height: thumbnailSize)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                if !isUnlocked {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.black.opacity(0.55))
                }
            }
    }

    private var checkmark: some View {
        Image(systemName: "checkmark")
            .font(.body.bold())
            .foregroundStyle(Color.dinoGreen)
            .transition(.scale.combined(with: .opacity))
    }

    private func accessibilityLabel(for option: AppIconOption, isUnlocked: Bool) -> Text {
        let title = option.pickerTitle(isUnlocked: isUnlocked)
        guard let subtitle = option.pickerSubtitle(isUnlocked: isUnlocked) else { return title }
        return title + Text(verbatim: ". ") + subtitle
    }

    private func select(_ option: AppIconOption?) {
        guard selected != option else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            selected = option
        }
        selectionFeedback += 1
        AppIconOption.apply(option)
    }
}

#Preview {
    Form {
        Section("App Icon") {
            AppIconPicker(unlockedIDs: ["t-rex", "triceratops"])
        }
    }
}
