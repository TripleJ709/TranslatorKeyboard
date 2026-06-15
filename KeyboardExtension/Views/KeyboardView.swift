//
//  KeyboardView.swift
//  KeyboardExtension
//
//  Created by 장주진 on 5/31/26.
//

import UIKit

protocol KeyboardViewDelegate: AnyObject {
    func keyboardView(_ view: KeyboardView, didTapKey key: String)
    func keyboardViewDidTapShift(_ view: KeyboardView)
    func keyboardViewDidTapDelete(_ view: KeyboardView)
    func keyboardViewDidTapSpace(_ view: KeyboardView)
    func keyboardViewDidTapReturn(_ view: KeyboardView)
    func keyboardViewDidTapLanguageSwitch(_ view: KeyboardView)
    func keyboardView(_ view: KeyboardView, didRequestTranslationTo language: Language)
}

// MARK: - Button Tags
private enum ButtonTag: Int {
    case shift = 999
    case languageSwitch = 1000
    case space = 1001
    case `return` = 1002
    case number = 1003
}

// MARK: - UIButton Extension
private extension UIButton {
    func applyKeyStyle() {
        setTitleColor(.label, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 23, weight: .regular)
        backgroundColor = .white
        layer.cornerRadius = 5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 0
        layer.shadowOffset = CGSize(width: 0, height: 1)
        heightAnchor.constraint(equalToConstant: 42).isActive = true
    }
    
    func applySpecialKeyStyle(width: CGFloat) {
        setTitleColor(.label, for: .normal)
        tintColor = .label
        backgroundColor = .systemGray2
        titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        layer.cornerRadius = 5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 0
        layer.shadowOffset = CGSize(width: 0, height: 1)
        heightAnchor.constraint(equalToConstant: 42).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
}

final class KeyboardView: UIView {
    
    weak var delegate: KeyboardViewDelegate?
    
    private let translationBar = UIView()
    private let languageDropdownButton = UIButton(type: .system)
    private let translateButton = UIButton(type: .system)
    private let toolbarView = UIView()
    private let toolbarLabel = UILabel()
    private let keyboardStackView = UIStackView()
    private(set) var currentKeyboardType: KeyboardType = .english
    private var availableLanguages: [Language] = []
    private var selectedLanguage: Language?
    
    private struct KeyboardLayout {
        let firstRowKeys: [String]
        let secondRowKeys: [String]
        let thirdRowKeys: [String]
        let languageSwitchTitle: String
        
        static let english = KeyboardLayout(
            firstRowKeys: ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
            secondRowKeys: ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
            thirdRowKeys: ["Z", "X", "C", "V", "B", "N", "M"],
            languageSwitchTitle: "한글"
        )
        
        static let korean = KeyboardLayout(
            firstRowKeys: ["ㅂ", "ㅈ", "ㄷ", "ㄱ", "ㅅ", "ㅛ", "ㅕ", "ㅑ", "ㅐ", "ㅔ"],
            secondRowKeys: ["ㅁ", "ㄴ", "ㅇ", "ㄹ", "ㅎ", "ㅗ", "ㅓ", "ㅏ", "ㅣ"],
            thirdRowKeys: ["ㅋ", "ㅌ", "ㅊ", "ㅍ", "ㅠ", "ㅜ", "ㅡ"],
            languageSwitchTitle: "ABC"
        )
    }
    
