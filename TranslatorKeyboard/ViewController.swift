//
//  ViewController.swift
//  TranslatorKeyboard
//
//  Created by 장주진 on 5/27/26.
//

import UIKit

class ViewController: UIViewController {
    private let testTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "키보드 테스트용 텍스트필드"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(testTextField)
        NSLayoutConstraint.activate([
            testTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            testTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            testTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            testTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

