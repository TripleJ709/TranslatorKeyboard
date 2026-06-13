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
            .combineLatest(viewModel.$isUppercase, viewModel.$currentKeyboardType)
            .sink { [weak self] isShift, isCapsLock, keyboardType in
                let isUppercase = isShift || isCapsLock
                self?.keyboardView.updateKeyCase(isUppercase: isUppercase)
                self?.keyboardView.updateShiftButton(isShift: isShift, isCapsLock: isCapsLock)
                
                // 한글 모드에서 Shift 상태에 따라 쌍자음 처리
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
        print("🌐 [번역] 요청: \(language.displayName)")
        
        Task {
            await performTranslation(to: language)
        }
    }
    
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
