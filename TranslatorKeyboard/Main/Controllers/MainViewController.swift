//
//  MainViewController.swift
//  TranslatorKeyboard
//
//  Created by 장주진 on 5/27/26.
//

import UIKit

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
    }

    // MARK: - Binding

    private func bindViewModel() {
        mainView.supportButton.addTarget(self, action: #selector(supportTapped), for: .touchUpInside)
        mainView.showGuideButton.addTarget(self, action: #selector(showGuideTapped), for: .touchUpInside)

        viewModel.onSupportTapped = {
            // StoreKit 결제 UI 표시 예정
        }

        viewModel.onShowGuideTapped = {
            // 온보딩 화면으로 이동 예정
        }
    }

    // MARK: - Actions

    @objc private func supportTapped() {
        viewModel.handleSupportTap()
    }

    @objc private func showGuideTapped() {
        viewModel.handleShowGuideTap()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