    private var currentLayout: KeyboardLayout {
        currentKeyboardType == .english ? .english : .korean
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods

    func updateKeyboardType(_ type: KeyboardType) {
        currentKeyboardType = type
        updateKeyboardLayout()
    }
    
    func updateKeyCase(isUppercase: Bool) {
        let excludedTags: Set<Int> = [ButtonTag.shift.rawValue, ButtonTag.languageSwitch.rawValue, 
                                       ButtonTag.space.rawValue, ButtonTag.return.rawValue, ButtonTag.number.rawValue]
        
        func getAllButtons(from view: UIView) -> [UIButton] {
            var buttons: [UIButton] = []
            
            if let button = view as? UIButton {
                buttons.append(button)
            }
            
            if let stackView = view as? UIStackView {
                stackView.arrangedSubviews.forEach { subview in
                    buttons.append(contentsOf: getAllButtons(from: subview))
                }
            }
            
            return buttons
        }
        
        getAllButtons(from: keyboardStackView)
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
        
        func getAllButtons(from view: UIView) -> [UIButton] {
            var buttons: [UIButton] = []
            
            if let button = view as? UIButton {
                buttons.append(button)
            }
            
            if let stackView = view as? UIStackView {
                for subview in stackView.arrangedSubviews {
                    buttons.append(contentsOf: getAllButtons(from: subview))
                }
            }
            
            return buttons
        }
        
        getAllButtons(from: keyboardStackView)
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
        func getAllButtons(from view: UIView) -> [UIButton] {
            var buttons: [UIButton] = []
            
            if let button = view as? UIButton {
                buttons.append(button)
            }
            
            if let stackView = view as? UIStackView {
                for subview in stackView.arrangedSubviews {
                    buttons.append(contentsOf: getAllButtons(from: subview))
                }
            }
            
            return buttons
        }
        
        let shiftButton = getAllButtons(from: keyboardStackView)
            .first { $0.tag == ButtonTag.shift.rawValue }
        
        let imageName = isCapsLock ? "arrow.up.circle.fill" : (isShift ? "shift.fill" : "shift")
        let config = UIImage.SymbolConfiguration(pointSize: 16)
        shiftButton?.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray5
        
        setupTranslationBar()
        setupToolbar()
        setupKeyboardLayout()
    }
    
    private func setupTranslationBar() {
        translationBar.backgroundColor = .systemGray6
        translationBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(translationBar)
        
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
        
        translateButton.translatesAutoresizingMaskIntoConstraints = false
        translateButton.setTitle("번역", for: .normal)
        translateButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        translateButton.setTitleColor(.white, for: .normal)
        translateButton.backgroundColor = .systemBlue
        translateButton.layer.cornerRadius = 8
        translateButton.addTarget(self, action: #selector(translateButtonTapped), for: .touchUpInside)
        
        translationBar.addSubview(languageDropdownButton)
        translationBar.addSubview(translateButton)
        
        NSLayoutConstraint.activate([
            translationBar.topAnchor.constraint(equalTo: topAnchor),
            translationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            translationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            translationBar.heightAnchor.constraint(equalToConstant: 44),
            
            languageDropdownButton.leadingAnchor.constraint(equalTo: translationBar.leadingAnchor, constant: 8),
            languageDropdownButton.trailingAnchor.constraint(equalTo: translateButton.leadingAnchor, constant: -8),
            languageDropdownButton.centerYAnchor.constraint(equalTo: translationBar.centerYAnchor),
            languageDropdownButton.heightAnchor.constraint(equalToConstant: 32),
            
            translateButton.trailingAnchor.constraint(equalTo: translationBar.trailingAnchor, constant: -8),
            translateButton.centerYAnchor.constraint(equalTo: translationBar.centerYAnchor),
            translateButton.heightAnchor.constraint(equalToConstant: 32),
            translateButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func updateAvailableLanguages(_ languages: [Language]) {
        availableLanguages = languages
        updateDropdownMenu()
    }
    
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
    }
    
    private func updateDropdownButtonTitle() {
        guard let selected = selectedLanguage else { return }
        languageDropdownButton.setTitle("🌐 \(selected.displayName)", for: .normal)
    }
    
    private func setupToolbar() {
        toolbarView.backgroundColor = UIColor.systemGray6
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toolbarView)
        
        toolbarLabel.text = "TranslatorKeyboard"
        toolbarLabel.font = .systemFont(ofSize: 12)
        toolbarLabel.textColor = .secondaryLabel
        toolbarLabel.translatesAutoresizingMaskIntoConstraints = false
        toolbarView.addSubview(toolbarLabel)
        
        NSLayoutConstraint.activate([
            toolbarView.topAnchor.constraint(equalTo: translationBar.bottomAnchor),
            toolbarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 24),
            
            toolbarLabel.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 8),
            toolbarLabel.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor)
        ])
    }
    
    private func setupKeyboardLayout() {
        keyboardStackView.axis = .vertical
        keyboardStackView.spacing = 12  // iOS 기본 키 간격
        keyboardStackView.distribution = .fillEqually
        keyboardStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(keyboardStackView)
        
        NSLayoutConstraint.activate([
            keyboardStackView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor, constant: 6),
            keyboardStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            keyboardStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            keyboardStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -5)
        ])
        
