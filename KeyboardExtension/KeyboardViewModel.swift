//
//  KeyboardViewModel.swift
//  KeyboardExtension
//
//  Created by 장주진 on 5/29/26.
//

import UIKit
import Combine

final class KeyboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentText: String = ""
    @Published var isUppercase: Bool = false
    @Published var isShiftEnabled: Bool = false
    
    // MARK: - Dependencies
    // 키보드 입력 전달 속성
    private let textDocumentProxy: UITextDocumentProxy
    
    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Double Tap Detection
    private var lastShiftTapTime: Date?
    private let doubleTapThreshold: TimeInterval = 0.3
    
    // MARK: - Initialization
    init(textDocumentProxy: UITextDocumentProxy) {
        self.textDocumentProxy = textDocumentProxy
    }
    
    // MARK: - Input Actions
    // 문자키
    func handleKeyTap(_ key: String) {
        let text = (isUppercase || isShiftEnabled) ? key.uppercased() : key.lowercased()
        textDocumentProxy.insertText(text)
        if isShiftEnabled && !isUppercase {
            isShiftEnabled = false
        }
    }
    
    // shift키
    func handleShiftTap() {
        let now = Date()

        if let lastTap = lastShiftTapTime,
           now.timeIntervalSince(lastTap) < doubleTapThreshold {
            // 무조건 Caps Lock 활성화 (이미 Caps Lock이어도 유지)
            isUppercase = true
            isShiftEnabled = false
            lastShiftTapTime = nil
            return
        }
        
        if isUppercase {
            isUppercase = false
            isShiftEnabled = false
            lastShiftTapTime = now
        } else if isShiftEnabled { // Shift → 소문자
            isShiftEnabled = false
            lastShiftTapTime = now
        } else {                   // 소문자 → Shift
            isShiftEnabled = true
            lastShiftTapTime = now
        }
    }
    
    // 백스페이스키
    func handleDeleteTap() {
        textDocumentProxy.deleteBackward()
    }
    
    // 스페이스키
    func handleSpaceTap() {
        textDocumentProxy.insertText(" ")
    }
    
    // 엔터키
    func handleReturnTap() {
        textDocumentProxy.insertText("\n")
    }
}
