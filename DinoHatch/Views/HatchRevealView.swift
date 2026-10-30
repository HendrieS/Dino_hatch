import SwiftUI
import SwiftData

struct HatchRevealView: View {
    let dinosaur: Dinosaur
    var onDismiss: () -> Void

    @Query private var unlockedRecords: [UnlockedDinosaur]
    /// Opens the same details screen Collection shows (facts, x-ray, map,
    /// favorite), added after tester feedback that a freshly hatched
    /// dinosaur could only be dismissed — not explored — from here. The
    /// dinosaur is already saved by the time this screen shows (both the
    /// timer and alarm flows unlock it as the hatch animation finishes), so
    /// favoriting works right away. Done returns here rather than finishing
    /// the reveal, so the flow still ends on Awesome!.
    @State private var showDetails = false

    // Drives the reveal's entrance pop and the success haptic that
    // accompanies it — false for one frame after appearing, then flipped
    // inside a spring animation, so the reward actually lands with a beat
    // instead of the whole card just being present on the first frame.
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("A dinosaur hatched!")
                .font(.title2.bold())
                .opacity(hasAppeared ? 1 : 0)

            DinoImageView(dinosaur: dinosaur, size: 180)
                .scaleEffect(hasAppeared ? 1 : 0.4)
                .opacity(hasAppeared ? 1 : 0)

            Text(localizedContent: dinosaur.name)
                .font(.largeTitle.bold())
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .opacity(hasAppeared ? 1 : 0)

            Text(localizedContent: dinosaur.funFact)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .foregroundStyle(.secondary)
                .opacity(hasAppeared ? 1 : 0)

            Spacer()

            Button {
                showDetails = true
            } label: {
                Label("See Details", systemImage: "book.fill")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.dinoGreenShadow)
                    .padding(.horizontal, 20)
                    .frame(minHeight: 44)
                    .background(.white.opacity(0.7), in: Capsule())
                    .overlay(Capsule().stroke(Color.dinoGreen, lineWidth: 2))
            }
            .buttonStyle(.plain)
            .opacity(hasAppeared ? 1 : 0)

            Button("Awesome!", action: onDismiss)
                .buttonStyle(.dinoChunkyGreen)
                // Wider than the fun-fact text's own 32pt inset — this sits
                // right at the bottom over the fern corners, so it needs
                // extra clearance to land between them instead of over them.
                // 32 -> 56 -> 80 -> 100 all still overlapped them, confirmed on
                // device each time.
                .padding(.horizontal, 140)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity)
        .dinoWarmBackground()
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                hasAppeared = true
            }
        }
        .sensoryFeedback(.success, trigger: hasAppeared) { _, newValue in newValue }
        .fullScreenCover(isPresented: $showDetails) {
            NavigationStack {
                DinosaurDetailView(
                    dinosaur: dinosaur,
                    unlockedAt: unlockedRecords.first(where: { $0.dinosaurID == dinosaur.id })?.unlockedAt
                )
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Done") {
                            showDetails = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HatchRevealView(dinosaur: DinosaurCatalog.all[0]) {}
        .modelContainer(for: UnlockedDinosaur.self, inMemory: true)
}
