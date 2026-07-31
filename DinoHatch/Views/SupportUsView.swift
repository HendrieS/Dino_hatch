import SwiftUI
import StoreKit
import SwiftData

/// Optional one-time support purchases — Dino Hatch stays free either way,
/// this only ever unlocks a small thank-you badge (see
/// `SupporterBadgeView`), never gameplay content. Reached from
/// `SettingsView`, already behind the parental-gate math check, so no
/// separate adults-only gate is needed here.
struct SupportUsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]

    @State private var store = SupporterStore()
    @State private var showThankYou = false

    private var ownedTier: SupporterTier? {
        settings.first?.supporterTier
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Dino Hatch is free and always will be. If your family enjoys it, you can leave a little support here — it only ever unlocks a small thank-you badge, never anything in the game itself.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    if store.isLoading && store.products.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(SupporterTier.allCases, id: \.self) { tier in
                            if let product = store.products.first(where: { $0.id == tier.productID }) {
                                tierRow(tier: tier, product: product)
                            }
                        }
                    }
                } header: {
                    Text("Support Dino Hatch")
                } footer: {
                    if let message = store.purchaseErrorMessage {
                        Text(message)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button("Restore Purchases") {
                        Task { await store.restorePurchases() }
                    }
                }
            }
            .navigationTitle("Support Us")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                store.configure(context: modelContext)
                await store.start()
            }
            .alert("Thank you!", isPresented: $showThankYou) {
                Button("You're welcome", role: .cancel) {}
            } message: {
                Text("Your support means a lot — enjoy your new badge!")
            }
        }
    }

    private func tierRow(tier: SupporterTier, product: Product) -> some View {
        HStack {
            Circle()
                .fill(tier.tint)
                .frame(width: 14, height: 14)

            VStack(alignment: .leading, spacing: 2) {
                tier.localizedLabel
                    .font(.body.bold())
                Text(product.displayPrice)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if ownedTier == tier {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.dinoGreen)
                    .font(.title3)
            } else {
                Button("Support") {
                    Task {
                        if await store.purchase(product) {
                            showThankYou = true
                        }
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

#Preview {
    SupportUsView()
        .modelContainer(for: [AppSettings.self], inMemory: true)
}
