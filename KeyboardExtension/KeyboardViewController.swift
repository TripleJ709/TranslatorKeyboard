//
//  KeyboardViewController.swift
//  KeyboardExtension
//
//  Created by 장주진 on 5/29/26.
//

import UIKit
import Combine

class KeyboardViewController: UIInputViewController {
    
    // MARK: - Properties
    
    private var keyboardView: KeyboardView!
    private var viewModel: KeyboardViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardView()
        setupViewModel()
        bindViewModelToView()
    }
    
    // MARK: - Setup
    
    private func setupKeyboardView() {
        keyboardView = KeyboardView()
        keyboardView.delegate = self
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardView)
        
        NSLayoutConstraint.activate([
            keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupViewModel() {
        // ViewModel 생성
        viewModel = KeyboardViewModel(textDocumentProxy: textDocumentProxy)
    }
    
    /// ViewModel의 상태 변화를 View에 반영
    private func bindViewModelToView() {
        // Shift 및 Caps Lock 상태 바인딩
        viewModel.$isShiftEnabled
            .combineLatest(viewModel.$isUppercase)
            .sink { [weak self] isShift, isCapsLock in
                let isUppercase = isShift || isCapsLock
                self?.keyboardView.updateKeyCase(isUppercase: isUppercase)
                self?.keyboardView.updateShiftButton(isShift: isShift, isCapsLock: isCapsLock)
            }
            .store(in: &cancellables)
        
        // 키보드 타입 변경 바인딩
        viewModel.$currentKeyboardType
            .sink { [weak self] keyboardType in
                self?.keyboardView.updateKeyboardType(keyboardType)
            }
            .store(in: &cancellables)
    }
}

// MARK: - KeyboardViewDelegate

extension KeyboardViewController: KeyboardViewDelegate {
    
    func keyboardView(_ view: KeyboardView, didTapKey key: String) {
        viewModel.handleKeyTap(key)
    }
    
    func keyboardViewDidTapShift(_ view: KeyboardView) {
        viewModel.handleShiftTap()
    }
    
    func keyboardViewDidTapDelete(_ view: KeyboardView) {
        viewModel.handleDeleteTap()
    }
    
    func keyboardViewDidTapSpace(_ view: KeyboardView) {
        viewModel.handleSpaceTap()
    }
    
    func keyboardViewDidTapReturn(_ view: KeyboardView) {
        viewModel.handleReturnTap()
    }
    
    func keyboardViewDidTapLanguageSwitch(_ view: KeyboardView) {
        viewModel.toggleKeyboardType()
    }
}
