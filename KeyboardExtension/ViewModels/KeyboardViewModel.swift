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
    @Published var currentKeyboardType: KeyboardType = .english
    
    // MARK: - Dependencies
    private let textDocumentProxy: UITextDocumentProxy
    private var hangulAutomata = HangulAutomata()
    private var previousBuffer: [String] = []
    
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
    
    func handleKeyTap(_ key: String) {
        if currentKeyboardType == .korean {
            hangulAutomata.hangulAutomata(key: key)
            syncBufferToScreen()
            
            if isShiftEnabled {
                isShiftEnabled = false
            }
            return
        }
    
        let text = (isUppercase || isShiftEnabled) ? key.uppercased() : key.lowercased()
        textDocumentProxy.insertText(text)
        
        if isShiftEnabled && !isUppercase {
            isShiftEnabled = false
        }
    }
    
    private func syncBufferToScreen() {
        let currentBuffer = hangulAutomata.buffer
        let previousCount = previousBuffer.count
        let currentCount = currentBuffer.count
        
        var deleteCount = 0
        var insertTexts: [String] = []
        
        var commonCount = 0
        for i in 0..<min(previousCount, currentCount) {
            if previousBuffer[i] == currentBuffer[i] {
                commonCount += 1
            } else {
                break
            }
        }
        
        deleteCount = previousCount - commonCount
        
        if currentCount > commonCount {
            insertTexts = Array(currentBuffer[commonCount..<currentCount])
        }
        
        for _ in 0..<deleteCount {
            textDocumentProxy.deleteBackward()
        }
        
        for text in insertTexts {
            textDocumentProxy.insertText(text)
        }
        
        previousBuffer = currentBuffer
    }
    
    // shift키
    func handleShiftTap() {
        if currentKeyboardType == .korean {
            isShiftEnabled.toggle()
            return
        }
        
        let now = Date()

        if let lastTap = lastShiftTapTime,
           now.timeIntervalSince(lastTap) < doubleTapThreshold {
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
        if currentKeyboardType == .korean {
            if hangulAutomata.inpStack.isEmpty && hangulAutomata.buffer.isEmpty {
                textDocumentProxy.deleteBackward()
                return
            }
            
            hangulAutomata.deleteBuffer()
            syncBufferToScreen()
            return
        }
        
        textDocumentProxy.deleteBackward()
    }
    
    // 스페이스키
    func handleSpaceTap() {
        hangulAutomata = HangulAutomata()
        previousBuffer = []
        textDocumentProxy.insertText(" ")
    }
    
    // 엔터키
    func handleReturnTap() {
        hangulAutomata = HangulAutomata()
        previousBuffer = []
        textDocumentProxy.insertText("\n")
    }
    
    func resetHangulState() {
        hangulAutomata = HangulAutomata()
        previousBuffer = []
    }

    // MARK: - Keyboard Type Switch

    /// 키보드 타입 전환 (영문 ↔ 한글)
    func toggleKeyboardType() {
        hangulAutomata = HangulAutomata()
        previousBuffer = []
        
        isShiftEnabled = false
        isUppercase = false
        lastShiftTapTime = nil
        
        currentKeyboardType = (currentKeyboardType == .english) ? .korean : .english
    }
}
