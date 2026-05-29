//
//  KeyboardView.swift
//  KeyboardExtension
//
//  Created by 장주진 on 5/29/26.
//

import SwiftUI

struct KeyboardView: View {
    
    @ObservedObject var viewModel: KeyboardViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 툴바 영역 (번역 기능 등 추후 추가)
            toolbarArea
            keyboardLayout
            
            Spacer(minLength: 0)
        }
        .background(Color(UIColor.systemGray5))
    }
    
    // MARK: - Toolbar Area
    private var toolbarArea: some View {
        HStack {
            Text("TranslatorKeyboard")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(UIColor.systemGray6))
    }
    
    // MARK: - Keyboard Layout
    private var keyboardLayout: some View {
        VStack(spacing: 8) {
            firstRow
            secondRow
            thirdRow
            fourthRow
        }
        .padding(.horizontal, 3)
        .padding(.vertical, 8)
    }
    
    // MARK: - Keyboard Rows
    private var firstRow: some View {
        HStack(spacing: 6) {
            ForEach(["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], id: \.self) { key in
                KeyButton(key: key, viewModel: viewModel)
            }
        }
    }
    
    private var secondRow: some View {
        HStack(spacing: 6) {
            Spacer().frame(width: 15) // A 키 시작 위치 조정
            ForEach(["A", "S", "D", "F", "G", "H", "J", "K", "L"], id: \.self) { key in
                KeyButton(key: key, viewModel: viewModel)
            }
            Spacer().frame(width: 15)
        }
    }
    
    private var thirdRow: some View {
        HStack(spacing: 6) {
            // Shift 키
            Button(action: {
                viewModel.handleShiftTap()
            }) {
                Image(systemName: viewModel.isUppercase ? "arrow.up.circle.fill" : viewModel.isShiftEnabled ? "shift.fill" : "shift")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 42, height: 42)
            .background(Color(UIColor.systemGray4))
            .foregroundColor(.primary)
            .cornerRadius(5)
            
            ForEach(["Z", "X", "C", "V", "B", "N", "M"], id: \.self) { key in
                KeyButton(key: key, viewModel: viewModel)
            }
            
            // Delete 키
            Button(action: {
                viewModel.handleDeleteTap()
            }) {
                Image(systemName: "delete.left")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 42, height: 42)
            .background(Color(UIColor.systemGray4))
            .foregroundColor(.primary)
            .cornerRadius(5)
        }
    }
    
    private var fourthRow: some View {
        HStack(spacing: 6) {
            // 숫자/기호 전환 키 (추후 구현)
            Button(action: {}) {
                Text("123")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 70, height: 42)
            .background(Color(UIColor.systemGray4))
            .foregroundColor(.primary)
            .cornerRadius(5)
            
            // Space 키
            Button(action: {
                viewModel.handleSpaceTap()
            }) {
                Text("space")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(Color.white)
            .foregroundColor(.primary)
            .cornerRadius(5)
            
            // Return 키
            Button(action: {
                viewModel.handleReturnTap()
            }) {
                Text("return")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 70, height: 42)
            .background(Color(UIColor.systemGray4))
            .foregroundColor(.primary)
            .cornerRadius(5)
        }
    }
}

// MARK: - KeyButton Component

/// 개별 문자 키 버튼 컴포넌트
struct KeyButton: View {
    let key: String
    @ObservedObject var viewModel: KeyboardViewModel
    
    var body: some View {
        Button(action: {
            viewModel.handleKeyTap(key)
        }) {
            Text(viewModel.isUppercase || viewModel.isShiftEnabled ? key.uppercased() : key.lowercased())
                .font(.system(size: 20))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 42)
        .background(Color.white)
        .foregroundColor(.primary)
        .cornerRadius(5)
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Preview

#Preview {
    KeyboardView(viewModel: KeyboardViewModel(textDocumentProxy: PreviewTextDocumentProxy()))
        .frame(height: 250)
}

// MARK: - Preview Helper

/// Preview 전용 Mock 텍스트 프록시
class PreviewTextDocumentProxy: NSObject, UITextDocumentProxy {
    var documentContextBeforeInput: String?
    var documentContextAfterInput: String?
    var selectedText: String?
    var documentInputMode: UITextInputMode?
    var documentIdentifier: UUID = UUID()
    
    var hasText: Bool { return false }
    
    func insertText(_ text: String) { 
        print("Insert: \(text)") 
    }
    
    func deleteBackward() { 
        print("Delete") 
    }
    
    func adjustTextPosition(byCharacterOffset offset: Int) {}
    func setMarkedText(_ markedText: String, selectedRange: NSRange) {}
    func unmarkText() {}
}
