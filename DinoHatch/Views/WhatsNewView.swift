import SwiftUI

/// Shown by `RootTabView` the first time the app opens after updating to a
/// version with something worth telling a returning parent about — see
/// `WhatsNewGate`/`ReleaseNotes`.
struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss
    let notes: [ReleaseNote]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                        .padding(28)
                        .background(Color.dinoGreen, in: Circle())
                        .padding(.top, 8)

                    Text("What's New")
                        .font(.title2.bold())

                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(notes, id: \.version) { note in
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(note.highlights, id: \.self) { highlight in
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: "pawprint.fill")
                                            .foregroundStyle(Color.dinoGreen)
                                            .font(.footnote)
                                            .padding(.top, 3)
                                        Text(localizedContent: highlight)
                                            .font(.body)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.dinoCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Button(action: { dismiss() }) {
                        Text("Got it!")
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.dinoGreen)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 12)
                }
                .padding()
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
            }
            .dinoWarmBackground()
        }
    }
}

#Preview {
    WhatsNewView(notes: [
        ReleaseNote(version: "1.1", highlights: [
            "New alarm streak counter to celebrate waking up on time.",
            "Fixed a bug where the timer dial could be set to 0:00.",
        ]),
    ])
}
