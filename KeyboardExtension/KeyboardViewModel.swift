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
    // 키보드 입력 전달 속성
    private let textDocumentProxy: UITextDocumentProxy
    
    // 한글 조합 엔진
    private var hangulAutomata = HangulAutomata()
    
    // Buffer 동기화용
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
    
    /// 문자키 입력 처리
    func handleKeyTap(_ key: String) {
        // 한글 모드일 때
        if currentKeyboardType == .korean {
            hangulAutomata.hangulAutomata(key: key)
            syncBufferToScreen()
            return
        }
        
        // 영문 모드일 때
        let text = (isUppercase || isShiftEnabled) ? key.uppercased() : key.lowercased()
        textDocumentProxy.insertText(text)
        
        // Shift 한 번만 적용되도록
        if isShiftEnabled && !isUppercase {
            isShiftEnabled = false
        }
    }
    
    /// HangulAutomata의 buffer를 화면에 동기화
    private func syncBufferToScreen() {
        let currentBuffer = hangulAutomata.buffer
        let previousCount = previousBuffer.count
        let currentCount = currentBuffer.count
        
        // 전체 비교 - 변경된 부분 찾기
        var deleteCount = 0
        var insertTexts: [String] = []
        
        // 1. 공통 부분 찾기 (앞에서부터 같은 글자 개수)
        var commonCount = 0
        for i in 0..<min(previousCount, currentCount) {
            if previousBuffer[i] == currentBuffer[i] {
                commonCount += 1
            } else {
                break
            }
        }
        
        // 2. 삭제할 글자 수 계산
        deleteCount = previousCount - commonCount
        
        // 3. 추가할 글자들
        if currentCount > commonCount {
            insertTexts = Array(currentBuffer[commonCount..<currentCount])
        }
        
        // 4. 화면 업데이트
        // 삭제
        for _ in 0..<deleteCount {
            textDocumentProxy.deleteBackward()
        }
        
        // 추가
        for text in insertTexts {
            textDocumentProxy.insertText(text)
        }
        
        // 5. previousBuffer 업데이트
        previousBuffer = currentBuffer
    }
    
    // shift키
    func handleShiftTap() {
        // 한글 모드에서는 Shift 동작이 다름
        if currentKeyboardType == .korean {
            // 한글: Shift는 쌍자음 입력용
            isShiftEnabled.toggle()
            return
        }
        
        // 영문 모드: 기존 로직 유지
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
        // 한글 모드일 때
        if currentKeyboardType == .korean {
            hangulAutomata.deleteBuffer()
            syncBufferToScreen()
            return
        }
        
        // 영문 모드일 때
        textDocumentProxy.deleteBackward()
    }
    
    // 스페이스키
    func handleSpaceTap() {
        // 한글 조합 완전 초기화
        hangulAutomata = HangulAutomata()
        previousBuffer = []
        textDocumentProxy.insertText(" ")
    }
    
    // 엔터키
    func handleReturnTap() {
        // 한글 조합 완전 초기화
        hangulAutomata = HangulAutomata()
        previousBuffer = []
        textDocumentProxy.insertText("\n")
    }
    
    // MARK: - Keyboard Type Switch
    
    /// 키보드 타입 전환 (영문 ↔ 한글)
    func toggleKeyboardType() {
        // 한글 조합 완전 초기화
        hangulAutomata = HangulAutomata()
        previousBuffer = []
        
        // Shift/CapsLock 상태 초기화 (매우 중요!)
        isShiftEnabled = false
        isUppercase = false
        lastShiftTapTime = nil
        
        currentKeyboardType = (currentKeyboardType == .english) ? .korean : .english
    }
}
