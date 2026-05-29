//
//  KeyboardViewController.swift
//  KeyboardExtension
//
//  Created by 장주진 on 5/29/26.
//

import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    private var hostingController: UIHostingController<KeyboardView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardUI()
    }
    
    private func setupKeyboardUI() {
        self.view.backgroundColor = .clear
        
        let viewModel = KeyboardViewModel(textDocumentProxy: textDocumentProxy)
        let keyboardView = KeyboardView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: keyboardView)
        self.hostingController = hostingController
        
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // 텍스트 변경 전 처리
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // 텍스트 변경 후 처리
    }
}
