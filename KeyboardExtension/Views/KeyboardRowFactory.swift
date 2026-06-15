//
//  KeyboardRowFactory.swift
//  KeyboardExtension
//
//  Created by 장주진 on 6/15/26.
//

import UIKit

final class KeyboardRowFactory {
    
    // MARK: - Properties
    
    weak var delegate: KeyboardRowActionDelegate?
    
    // MARK: - Row Creation
    
    func createFirstRow(with layout: KeyboardLayout) -> UIStackView {
        let row = createRowStackView()
        layout.firstRowKeys.forEach { row.addArrangedSubview(createKeyButton(key: $0)) }
        return row
    }
    
    func createSecondRow(with layout: KeyboardLayout) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 6
        row.distribution = .fill
        row.backgroundColor = .clear
        
        let leftSpacer = UIView()
        leftSpacer.backgroundColor = .clear
        let rightSpacer = UIView()
        rightSpacer.backgroundColor = .clear
        let keysStack = UIStackView()
        keysStack.axis = .horizontal
        keysStack.spacing = 6
        keysStack.distribution = .fillEqually
        keysStack.backgroundColor = .clear
        
        layout.secondRowKeys.forEach { keysStack.addArrangedSubview(createKeyButton(key: $0)) }
        
        row.addArrangedSubview(leftSpacer)
        row.addArrangedSubview(keysStack)
        row.addArrangedSubview(rightSpacer)
        
        let leftWidthConstraint = leftSpacer.widthAnchor.constraint(equalToConstant: 11)
        leftWidthConstraint.priority = UILayoutPriority(999)
        leftWidthConstraint.isActive = true
        
        let rightWidthConstraint = rightSpacer.widthAnchor.constraint(equalTo: leftSpacer.widthAnchor)
        rightWidthConstraint.priority = UILayoutPriority(999)
        rightWidthConstraint.isActive = true
        
        return row
    }
    
    func createThirdRow(with layout: KeyboardLayout) -> UIStackView {
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
    
    func createFourthRow(with layout: KeyboardLayout) -> UIStackView {
        let row = createRowStackView()
        row.distribution = .fill
        
        let languageWidth: CGFloat = layout.languageSwitchTitle == "ABC" ? 52 : 42
        let languageButton = createSpecialButton(title: layout.languageSwitchTitle, systemImage: nil, width: languageWidth)
        languageButton.tag = ButtonTag.languageSwitch.rawValue
        languageButton.addTarget(self, action: #selector(languageSwitchTapped), for: .touchUpInside)
        
        let numberButton = createSpecialButton(title: "123", systemImage: nil, width: 42)
        numberButton.tag = ButtonTag.number.rawValue
        
        let spaceButton = createSpaceButton()
        let returnButton = createReturnButton()
        
        [languageButton, numberButton, spaceButton, returnButton].forEach { row.addArrangedSubview($0) }
        
        return row
    }
    
    // MARK: - Button Factory Methods
    
    private func createRowStackView() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fillEqually
        stack.backgroundColor = .clear
        return stack
    }
    
    private func createKeyButton(key: String) -> KeyboardButton {
        let button = KeyboardButton(type: .system)
        button.setTitle(key.lowercased(), for: .normal)
        button.applyStyle(.key)
        button.tag = key.unicodeScalars.first?.value.hashValue ?? 0
        button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func createSpecialButton(title: String?, systemImage: String?, width: CGFloat) -> KeyboardButton {
        let button = KeyboardButton(type: .system)
        if let title = title {
            button.setTitle(title, for: .normal)
        } else if let imageName = systemImage {
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            button.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        }
        button.applyStyle(.special, width: width)
        return button
    }
    
    private func createSpaceButton() -> KeyboardButton {
        let button = KeyboardButton(type: .system)
        button.setTitle("space", for: .normal)
        button.applyStyle(.space)
        button.tag = ButtonTag.space.rawValue
        button.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)
        return button
    }
    
    private func createReturnButton() -> KeyboardButton {
        let button = createSpecialButton(title: "return", systemImage: nil, width: 88)
        button.tag = ButtonTag.return.rawValue
        button.addTarget(self, action: #selector(returnTapped), for: .touchUpInside)
        return button
    }
    
    // MARK: - Actions
    
    @objc private func keyTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        delegate?.keyboardRowFactory(self, didTapKey: title.uppercased())
    }
    
    @objc private func shiftTapped() {
        delegate?.keyboardRowFactoryDidTapShift(self)
    }
    
    @objc private func deleteTapped() {
        delegate?.keyboardRowFactoryDidTapDelete(self)
    }
    
    @objc private func spaceTapped() {
        delegate?.keyboardRowFactoryDidTapSpace(self)
    }
    
    @objc private func returnTapped() {
        delegate?.keyboardRowFactoryDidTapReturn(self)
    }
    
    @objc private func languageSwitchTapped() {
        delegate?.keyboardRowFactoryDidTapLanguageSwitch(self)
    }
}

// MARK: - Delegate Protocol

protocol KeyboardRowActionDelegate: AnyObject {
    func keyboardRowFactory(_ factory: KeyboardRowFactory, didTapKey key: String)
    func keyboardRowFactoryDidTapShift(_ factory: KeyboardRowFactory)
    func keyboardRowFactoryDidTapDelete(_ factory: KeyboardRowFactory)
    func keyboardRowFactoryDidTapSpace(_ factory: KeyboardRowFactory)
    func keyboardRowFactoryDidTapReturn(_ factory: KeyboardRowFactory)
    func keyboardRowFactoryDidTapLanguageSwitch(_ factory: KeyboardRowFactory)
}
