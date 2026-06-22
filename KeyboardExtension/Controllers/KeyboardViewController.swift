//
//  KeyboardViewController.swift
//  KeyboardExtension
//
//  Created by 장주진 on 5/29/26.
//

import UIKit
import Combine
import Translation
import NaturalLanguage

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
        setupLanguageManagerAsync()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyKeyboardAppearance()
        updateKeyboardHeight()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // 실제 safe area가 확정된 시점에 constraint 업데이트 (애니메이션 없이)
        UIView.performWithoutAnimation {
            keyboardView.updateSafeAreaBottomInset(view.safeAreaInsets.bottom)
            view.layoutIfNeeded()
        }
    }
    
    private func applyKeyboardAppearance() {
        switch textDocumentProxy.keyboardAppearance {
        case .dark:
            overrideUserInterfaceStyle = .dark
        case .light:
            overrideUserInterfaceStyle = .light
        default:
            overrideUserInterfaceStyle = .unspecified
        }
    }

    private func updateKeyboardHeight() {
        let estimatedHeight: CGFloat = 291
        
        if let heightConstraint = view.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = estimatedHeight
        } else {
            let constraint = view.heightAnchor.constraint(equalToConstant: estimatedHeight)
            constraint.priority = .defaultHigh
            constraint.isActive = true
        }
    }
    
    // MARK: - Setup
    
    private func setupKeyboardView() {
        let keyboardBgColor = UIColor(dynamicProvider: { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 0.18, alpha: 1)
                : UIColor(red: 0.82, green: 0.824, blue: 0.843, alpha: 1)
        })
        view.backgroundColor = keyboardBgColor
        inputView?.backgroundColor = keyboardBgColor

        keyboardView = KeyboardView()
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardView)

        keyboardView.translationBar.delegate = self
        keyboardView.rowFactory.delegate = self

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
    
    private func setupLanguageManagerAsync() {
        Task.detached(priority: .userInitiated) {
            let manager = AvailableLanguagesManager.shared
            
            let cachedLanguages = manager.availableLanguages
            if !cachedLanguages.isEmpty {
                await MainActor.run {
                    self.languageManager = manager
                    self.keyboardView.updateAvailableLanguages(cachedLanguages)
                }
            }
            
            await manager.fetchAvailableLanguages()
            let systemLanguages = manager.availableLanguages
            
            await MainActor.run {
                self.languageManager = manager
                self.keyboardView.updateAvailableLanguages(systemLanguages)
            }
        }
    }
    
    private func bindViewModelToView() {
        viewModel.$isShiftEnabled
            .combineLatest(viewModel.$isUppercase, viewModel.$currentKeyboardType)
            .sink { [weak self] isShift, isCapsLock, keyboardType in
                let isUppercase = isShift || isCapsLock
                self?.keyboardView.updateKeyCase(isUppercase: isUppercase)
                self?.keyboardView.updateShiftButton(isShift: isShift, isCapsLock: isCapsLock)
                
                if keyboardType == .korean {
                    self?.keyboardView.updateKoreanDoubleConsonant(isShift: isShift)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$currentKeyboardType
            .sink { [weak self] keyboardType in
                self?.keyboardView.updateKeyboardType(keyboardType)
            }
            .store(in: &cancellables)
    }
}

// MARK: - TranslationBarViewDelegate

extension KeyboardViewController: TranslationBarViewDelegate {
    func translationBarView(_ view: TranslationBarView, didSelectLanguage language: Language) {
        print("🌐 [언어 선택] \(language.displayName)")
    }
    
    func translationBarViewDidTapTranslate(_ view: TranslationBarView) {
        guard let targetLanguage = view.getSelectedLanguage() else { return }
        print("🌐 [번역] 요청: \(targetLanguage.displayName)")
        
        Task {
            await performTranslation(to: targetLanguage)
        }
    }
}

// MARK: - KeyboardRowActionDelegate

extension KeyboardViewController: KeyboardRowActionDelegate {
    func keyboardRowFactory(_ factory: KeyboardRowFactory, didTapKey key: String) {
        viewModel.handleKeyTap(key)
    }
    
    func keyboardRowFactoryDidTapShift(_ factory: KeyboardRowFactory) {
        viewModel.handleShiftTap()
    }
    
    func keyboardRowFactoryDidTapDelete(_ factory: KeyboardRowFactory) {
        viewModel.handleDeleteTap()
    }
    
    func keyboardRowFactoryDidTapSpace(_ factory: KeyboardRowFactory) {
        viewModel.handleSpaceTap()
    }
    
    func keyboardRowFactoryDidTapReturn(_ factory: KeyboardRowFactory) {
        viewModel.handleReturnTap()
    }
    
    func keyboardRowFactoryDidTapLanguageSwitch(_ factory: KeyboardRowFactory) {
        viewModel.toggleKeyboardType()
    }
}

// MARK: - Translation

extension KeyboardViewController {
    
    @MainActor
    private func performTranslation(to targetLanguage: Language) async {
        print("🚀 [번역] performTranslation 시작")
        
        keyboardView.startTranslation()
        
        guard let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty else {
            print("⚠️ [번역] 선택된 텍스트가 없습니다")
            keyboardView.finishTranslation(success: false)
            return
        }
        
        let targetLocaleLanguage = Locale.Language(identifier: targetLanguage.languageCode)
        
        do {
            let sourceLanguageCode = detectLanguage(from: selectedText)
            let sourceLocaleLanguage = Locale.Language(identifier: sourceLanguageCode)
            
            let session = TranslationSession(
                installedSource: sourceLocaleLanguage,
                target: targetLocaleLanguage
            )
            
            let response = try await session.translate(selectedText)
            textDocumentProxy.insertText(response.targetText)
            viewModel.resetHangulState()
            keyboardView.finishTranslation(success: true)
            
        } catch {
            print("❌ [번역] 에러: \(error.localizedDescription)")
            keyboardView.finishTranslation(success: false)
        }
    }
    
    private func detectLanguage(from text: String) -> String {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        guard let dominantLanguage = recognizer.dominantLanguage else { return "en" }
        return dominantLanguage.rawValue
    }
}
