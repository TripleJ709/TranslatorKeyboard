//
//  MainViewModel.swift
//  TranslatorKeyboard
//
//  Created by 장주진 on 5/27/26.
//

import StoreKit

final class MainViewModel {

    // MARK: - Actions

    var onSupportTapped: (() -> Void)?
    var onShowGuideTapped: (() -> Void)?

    // MARK: - Purchase

    private let purchaseManager = PurchaseManager.shared

    var products: [Product] { purchaseManager.products }

    func loadProducts() async {
        await purchaseManager.loadProducts()
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        return try await purchaseManager.purchase(product)
    }

    // MARK: - Handlers

    func handleSupportTap() {
        onSupportTapped?()
    }

    func handleShowGuideTap() {
        onShowGuideTapped?()
    }
}
