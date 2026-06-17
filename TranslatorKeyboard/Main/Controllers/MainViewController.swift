//
//  MainViewController.swift
//  TranslatorKeyboard
//
//  Created by 장주진 on 5/27/26.
//

import UIKit
import StoreKit

class MainViewController: UIViewController {

    // MARK: - Properties

    private let mainView = MainView()
    private let viewModel = MainViewModel()

    // MARK: - Lifecycle

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        Task {
            await viewModel.loadProducts()
        }
    }

    // MARK: - Binding

    private func bindViewModel() {
        mainView.supportButton.addTarget(self, action: #selector(supportTapped), for: .touchUpInside)
        mainView.showGuideButton.addTarget(self, action: #selector(showGuideTapped), for: .touchUpInside)

        viewModel.onShowGuideTapped = {
            // 온보딩 화면으로 이동 예정
        }
    }

    // MARK: - Actions

    @objc private func supportTapped() {
        let products = viewModel.products

        let alert = UIAlertController(
            title: "☕ 개발자에게 커피 사주기",
            message: products.isEmpty
                ? "상품을 불러오는 중입니다..."
                : "후원금은 앱 개발과 유지에 사용됩니다",
            preferredStyle: .actionSheet
        )

        for product in products {
            let emoji: String
            switch product.id {
            case CoffeeProduct.americano.rawValue: emoji = "☕ 아메리카노 한 잔"
            case CoffeeProduct.latte.rawValue:     emoji = "☕ 라떼 한 잔"
            case CoffeeProduct.starbucks.rawValue: emoji = "☕ 스타벅스 한 잔"
            default: emoji = product.displayName
            }
            let action = UIAlertAction(title: "\(emoji) — \(product.displayPrice)", style: .default) { [weak self] _ in
                Task { await self?.purchase(product) }
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    private func purchase(_ product: Product) async {
        do {
            let transaction = try await viewModel.purchase(product)
            showPurchaseResult(success: transaction != nil)
        } catch {
            showPurchaseResult(success: false)
        }
    }

    private func showPurchaseResult(success: Bool) {
        let alert = UIAlertController(
            title: success ? "감사합니다! ☕" : "결제 실패",
            message: success ? "커피 잘 마실게요 :)" : "잠시 후 다시 시도해 주세요",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    @objc private func showGuideTapped() {
        viewModel.handleShowGuideTap()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
