//
//  PurchaseManager.swift
//  TranslatorKeyboard
//
//  Created by 장주진 on 5/27/26.
//

import StoreKit

enum CoffeeProduct: String, CaseIterable {
    case americano = "com.jang.TranslatorKeyboard.donation.americano"
    case latte     = "com.jang.TranslatorKeyboard.donation.latte"
    case starbucks = "com.jang.TranslatorKeyboard.donation.starbucks"
}

final class PurchaseManager {
    static let shared = PurchaseManager()

    private(set) var products: [Product] = []
    private var updateListenerTask: Task<Void, Never>?

    private init() {
        updateListenerTask = listenForTransactions()
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func loadProducts() async {
        do {
            let ids = CoffeeProduct.allCases.map { $0.rawValue }
            let loaded = try await Product.products(for: ids)
            await MainActor.run {
                self.products = loaded.sorted { $0.price < $1.price }
            }
        } catch {}
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
            }
        }
    }
}
