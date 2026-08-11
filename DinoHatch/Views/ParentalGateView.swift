import SwiftUI

/// A trivial "grown-ups only" math check shown before Settings, so a young
/// child tapping the gear icon can't casually reach Reset All Data. Not real
/// security — just enough friction that solving it reliably needs to be old
/// enough for single-digit multiplication. A wrong answer swaps in a fresh
/// question rather than just letting you retry the same one.
struct ParentalGateView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var factorA = Int.random(in: 3...9)
    @State private var factorB = Int.random(in: 3...9)
    @State private var answer = ""
    @State private var showWrongAnswer = false
    @State private var isUnlocked = false
    @FocusState private var isFocused: Bool

    var body: some View {
        if isUnlocked {
            SettingsView()
        } else {
            NavigationStack {
                VStack(spacing: 24) {
                    Spacer()

                    Text("Grown-ups only")
                        .font(.title2.bold())

                    Text("Solve this to open settings.")
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
            }
        }
    }

    private func check() {
        if Int(answer) == factorA * factorB {
            isUnlocked = true
        } else {
            newQuestion()
        }
    }

    private func newQuestion() {
        showWrongAnswer = true
        answer = ""
        factorA = Int.random(in: 3...9)
        factorB = Int.random(in: 3...9)
    }
}

#Preview {
    ParentalGateView()
}
