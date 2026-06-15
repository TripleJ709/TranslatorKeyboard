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
        
        DispatchQueue.main.async { [weak self] in
            self?.setupLanguageManagerAsync()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        keyboardView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateKeyboardHeight()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
        view.backgroundColor = .clear
        inputView?.backgroundColor = .clear
        
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
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
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
        // 언어 선택 이벤트는 내부적으로 처리됨
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
        
        print("📋 [번역] documentContextBeforeInput: \(textDocumentProxy.documentContextBeforeInput ?? "nil")")
        print("📋 [번역] documentContextAfterInput: \(textDocumentProxy.documentContextAfterInput ?? "nil")")
        print("📋 [번역] selectedText: \(textDocumentProxy.selectedText ?? "nil")")
        
        guard let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty else {
            print("⚠️ [번역] 선택된 텍스트가 없습니다")
            print("💡 [번역] 텍스트를 드래그하여 선택한 후 번역 버튼을 눌러주세요")
            
            keyboardView.finishTranslation(success: false)
            return
        }
        
        print("📝 [번역] 선택된 텍스트: \(selectedText)")
        
        let targetLocaleLanguage = Locale.Language(identifier: targetLanguage.languageCode)
        
        do {
            let sourceLanguageCode = detectLanguage(from: selectedText)
            let sourceLocaleLanguage = Locale.Language(identifier: sourceLanguageCode)
            
            print("🔍 [번역] 감지된 소스 언어: \(sourceLanguageCode)")
            
            let session = TranslationSession(
                installedSource: sourceLocaleLanguage,
                target: targetLocaleLanguage
            )
            
            print("⏳ [번역] 번역 중... (\(sourceLanguageCode) → \(targetLanguage.languageCode))")
            
            let response = try await session.translate(selectedText)
            let finalText = response.targetText
            
            print("✅ [번역] 완료: \(finalText)")
            
            textDocumentProxy.insertText(finalText)
            keyboardView.finishTranslation(success: true)
            
        } catch {
            print("❌ [번역] 에러: \(error.localizedDescription)")
            
            keyboardView.finishTranslation(success: false)
            
        }
    }
    
    /// 텍스트에서 언어 자동 감지
    private func detectLanguage(from text: String) -> String {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        guard let dominantLanguage = recognizer.dominantLanguage else {
            print("⚠️ [번역] 언어 감지 실패, 기본값 'en' 사용")
            return "en"
        }
        
        return dominantLanguage.rawValue
    }
}
