import StoreKit

@Observable
@MainActor
final class SubscriptionService {
    static let shared = SubscriptionService()

    private let productID = "app.rork.lifenode.premium.annual"
    private let freeNodeLimit = 1000
    private let freeReelLimit = 3

    var isPremium: Bool = false
    var product: Product?
    var purchaseError: String?
    var isLoading: Bool = false

    private nonisolated(unsafe) var updateTask: Task<Void, Never>?

    init() {
        updateTask = Task { [weak self] in
            await self?.listenForTransactions()
        }
        Task {
            await loadProduct()
            await checkEntitlement()
        }
    }

    deinit {
        updateTask?.cancel()
    }

    var formattedPrice: String {
        product?.displayPrice ?? "$29.99"
    }

    func hasReachedNodeLimit(_ currentCount: Int) -> Bool {
        !isPremium && currentCount >= freeNodeLimit
    }

    func hasReachedReelLimit() -> Bool {
        if isPremium { return false }
        let reelsThisMonth = UserDefaults.standard.integer(forKey: reelCountKey)
        return reelsThisMonth >= freeReelLimit
    }

    func recordReelGenerated() {
        let current = UserDefaults.standard.integer(forKey: reelCountKey)
        UserDefaults.standard.set(current + 1, forKey: reelCountKey)
    }

    var remainingFreeReels: Int {
        max(0, freeReelLimit - UserDefaults.standard.integer(forKey: reelCountKey))
    }

    func purchase() async {
        guard let product else {
            purchaseError = "Product not available. Please try again later."
            return
        }

        isLoading = true
        purchaseError = nil

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isPremium = true
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Purchase is pending approval."
            @unknown default:
                break
            }
        } catch {
            purchaseError = "Purchase failed. Please try again."
        }

        isLoading = false
    }

    func restorePurchases() async {
        isLoading = true
        purchaseError = nil

        try? await AppStore.sync()
        await checkEntitlement()

        if !isPremium {
            purchaseError = "No active subscription found."
        }

        isLoading = false
    }

    private func loadProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            product = products.first
        } catch {}
    }

    private func checkEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == productID {
                isPremium = true
                return
            }
        }
        isPremium = false
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result) {
                if transaction.productID == productID {
                    isPremium = transaction.revocationDate == nil
                }
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    private var reelCountKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return "reelsGenerated_\(formatter.string(from: Date()))"
    }
}

nonisolated enum StoreError: Error, Sendable {
    case verificationFailed
}
