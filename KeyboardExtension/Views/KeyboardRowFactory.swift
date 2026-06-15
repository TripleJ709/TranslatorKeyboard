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
    
    private func createSpaceButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("space", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowRadius = 0
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.tag = ButtonTag.space.rawValue
        button.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)
        return button
    }
    
    private func createReturnButton() -> UIButton {
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
