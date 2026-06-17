//
//  MainViewModel.swift
//  TranslatorKeyboard
//
//  Created by 장주진 on 5/27/26.
//

import Foundation

final class MainViewModel {

    // MARK: - Actions

    var onSupportTapped: (() -> Void)?
    var onShowGuideTapped: (() -> Void)?

    // MARK: - Methods

    func handleSupportTap() {
        onSupportTapped?()
        // StoreKit 연동 예정
    }

    func handleShowGuideTap() {
        onShowGuideTapped?()
        // 온보딩 화면으로 이동 예정
    }
}
