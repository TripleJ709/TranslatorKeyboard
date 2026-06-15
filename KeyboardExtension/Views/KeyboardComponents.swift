//
//  KeyboardComponents.swift
//  KeyboardExtension
//
//  Created by 장주진 on 6/15/26.
//

import UIKit

// MARK: - ButtonTag

enum ButtonTag: Int {
    case shift = 999
    case languageSwitch = 1000
    case space = 1001
    case `return` = 1002
    case number = 1003
}

// MARK: - KeyboardLayout

struct KeyboardLayout {
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

// MARK: - KeyboardButtonHelper

enum KeyboardButtonHelper {
    
    static func getAllButtons(from view: UIView) -> [UIButton] {
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
}

// MARK: - UIButton+KeyboardStyle

extension UIButton {
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
