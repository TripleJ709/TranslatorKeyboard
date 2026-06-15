//
//  TranslationBarView.swift
//  KeyboardExtension
//
//  Created by 장주진 on 6/15/26.
//

import UIKit

protocol TranslationBarViewDelegate: AnyObject {
    func translationBarView(_ view: TranslationBarView, didSelectLanguage language: Language)
    func translationBarViewDidTapTranslate(_ view: TranslationBarView)
}

final class TranslationBarView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: TranslationBarViewDelegate?
    
    private let languageDropdownButton = UIButton(type: .system)
    private let translateButton = UIButton(type: .system)
    private var availableLanguages: [Language] = []
    private var selectedLanguage: Language?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = .systemGray6
        
        setupLanguageDropdownButton()
        setupTranslateButton()
        setupConstraints()
    }
    
    private func setupLanguageDropdownButton() {
        languageDropdownButton.translatesAutoresizingMaskIntoConstraints = false
        languageDropdownButton.setTitle("번역 언어 선택", for: .normal)
        languageDropdownButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        languageDropdownButton.setTitleColor(.label, for: .normal)
        languageDropdownButton.backgroundColor = .systemBackground
        languageDropdownButton.layer.cornerRadius = 8
        languageDropdownButton.layer.borderWidth = 1
        languageDropdownButton.layer.borderColor = UIColor.systemGray4.cgColor
        languageDropdownButton.showsMenuAsPrimaryAction = true
        languageDropdownButton.contentHorizontalAlignment = .center
        
        addSubview(languageDropdownButton)
    }
    
    private func setupTranslateButton() {
        translateButton.translatesAutoresizingMaskIntoConstraints = false
        translateButton.setTitle("번역", for: .normal)
        translateButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        translateButton.setTitleColor(.white, for: .normal)
        translateButton.backgroundColor = .systemBlue
        translateButton.layer.cornerRadius = 8
        translateButton.addTarget(self, action: #selector(translateButtonTapped), for: .touchUpInside)
        
        addSubview(translateButton)
    }
    
    private func setupConstraints() {
        // ⚡️ 모든 제약 조건 우선순위를 낮춰서 width=0 초기 상태에서도 유연하게 대응
        
        let leadingConstraint = languageDropdownButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        leadingConstraint.priority = UILayoutPriority(999)
        
        let trailingToButtonConstraint = languageDropdownButton.trailingAnchor.constraint(equalTo: translateButton.leadingAnchor, constant: -8)
        trailingToButtonConstraint.priority = UILayoutPriority(999)
        
        let centerYConstraint1 = languageDropdownButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        centerYConstraint1.priority = UILayoutPriority(999)
        
        let heightConstraint1 = languageDropdownButton.heightAnchor.constraint(equalToConstant: 32)
        heightConstraint1.priority = .defaultHigh // 750
        
        let trailingConstraint = translateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        trailingConstraint.priority = UILayoutPriority(999)
        
        let centerYConstraint2 = translateButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        centerYConstraint2.priority = UILayoutPriority(999)
        
        let heightConstraint2 = translateButton.heightAnchor.constraint(equalToConstant: 32)
        heightConstraint2.priority = .defaultHigh // 750
        
        let widthConstraint = translateButton.widthAnchor.constraint(equalToConstant: 60)
        widthConstraint.priority = UILayoutPriority(999) // ⚡️ 999로 낮춤!
        
        NSLayoutConstraint.activate([
            leadingConstraint,
            trailingToButtonConstraint,
            centerYConstraint1,
            heightConstraint1,
            trailingConstraint,
            centerYConstraint2,
            heightConstraint2,
            widthConstraint
        ])
    }
    
    // MARK: - Public Methods
    
    func updateAvailableLanguages(_ languages: [Language]) {
        availableLanguages = languages
        updateDropdownMenu()
    }
    
    func startTranslation() {
        translateButton.isEnabled = false
        translateButton.setTitle("번역 중...", for: .normal)
        translateButton.backgroundColor = .systemGray
        languageDropdownButton.isEnabled = false
    }
    
    func finishTranslation(success: Bool) {
        translateButton.isEnabled = true
        translateButton.setTitle("번역", for: .normal)
        languageDropdownButton.isEnabled = true
        
        let color: UIColor = success ? .systemGreen : .systemRed
        translateButton.backgroundColor = color
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.translateButton.backgroundColor = .systemBlue
        }
    }
    
    func getSelectedLanguage() -> Language? {
        return selectedLanguage
    }
    
    // MARK: - Private Methods
    
    private func updateDropdownMenu() {
        guard !availableLanguages.isEmpty else { return }
        
        let menuActions = availableLanguages.map { language in
            UIAction(title: "\(language.displayName) (\(language.shortCode))") { [weak self] _ in
                self?.handleLanguageSelection(language)
            }
        }
        
        languageDropdownButton.menu = UIMenu(title: "번역 언어 선택", children: menuActions)
        
        if selectedLanguage == nil, let firstLanguage = availableLanguages.first {
            selectedLanguage = firstLanguage
            updateDropdownButtonTitle()
        }
    }
    
    private func handleLanguageSelection(_ language: Language) {
        selectedLanguage = language
        updateDropdownButtonTitle()
        delegate?.translationBarView(self, didSelectLanguage: language)
    }
    
    private func updateDropdownButtonTitle() {
        guard let selected = selectedLanguage else { return }
        languageDropdownButton.setTitle("🌐 \(selected.displayName)", for: .normal)
    }
    
    // MARK: - Actions
    
    @objc private func translateButtonTapped() {
        delegate?.translationBarViewDidTapTranslate(self)
    }
}