        updateKeyboardLayout()
    }
    
    private func updateKeyboardLayout() {
        keyboardStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let layout = currentLayout
        
        keyboardStackView.addArrangedSubview(createFirstRow(with: layout))
        keyboardStackView.addArrangedSubview(createSecondRow(with: layout))
        keyboardStackView.addArrangedSubview(createThirdRow(with: layout))
        keyboardStackView.addArrangedSubview(createFourthRow(with: layout))
    }
    
    // MARK: - Keyboard Rows (Unified)
    
    private func createFirstRow(with layout: KeyboardLayout) -> UIStackView {
        let row = createRowStackView()
        layout.firstRowKeys.forEach { row.addArrangedSubview(createKeyButton(key: $0)) }
        return row
    }
    
    private func createSecondRow(with layout: KeyboardLayout) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 6
        row.distribution = .fill
        
        let leftSpacer = UIView()
        let rightSpacer = UIView()
        let keysStack = UIStackView()
        keysStack.axis = .horizontal
        keysStack.spacing = 6
        keysStack.distribution = .fillEqually
        
        layout.secondRowKeys.forEach { keysStack.addArrangedSubview(createKeyButton(key: $0)) }
        
        row.addArrangedSubview(leftSpacer)
        row.addArrangedSubview(keysStack)
        row.addArrangedSubview(rightSpacer)
        
        leftSpacer.widthAnchor.constraint(equalToConstant: 18).isActive = true
        rightSpacer.widthAnchor.constraint(equalTo: leftSpacer.widthAnchor).isActive = true
        
        return row
    }
    
    private func createThirdRow(with layout: KeyboardLayout) -> UIStackView {
        let row = createRowStackView()
        
        let shiftButton = createSpecialButton(title: nil, systemImage: "shift", width: 44)
        shiftButton.tag = ButtonTag.shift.rawValue
        shiftButton.addTarget(self, action: #selector(shiftTapped), for: .touchUpInside)
        row.addArrangedSubview(shiftButton)
        
        layout.thirdRowKeys.forEach { row.addArrangedSubview(createKeyButton(key: $0)) }
        
        let deleteButton = createSpecialButton(title: nil, systemImage: "delete.left", width: 44)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        row.addArrangedSubview(deleteButton)
        
        return row
    }
    
    private func createFourthRow(with layout: KeyboardLayout) -> UIStackView {
        let row = createRowStackView()
        row.distribution = .fill
        
        let languageWidth: CGFloat = layout.languageSwitchTitle == "ABC" ? 52 : 42
        let languageButton = createSpecialButton(title: layout.languageSwitchTitle, systemImage: nil, width: languageWidth)
        languageButton.tag = ButtonTag.languageSwitch.rawValue
        languageButton.addTarget(self, action: #selector(languageSwitchTapped), for: .touchUpInside)
        
        let numberButton = createSpecialButton(title: "123", systemImage: nil, width: 42)
        numberButton.tag = ButtonTag.number.rawValue
        
        let spaceButton = UIButton(type: .system)
        spaceButton.setTitle("space", for: .normal)
        spaceButton.setTitleColor(.label, for: .normal)
        spaceButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        spaceButton.backgroundColor = .white
        spaceButton.layer.cornerRadius = 5
        spaceButton.layer.shadowColor = UIColor.black.cgColor
        spaceButton.layer.shadowOpacity = 0.15
        spaceButton.layer.shadowRadius = 0
        spaceButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        spaceButton.tag = ButtonTag.space.rawValue
        spaceButton.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)
        
        let returnButton = createSpecialButton(title: "return", systemImage: nil, width: 88)
        returnButton.tag = ButtonTag.return.rawValue
        returnButton.addTarget(self, action: #selector(returnTapped), for: .touchUpInside)
        
        [languageButton, numberButton, spaceButton, returnButton].forEach { row.addArrangedSubview($0) }
        
        return row
    }
    
    // MARK: - Button Factory Methods
    
    private func createRowStackView() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6  // iOS 기본 키 간격
        stack.distribution = .fillEqually
        return stack
    }
    
    private func createKeyButton(key: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(key.lowercased(), for: .normal)
        button.applyKeyStyle()
        button.tag = key.unicodeScalars.first?.value.hashValue ?? 0
        button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func createSpecialButton(title: String?, systemImage: String?, width: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        if let title = title {
            button.setTitle(title, for: .normal)
        } else if let imageName = systemImage {
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            button.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        }
        button.applySpecialKeyStyle(width: width)
        return button
    }
    
    // MARK: - Actions
    
    @objc private func translateButtonTapped() {
        guard let targetLanguage = selectedLanguage else { return }
        delegate?.keyboardView(self, didRequestTranslationTo: targetLanguage)
    }
    
    @objc private func keyTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        delegate?.keyboardView(self, didTapKey: title.uppercased())
    }
    
    @objc private func shiftTapped() { delegate?.keyboardViewDidTapShift(self) }
    @objc private func deleteTapped() { delegate?.keyboardViewDidTapDelete(self) }
    @objc private func spaceTapped() { delegate?.keyboardViewDidTapSpace(self) }
    @objc private func returnTapped() { delegate?.keyboardViewDidTapReturn(self) }
    @objc private func languageSwitchTapped() { delegate?.keyboardViewDidTapLanguageSwitch(self) }
    
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
}
