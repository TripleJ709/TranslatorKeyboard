//
//  KeyboardView.swift
//  KeyboardExtension
//
//  Created by 장주진 on 5/31/26.
//

import UIKit

final class KeyboardView: UIView {
    
    // MARK: - Properties
    
    private(set) var currentKeyboardType: KeyboardType = .english
    
    private var currentLayout: KeyboardLayout {
        currentKeyboardType == .english ? .english : .korean
    }
    
    // MARK: - Subviews
    
    lazy var translationBar: TranslationBarView = {
        let view = TranslationBarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var toolbarView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var toolbarLabel: UILabel = {
        let label = UILabel()
        label.text = "TranslatorKeyboard"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var keyboardStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.backgroundColor = .clear
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var rowFactory: KeyboardRowFactory = {
        let factory = KeyboardRowFactory()
        return factory
    }()

    private var keyboardStackBottomConstraint: NSLayoutConstraint!

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateAvailableLanguages(_ languages: [Language]) {
        translationBar.updateAvailableLanguages(languages)
    }

    func updateSafeAreaBottomInset(_ inset: CGFloat) {
        keyboardStackBottomConstraint.constant = -(inset + 5)
    }
    
    func startTranslation() { translationBar.startTranslation() }
    func finishTranslation(success: Bool) { translationBar.finishTranslation(success: success) }

    func updateKeyboardType(_ type: KeyboardType) {
        currentKeyboardType = type
        updateKeyboardLayout()
    }
    
    func updateKeyCase(isUppercase: Bool) {
        let excludedTags: Set<Int> = [ButtonTag.shift.rawValue, ButtonTag.languageSwitch.rawValue,
                                       ButtonTag.space.rawValue, ButtonTag.return.rawValue, ButtonTag.number.rawValue]
        KeyboardButtonHelper.getAllButtons(from: keyboardStackView)
            .filter { !excludedTags.contains($0.tag) }
            .forEach { button in
                if let title = button.title(for: .normal) {
                    button.setTitle(isUppercase ? title.uppercased() : title.lowercased(), for: .normal)
                }
            }
    }
    
    func updateKoreanDoubleConsonant(isShift: Bool) {
        let doubleMap: [String: String] = ["ㅂ": "ㅃ", "ㅈ": "ㅉ", "ㄷ": "ㄸ", "ㄱ": "ㄲ", "ㅅ": "ㅆ"]
        let reverseMap = Dictionary(uniqueKeysWithValues: doubleMap.map { ($1, $0) })
        let excludedTags: Set<Int> = [ButtonTag.shift.rawValue, ButtonTag.languageSwitch.rawValue,
                                       ButtonTag.space.rawValue, ButtonTag.return.rawValue, ButtonTag.number.rawValue]
        KeyboardButtonHelper.getAllButtons(from: keyboardStackView)
            .filter { !excludedTags.contains($0.tag) }
            .forEach { button in
                guard let title = button.title(for: .normal) else { return }
                if isShift, let doubled = doubleMap[title] {
                    button.setTitle(doubled, for: .normal)
                } else if !isShift, let original = reverseMap[title] {
                    button.setTitle(original, for: .normal)
                }
            }
    }
    
    func updateShiftButton(isShift: Bool, isCapsLock: Bool) {
        let shiftButton = KeyboardButtonHelper.getAllButtons(from: keyboardStackView)
            .first { $0.tag == ButtonTag.shift.rawValue }
        let imageName = isCapsLock ? "arrow.up.circle.fill" : (isShift ? "shift.fill" : "shift")
        let config = UIImage.SymbolConfiguration(pointSize: 16)
        shiftButton?.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = UIColor(dynamicProvider: { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 0.18, alpha: 1)
                : UIColor(red: 0.82, green: 0.824, blue: 0.843, alpha: 1)
        })

        addSubview(translationBar)
        addSubview(toolbarView)
        toolbarView.addSubview(toolbarLabel)
        addSubview(keyboardStackView)
        
        setupConstraints()
        updateKeyboardLayout()
    }
    
    private func setupConstraints() {
        let constraints = [
            translationBar.topAnchor.constraint(equalTo: topAnchor),
            translationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            translationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            translationBar.heightAnchor.constraint(equalToConstant: 44),
            
            toolbarView.topAnchor.constraint(equalTo: translationBar.bottomAnchor),
            toolbarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 24),
            
            toolbarLabel.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 8),
            toolbarLabel.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            keyboardStackView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor, constant: 6),
            keyboardStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            keyboardStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
        ]

        keyboardStackBottomConstraint = keyboardStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        keyboardStackBottomConstraint.priority = UILayoutPriority(999)

        constraints.forEach { $0.priority = UILayoutPriority(999) }
        NSLayoutConstraint.activate(constraints + [keyboardStackBottomConstraint])
    }
    
    private func updateKeyboardLayout() {
        keyboardStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let layout = currentLayout
        keyboardStackView.addArrangedSubview(rowFactory.createFirstRow(with: layout))
        keyboardStackView.addArrangedSubview(rowFactory.createSecondRow(with: layout))
        keyboardStackView.addArrangedSubview(rowFactory.createThirdRow(with: layout))
        keyboardStackView.addArrangedSubview(rowFactory.createFourthRow(with: layout))
    }
}
