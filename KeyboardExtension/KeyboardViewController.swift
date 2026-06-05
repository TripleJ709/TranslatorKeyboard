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
        viewModel = KeyboardViewModel(textDocumentProxy: textDocumentProxy)
    }
    
    private func bindViewModelToView() {
        viewModel.$isShiftEnabled
            .combineLatest(viewModel.$isUppercase, viewModel.$currentKeyboardType)
            .sink { [weak self] isShift, isCapsLock, keyboardType in
                if keyboardType == .english {
                    let isUppercase = isShift || isCapsLock
                    self?.keyboardView.updateKeyCase(isUppercase: isUppercase)
                } else {
                    self?.keyboardView.updateKoreanDoubleConsonant(isShift: isShift)
                }
                self?.keyboardView.updateShiftButton(isShift: isShift, isCapsLock: isCapsLock)
            }
            .store(in: &cancellables)
        
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
