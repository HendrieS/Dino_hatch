import SwiftUI

/// Row of tappable Home Screen icon choices — the default plus one per
/// `AppIconOption`, each locked behind having hatched that dinosaur. Mirrors
/// `CollectionView`'s locked/unlocked treatment (dimmed + a lock badge)
/// rather than hiding locked choices outright, since seeing what's still to
/// unlock is part of the reward.
struct AppIconPicker: View {
    let unlockedIDs: Set<String>

    @State private var selected: AppIconOption?

    private let thumbnailSize: CGFloat = 56

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                defaultThumbnail
                ForEach(AppIconOption.allCases) { option in
                    thumbnail(for: option)
                }
            }
            .padding(.vertical, 4)
        }
        .onAppear { selected = AppIconOption.current }
    }

    private var defaultThumbnail: some View {
        Button {
            select(nil)
        } label: {
            Image("AppIcon")
                .resizable()
                .scaledToFit()
                .frame(width: thumbnailSize, height: thumbnailSize)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(selectionRing(isSelected: selected == nil))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Default icon"))
        .accessibilityAddTraits(selected == nil ? .isSelected : [])
    }

    private func thumbnail(for option: AppIconOption) -> some View {
        let isUnlocked = AppIconOption.isUnlocked(option, unlockedIDs: unlockedIDs)
        return Button {
            select(option)
        } label: {
            Image(option.assetName)
                .resizable()
                .scaledToFit()
                .frame(width: thumbnailSize, height: thumbnailSize)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(selectionRing(isSelected: selected == option))
                .overlay {
                    if !isUnlocked {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.black.opacity(0.55))
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.white)
                        }
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
        .accessibilityLabel(isUnlocked ? option.displayLabel : Text("Locked"))
        .accessibilityAddTraits(selected == option ? .isSelected : [])
    }

    private func selectionRing(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(isSelected ? Color.dinoGreen : .clear, lineWidth: 3)
    }

    private func select(_ option: AppIconOption?) {
        selected = option
        AppIconOption.apply(option)
    }
}

#Preview {
    AppIconPicker(unlockedIDs: ["t-rex", "triceratops"])
        .padding()
}
