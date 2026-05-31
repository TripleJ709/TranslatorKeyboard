//
//  KeyboardViewController.swift
//  KeyboardExtension
//
//  Created by 장주진 on 5/29/26.
//

import UIKit

/// 커스텀 키보드의 메인 뷰 컨트롤러
/// UIInputViewController를 상속하여 iOS 시스템 키보드 인터페이스 제공
class KeyboardViewController: UIInputViewController {
    
    private var keyboardView: KeyboardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardView()
    }
    
    private func setupKeyboardView() {
        // ViewModel 생성
        let viewModel = KeyboardViewModel(textDocumentProxy: textDocumentProxy)
        
        // KeyboardView 생성 및 추가
        keyboardView = KeyboardView(viewModel: viewModel)
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardView)
        
        // AutoLayout 설정
        NSLayoutConstraint.activate([
            keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
