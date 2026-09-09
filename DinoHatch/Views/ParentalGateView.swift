import SwiftUI

/// A trivial "grown-ups only" math check shown before Settings, so a young
/// child tapping the gear icon can't casually reach Reset All Data. Not real
/// security — just enough friction that solving it reliably needs to be old
/// enough for single-digit multiplication. A wrong answer swaps in a fresh
/// question rather than just letting you retry the same one.
struct ParentalGateView: View {
    /// When provided, a correct answer calls this and dismisses the gate
    /// instead of swapping in `SettingsView` — for callers that just need a
    /// one-off "prove you're a grown-up" moment (e.g. the Timer Lock
    /// confirming a cancel) rather than the Settings flow itself. Leave nil
    /// for the original "gate on the way to Settings" behavior.
    var onUnlock: (() -> Void)?
    var prompt: LocalizedStringKey = "Solve this to open settings."

    @Environment(\.dismiss) private var dismiss

    @State private var factorA = Int.random(in: 3...9)
    @State private var factorB = Int.random(in: 3...9)
    @State private var answer = ""
    @State private var showWrongAnswer = false
    @State private var isUnlocked = false
    // Bumped on every wrong answer, purely to drive the shake below — its
    // actual value never matters, only that it changes.
    @State private var wrongAnswerCount = 0
    @FocusState private var isFocused: Bool

    var body: some View {
        if isUnlocked, onUnlock == nil {
            SettingsView()
        } else {
            NavigationStack {
                VStack(spacing: 24) {
                    Spacer()

                    Text("Grown-ups only")
                        .font(.title2.bold())

                    Text(prompt)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Text(factorA, format: .number)
                        Text(verbatim: "×")
                        Text(factorB, format: .number)
                        Text(verbatim: "=")
                    }
                    .font(.largeTitle.bold())
                    .fontDesign(.rounded)
                    .modifier(ShakeEffect(animatableData: CGFloat(wrongAnswerCount)))
                    .animation(.default, value: wrongAnswerCount)

                    TextField("Answer", text: $answer)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.title.weight(.semibold))
                        .fontDesign(.rounded)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(width: 160)
                        .padding(.vertical, 10)
                        .background(Color.dinoCardBackground, in: RoundedRectangle(cornerRadius: 14))
                        .focused($isFocused)
                        .onSubmit(check)
                        .onChange(of: answer) { _, newValue in
                            // Auto-checks once enough digits are typed to
                            // match the correct answer's length, so solving
                            // it doesn't require an explicit submit action
                            // (Enter or tapping Check) at all — matches
                            // partial input length only, not value, so
                            // typing the first digit of a two-digit answer
                            // doesn't prematurely fail it.
                            guard newValue.count == String(factorA * factorB).count else { return }
                            check()
                        }

                    Text("Try again")
                        .font(.footnote.bold())
                        .foregroundStyle(.red)
                        .opacity(showWrongAnswer ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: showWrongAnswer)

                    Button(action: check) {
                        Text("Check")
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.dinoGreen)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .padding(.horizontal, 32)
                    .disabled(answer.isEmpty)

                    Spacer()
                    Spacer()
                }
                .padding()
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
                .dinoWarmBackground()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
                .onAppear { isFocused = true }
                .sensoryFeedback(.error, trigger: wrongAnswerCount)
            }
        }
    }

    private func check() {
        guard Int(answer) == factorA * factorB else {
            newQuestion()
            return
        }
        if let onUnlock {
            onUnlock()
            dismiss()
        } else {
            isUnlocked = true
        }
    }

    private func newQuestion() {
        showWrongAnswer = true
        wrongAnswerCount += 1
        answer = ""
        factorA = Int.random(in: 3...9)
        factorB = Int.random(in: 3...9)
    }
}

/// A horizontal "no, try again" shake — `animatableData` is driven by a
/// plain incrementing counter rather than a Bool, so the effect can replay
/// identically on every wrong answer in a row, not just the first.
private struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let progress = animatableData.truncatingRemainder(dividingBy: 1)
        let offset = amount * sin(progress * .pi * shakesPerUnit) * (1 - progress)
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}

#Preview {
    ParentalGateView()
}
