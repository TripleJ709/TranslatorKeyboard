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
    private var languageManager: AvailableLanguagesManager?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardView()
        setupViewModel()
        bindViewModelToView()
        setupLanguageManager()
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
    
    private func setupLanguageManager() {
        Task { @MainActor in
            languageManager = AvailableLanguagesManager.shared
            await languageManager?.fetchAvailableLanguages()
            if let languages = languageManager?.availableLanguages {
                keyboardView.updateAvailableLanguages(languages)
            } else {
                print("언어 목록 없음")
            }
        }
    }
    
    private func bindViewModelToView() {
        viewModel.$isShiftEnabled
            .combineLatest(viewModel.$isUppercase)
            .sink { [weak self] isShift, isCapsLock in
                let isUppercase = isShift || isCapsLock
                self?.keyboardView.updateKeyCase(isUppercase: isUppercase)
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
    
    func keyboardView(_ view: KeyboardView, didRequestTranslationTo language: Language) {
        // TODO: 번역 로직 (다음 단계에서 구현)
        print("번역 요청: \(language.displayName)")
    }
}
