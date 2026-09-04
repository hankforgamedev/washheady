import Combine
import StoreKit

enum StorefrontError: Error {
    case failedVerification
}

final class StorefrontModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var entitledProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var message: String?

    private let productIDs: Set<String>

    init(productIDs: [String]) {
        self.productIDs = Set(productIDs)
    }

    @MainActor
    func load() async {
        guard !productIDs.isEmpty else {
            products = []
            message = "角色包尚未設定。免費功能仍可正常使用。"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: productIDs)
                .sorted { $0.displayName < $1.displayName }
            await refreshEntitlements()
            message = products.isEmpty ? "目前沒有可購買的角色包。" : nil
        } catch {
            message = "商店暫時無法載入。免費功能不受影響。"
        }
    }

    @MainActor
    func purchase(_ product: Product) async {
        do {
            switch try await product.purchase() {
            case .success(let verification):
                let transaction = try verified(verification)
                await transaction.finish()
                await refreshEntitlements()
                message = "角色包已解鎖。"
            case .pending:
                message = "購買正在等待確認。"
            case .userCancelled:
                message = nil
            @unknown default:
                message = "商店回傳了尚未支援的狀態。"
            }
        } catch {
            message = "購買沒有完成，沒有變更免費功能。"
        }
    }

    @MainActor
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            message = entitledProductIDs.isEmpty ? "沒有找到已購買的角色包。" : "購買內容已還原。"
        } catch {
            message = "目前無法還原購買，請稍後再試。"
        }
    }

    @MainActor
    private func refreshEntitlements() async {
        var verifiedIDs = Set<String>()

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  transaction.revocationDate == nil,
                  productIDs.contains(transaction.productID) else {
                continue
            }
            verifiedIDs.insert(transaction.productID)
        }

        entitledProductIDs = verifiedIDs
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw StorefrontError.failedVerification
        }
    }
}
