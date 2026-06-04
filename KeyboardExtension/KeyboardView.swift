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
}

final class KeyboardView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: KeyboardViewDelegate?
    
    private let toolbarView = UIView()
    private let toolbarLabel = UILabel()
    private let keyboardStackView = UIStackView()
    
    private(set) var currentKeyboardType: KeyboardType = .english
    
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
                // 특수 버튼들 제외 (Shift, Language, Space, Return)
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
    
    /// 한글 쌍자음 표시 업데이트
    func updateKoreanDoubleConsonant(isShift: Bool) {
        let doubleConsonantMap: [String: String] = [
            "ㅂ": "ㅃ", "ㅈ": "ㅉ", "ㄷ": "ㄸ",
            "ㄱ": "ㄲ", "ㅅ": "ㅆ"
        ]
        
        for subview in keyboardStackView.arrangedSubviews {
            guard let rowStack = subview as? UIStackView else { continue }
            for button in rowStack.arrangedSubviews.compactMap({ $0 as? UIButton }) {
                // 특수 버튼 제외
                if button.tag != 999 && button.tag != 1000 && 
                   button.tag != 1001 && button.tag != 1002,
                   let title = button.title(for: .normal) {
                    
                    if isShift {
                        // Shift 눌림: 쌍자음으로 변환
                        if let doubled = doubleConsonantMap[title] {
                            button.setTitle(doubled, for: .normal)
                        }
                    } else {
                        // Shift 해제: 원래대로 복원
                        // 역방향 맵 확인
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
        
        setupToolbar()
        setupKeyboardLayout()
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
            toolbarView.topAnchor.constraint(equalTo: topAnchor),
            toolbarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 24),
            
            toolbarLabel.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 8),
            toolbarLabel.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor)
        ])
    }
    
    private func setupKeyboardLayout() {
        keyboardStackView.axis = .vertical
        keyboardStackView.spacing = 11
        keyboardStackView.distribution = .fillEqually
        keyboardStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(keyboardStackView)
        
        NSLayoutConstraint.activate([
            keyboardStackView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor, constant: 8),
            keyboardStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            keyboardStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            keyboardStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
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
        let row = createRowStackView()
        
        let leftSpacer = UIView()
        leftSpacer.widthAnchor.constraint(equalToConstant: 15).isActive = true
        row.addArrangedSubview(leftSpacer)
        
        for key in layout.secondRowKeys {
            let button = createKeyButton(key: key)
            row.addArrangedSubview(button)
        }
        
        let rightSpacer = UIView()
        rightSpacer.widthAnchor.constraint(equalToConstant: 15).isActive = true
        row.addArrangedSubview(rightSpacer)
        
        return row
    }
    
    private func createThirdRow(with layout: KeyboardLayout) -> UIStackView {
        let row = createRowStackView()
        
        // Shift 키
        let shiftButton = createSpecialButton(title: nil, systemImage: "shift", width: 42)
        shiftButton.tag = 999
        shiftButton.addTarget(self, action: #selector(shiftTapped), for: .touchUpInside)
        row.addArrangedSubview(shiftButton)
        
        for key in layout.thirdRowKeys {
            let button = createKeyButton(key: key)
            row.addArrangedSubview(button)
        }
        
        // Delete 키
        let deleteButton = createSpecialButton(title: nil, systemImage: "delete.left", width: 42)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        row.addArrangedSubview(deleteButton)
        
        return row
    }
    
    private func createFourthRow(with layout: KeyboardLayout) -> UIStackView {
        let row = createRowStackView()
        row.distribution = .fill
        
        let languageButtonWidth: CGFloat = layout.languageSwitchTitle == "ABC" ? 60 : 45
        let languageButton = createSpecialButton(title: layout.languageSwitchTitle, systemImage: nil, width: languageButtonWidth)
        languageButton.tag = 1000  // 언어 전환 버튼 - Shift 제외
        languageButton.addTarget(self, action: #selector(languageSwitchTapped), for: .touchUpInside)
        row.addArrangedSubview(languageButton)
        
        let spaceButton = createKeyButton(key: "space")
        spaceButton.tag = 1001  // Space 버튼 - Shift 제외
        spaceButton.backgroundColor = .white
        spaceButton.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)
        row.addArrangedSubview(spaceButton)
        
        let returnButton = createSpecialButton(title: "return", systemImage: nil, width: 85)
        returnButton.tag = 1002  // Return 버튼 - Shift 제외
        returnButton.addTarget(self, action: #selector(returnTapped), for: .touchUpInside)
        row.addArrangedSubview(returnButton)
        
        return row
    }
    
    // MARK: - Button Factory Methods
    
    private func createRowStackView() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5
        stack.distribution = .fillEqually
        return stack
    }
    
    private func createKeyButton(key: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(key.lowercased(), for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 26, weight: .regular)
        button.backgroundColor = .white
        button.layer.cornerRadius = 6
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 1
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        if key != "space" {
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        button.tag = key.unicodeScalars.first?.value.hashValue ?? 0
        button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func createSpecialButton(title: String?, systemImage: String?, width: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        
        if let title = title {
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        } else if let imageName = systemImage {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            button.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        }
        
        button.setTitleColor(.label, for: .normal)
        button.tintColor = .label
        button.backgroundColor = UIColor.systemGray3
        button.layer.cornerRadius = 6
        button.heightAnchor.constraint(equalToConstant: 42).isActive = true
        button.widthAnchor.constraint(equalToConstant: width).isActive = true
        return button
    }
    
    // MARK: - Actions
    
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
}
