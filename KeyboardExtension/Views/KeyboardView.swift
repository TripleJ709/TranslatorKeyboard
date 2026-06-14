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

final class KeyboardView: UIView {
    
    // MARK: - Properties
    
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
    
    // MARK: - Keyboard Layout Configuration
    
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
        for subview in keyboardStackView.arrangedSubviews {
            guard let rowStack = subview as? UIStackView else { continue }
            for button in rowStack.arrangedSubviews.compactMap({ $0 as? UIButton }) {
                if button.tag != 999 &&   // Shift
                   button.tag != 1000 &&  // Language switch
                   button.tag != 1001 &&  // Space
                   button.tag != 1002,    // Return
                   let title = button.title(for: .normal) {
                    button.setTitle(isUppercase ? title.uppercased() : title.lowercased(), for: .normal)
                }
            }
        }
    }
    
    func updateKoreanDoubleConsonant(isShift: Bool) {
        let doubleConsonantMap: [String: String] = [
            "ㅂ": "ㅃ", "ㅈ": "ㅉ", "ㄷ": "ㄸ",
            "ㄱ": "ㄲ", "ㅅ": "ㅆ"
        ]
        
        for subview in keyboardStackView.arrangedSubviews {
            guard let rowStack = subview as? UIStackView else { continue }
            for button in rowStack.arrangedSubviews.compactMap({ $0 as? UIButton }) {
                if button.tag != 999 && button.tag != 1000 && 
                   button.tag != 1001 && button.tag != 1002,
                   let title = button.title(for: .normal) {
                    
                    if isShift {
                        if let doubled = doubleConsonantMap[title] {
                            button.setTitle(doubled, for: .normal)
                        }
                    } else {
                        let reverseMap = doubleConsonantMap.reduce(into: [String: String]()) { result, pair in
                            result[pair.value] = pair.key
                        }
                        if let original = reverseMap[title] {
                            button.setTitle(original, for: .normal)
                        }
                    }
                }
            }
        }
    }
    
    func updateShiftButton(isShift: Bool, isCapsLock: Bool) {
        for subview in keyboardStackView.arrangedSubviews {
            guard let rowStack = subview as? UIStackView else { continue }
            if let shiftButton = rowStack.arrangedSubviews.compactMap({ $0 as? UIButton }).first(where: { $0.tag == 999 }) {
                let imageName = isCapsLock ? "arrow.up.circle.fill" : (isShift ? "shift.fill" : "shift")
                let config = UIImage.SymbolConfiguration(pointSize: 16)
                shiftButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
            }
        }
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray5
        
        setupTranslationBar()
        setupToolbar()
        setupKeyboardLayout()
    }
    
    private func setupTranslationBar() {
        translationBar.backgroundColor = UIColor.systemGray6
        translationBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(translationBar)
        
        // 드롭다운 버튼 설정
        languageDropdownButton.translatesAutoresizingMaskIntoConstraints = false
        languageDropdownButton.setTitle("번역 언어 선택", for: .normal)
        languageDropdownButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        languageDropdownButton.setTitleColor(.label, for: .normal)
        languageDropdownButton.backgroundColor = .systemBackground
        languageDropdownButton.layer.cornerRadius = 8
        languageDropdownButton.layer.borderWidth = 1
        languageDropdownButton.layer.borderColor = UIColor.systemGray4.cgColor
        languageDropdownButton.contentHorizontalAlignment = .center
        languageDropdownButton.showsMenuAsPrimaryAction = true
        
        translationBar.addSubview(languageDropdownButton)
        
        // 번역 버튼 설정
        translateButton.translatesAutoresizingMaskIntoConstraints = false
        translateButton.setTitle("번역", for: .normal)
        translateButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        translateButton.setTitleColor(.white, for: .normal)
        translateButton.backgroundColor = .systemBlue
        translateButton.layer.cornerRadius = 8
        translateButton.addTarget(self, action: #selector(translateButtonTapped), for: .touchUpInside)
        
        translationBar.addSubview(translateButton)
        
        NSLayoutConstraint.activate([
            translationBar.topAnchor.constraint(equalTo: topAnchor),
            translationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            translationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            translationBar.heightAnchor.constraint(equalToConstant: 44),
            
            // 드롭다운 버튼 (왼쪽, 가변 너비)
            languageDropdownButton.leadingAnchor.constraint(equalTo: translationBar.leadingAnchor, constant: 8),
            languageDropdownButton.trailingAnchor.constraint(equalTo: translateButton.leadingAnchor, constant: -8),
            languageDropdownButton.centerYAnchor.constraint(equalTo: translationBar.centerYAnchor),
            languageDropdownButton.heightAnchor.constraint(equalToConstant: 32),
            
            // 번역 버튼 (오른쪽, 고정 너비)
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
        
        var menuActions: [UIAction] = []
        
        for language in availableLanguages {
            let action = UIAction(
                title: "\(language.displayName) (\(language.shortCode))",
                handler: { [weak self] _ in
                    self?.handleLanguageSelection(language)
                }
            )
            menuActions.append(action)
        }
        
        let menu = UIMenu(title: "번역 언어 선택", children: menuActions)
        languageDropdownButton.menu = menu
        
        if selectedLanguage == nil, let firstLanguage = availableLanguages.first {
            selectedLanguage = firstLanguage
            updateDropdownButtonTitle()
        }
    }
    
    /// 언어 선택 처리 (번역은 실행하지 않음)
    private func handleLanguageSelection(_ language: Language) {
        selectedLanguage = language
        updateDropdownButtonTitle()
        // delegate 호출 제거 - 번역 버튼을 눌러야만 번역 실행
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
        
        for key in layout.firstRowKeys {
            let button = createKeyButton(key: key)
            row.addArrangedSubview(button)
        }
        
        return row
    }
    
    private func createSecondRow(with layout: KeyboardLayout) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 6
        row.distribution = .fill  // fillEqually에서 fill로 변경
        
        // 왼쪽 스페이서 - 작은 고정 크기
        let leftSpacer = UIView()
        leftSpacer.translatesAutoresizingMaskIntoConstraints = false
        row.addArrangedSubview(leftSpacer)
        
        // 2열 키들 컨테이너 (균등 분배)
        let keysStack = UIStackView()
        keysStack.axis = .horizontal
        keysStack.spacing = 6
        keysStack.distribution = .fillEqually
        
        for key in layout.secondRowKeys {
            let button = createKeyButton(key: key)
            keysStack.addArrangedSubview(button)
        }
        
        row.addArrangedSubview(keysStack)
        
        // 오른쪽 스페이서 - 왼쪽과 동일한 크기
        let rightSpacer = UIView()
        rightSpacer.translatesAutoresizingMaskIntoConstraints = false
        row.addArrangedSubview(rightSpacer)
        
        // 스페이서 크기 설정 (작게)
        leftSpacer.widthAnchor.constraint(equalToConstant: 18).isActive = true
        rightSpacer.widthAnchor.constraint(equalTo: leftSpacer.widthAnchor).isActive = true
        
        return row
    }
    
    private func createThirdRow(with layout: KeyboardLayout) -> UIStackView {
        let row = createRowStackView()
        
        // Shift 키 (iOS 표준 크기)
        let shiftButton = createSpecialButton(title: nil, systemImage: "shift", width: 44)
        shiftButton.tag = 999
        shiftButton.addTarget(self, action: #selector(shiftTapped), for: .touchUpInside)
        row.addArrangedSubview(shiftButton)
        
        for key in layout.thirdRowKeys {
            let button = createKeyButton(key: key)
            row.addArrangedSubview(button)
        }
        
        // Delete 키 (iOS 표준 크기)
        let deleteButton = createSpecialButton(title: nil, systemImage: "delete.left", width: 44)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        row.addArrangedSubview(deleteButton)
        
        return row
    }
    
    private func createFourthRow(with layout: KeyboardLayout) -> UIStackView {
        let row = createRowStackView()
        row.distribution = .fill
        
        // 언어 전환 버튼 (iOS 표준 크기)
        let languageButtonWidth: CGFloat = layout.languageSwitchTitle == "ABC" ? 52 : 42
        let languageButton = createSpecialButton(title: layout.languageSwitchTitle, systemImage: nil, width: languageButtonWidth)
        languageButton.tag = 1000
        languageButton.addTarget(self, action: #selector(languageSwitchTapped), for: .touchUpInside)
        row.addArrangedSubview(languageButton)
        
        // 숫자 키 버튼 (iOS 표준)
        let numberButton = createSpecialButton(title: "123", systemImage: nil, width: 42)
        numberButton.tag = 1003
        // TODO: 숫자 키보드 전환 기능 추가 시 활성화
        row.addArrangedSubview(numberButton)
        
        // 스페이스 버튼 (iOS 표준 스타일)
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
        spaceButton.tag = 1001
        spaceButton.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)
        row.addArrangedSubview(spaceButton)
        
        // Return 버튼 (iOS 표준 크기)
        let returnButton = createSpecialButton(title: "return", systemImage: nil, width: 88)
        returnButton.tag = 1002
        returnButton.addTarget(self, action: #selector(returnTapped), for: .touchUpInside)
        row.addArrangedSubview(returnButton)
        
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
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 23, weight: .regular)  // iOS 표준 폰트 크기
        button.backgroundColor = .white
        button.layer.cornerRadius = 5  // iOS 표준 둥근 모서리
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowRadius = 0
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        if key != "space" {
            button.heightAnchor.constraint(equalToConstant: 42).isActive = true  // iOS 표준 키 높이
        }
        button.tag = key.unicodeScalars.first?.value.hashValue ?? 0
        button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func createSpecialButton(title: String?, systemImage: String?, width: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        
        if let title = title {
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)  // iOS 표준 특수키 폰트
        } else if let imageName = systemImage {
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)  // iOS 표준 아이콘 크기
            button.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        }
        
        button.setTitleColor(.label, for: .normal)
        button.tintColor = .label
        button.backgroundColor = UIColor.systemGray2  // iOS 특수키 색상
        button.layer.cornerRadius = 5  // iOS 표준 둥근 모서리
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowRadius = 0
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.heightAnchor.constraint(equalToConstant: 42).isActive = true
        button.widthAnchor.constraint(equalToConstant: width).isActive = true
        return button
    }
    
    // MARK: - Actions
    
    @objc private func translateButtonTapped() {
        guard let targetLanguage = selectedLanguage else {
            print("⚠️ [KeyboardView] 번역 언어가 선택되지 않음")
            return
        }
        delegate?.keyboardView(self, didRequestTranslationTo: targetLanguage)
    }
    
    @objc private func keyTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        delegate?.keyboardView(self, didTapKey: title.uppercased())
    }
    
    @objc private func shiftTapped() {
        delegate?.keyboardViewDidTapShift(self)
    }
    
    @objc private func deleteTapped() {
        delegate?.keyboardViewDidTapDelete(self)
    }
    
    @objc private func spaceTapped() {
        delegate?.keyboardViewDidTapSpace(self)
    }
    
    @objc private func returnTapped() {
        delegate?.keyboardViewDidTapReturn(self)
    }
    
    @objc private func languageSwitchTapped() {
        delegate?.keyboardViewDidTapLanguageSwitch(self)
    }
    
    // MARK: - Translation UI Feedback
    
    /// 번역 시작 시 UI 피드백 (버튼 비활성화, 로딩 표시)
    func startTranslation() {
        translateButton.isEnabled = false
        translateButton.setTitle("번역 중...", for: .normal)
        translateButton.backgroundColor = .systemGray
        languageDropdownButton.isEnabled = false
    }
    
    /// 번역 완료 시 UI 피드백 (버튼 활성화, 원래 상태로)
    func finishTranslation(success: Bool) {
        translateButton.isEnabled = true
        translateButton.setTitle("번역", for: .normal)
        translateButton.backgroundColor = .systemBlue
        languageDropdownButton.isEnabled = true
        
        if success {
            // 성공 시 잠깐 초록색으로 표시
            translateButton.backgroundColor = .systemGreen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.translateButton.backgroundColor = .systemBlue
            }
        } else {
            // 실패 시 잠깐 빨간색으로 표시
            translateButton.backgroundColor = .systemRed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.translateButton.backgroundColor = .systemBlue
            }
        }
    }
}
