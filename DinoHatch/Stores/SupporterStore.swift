import Foundation
import Observation
import StoreKit
import SwiftData

/// Wraps StoreKit 2 for the four non-consumable "supporter badge" products
/// (see `SupporterTier`). StoreKit itself is the source of truth for
/// ownership — `refreshOwnedTier()` rebuilds it from
/// `Transaction.currentEntitlements` rather than us keeping our own
/// purchase ledger — so a reinstall or a second device signed into the
/// same Apple ID recovers the badge via `restorePurchases()` without
/// depending on this app's iCloud sync at all. The result is cached into
/// `AppSettings.supporterTier` purely so the badge can render instantly
/// before that StoreKit round trip finishes.
@Observable
final class SupporterStore {
    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var purchaseErrorMessage: String?

    private var modelContext: ModelContext?
    private var transactionListener: Task<Void, Never>?

    func configure(context: ModelContext) {
        modelContext = context
    }

    /// Call once (e.g. `.task` on `SupportUsView`) — loads the product list,
    /// reconciles current ownership, and starts listening for transactions
    /// that complete outside this purchase flow (e.g. Ask to Buy approval).
    func start() async {
        transactionListener = transactionListener ?? listenForTransactionUpdates()
        await loadProducts()
        await refreshOwnedTier()
    }

    func stop() {
        transactionListener?.cancel()
        transactionListener = nil
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let loaded = try await Product.products(for: SupporterTier.allCases.map(\.productID))
            products = loaded.sorted { $0.price < $1.price }
        } catch {
            purchaseErrorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        purchaseErrorMessage = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    purchaseErrorMessage = "Purchase could not be verified."
                    return false
                }
                await transaction.finish()
                await refreshOwnedTier()
                return true
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            purchaseErrorMessage = error.localizedDescription
            return false
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await refreshOwnedTier()
    }

    private func refreshOwnedTier() async {
        var highest: SupporterTier?
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  let tier = SupporterTier(productID: transaction.productID) else { continue }
            if highest == nil || tier > highest! {
                highest = tier
            }
        }
        persist(highest)
    }

    private func persist(_ tier: SupporterTier?) {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<AppSettings>(sortBy: [SortDescriptor(\.createdAt)])
        let settings = (try? modelContext.fetch(descriptor).first) ?? {
            let created = AppSettings()
            modelContext.insert(created)
            return created
        }()
        settings.supporterTier = tier
    }

    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await transaction.finish()
                await self?.refreshOwnedTier()
            }
        }
    }
}
