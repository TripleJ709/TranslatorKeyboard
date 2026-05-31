//
//  KeyboardView.swift
//  KeyboardExtension
//
//  Created by 장주진 on 5/31/26.
//

import UIKit
import Combine

final class KeyboardView: UIView {
    
    // MARK: - Properties
    
    private let viewModel: KeyboardViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // UI 컴포넌트들
    private let toolbarView = UIView()
    private let toolbarLabel = UILabel()
    private let keyboardStackView = UIStackView()
    
    // MARK: - Initialization
    
    init(viewModel: KeyboardViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray5
        
        setupToolbar()
        setupKeyboardLayout()
    }
    
    private func setupToolbar() {
        toolbarView.backgroundColor = UIColor.systemGray6
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toolbarView)
        
        toolbarLabel.text = "TranslatorKeyboard"
        toolbarLabel.font = .systemFont(ofSize: 12)
        toolbarLabel.textColor = .secondaryLabel
        toolbarLabel.translatesAutoresizingMaskIntoConstraints = false
        toolbarView.addSubview(toolbarLabel)
        
        NSLayoutConstraint.activate([
            toolbarView.topAnchor.constraint(equalTo: topAnchor),
            toolbarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 24),
            
            toolbarLabel.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 8),
            toolbarLabel.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor)
        ])
    }
    
    private func setupKeyboardLayout() {
        keyboardStackView.axis = .vertical
        keyboardStackView.spacing = 8
        keyboardStackView.distribution = .fillEqually
        keyboardStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(keyboardStackView)
        
        NSLayoutConstraint.activate([
            keyboardStackView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor, constant: 8),
            keyboardStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            keyboardStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            keyboardStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        // 4개 행 추가
        keyboardStackView.addArrangedSubview(createFirstRow())
        keyboardStackView.addArrangedSubview(createSecondRow())
        keyboardStackView.addArrangedSubview(createThirdRow())
        keyboardStackView.addArrangedSubview(createFourthRow())
    }
    
    // MARK: - Keyboard Rows
    
    private func createFirstRow() -> UIStackView {
        let row = createRowStackView()
        let keys = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
        
        for key in keys {
            let button = createKeyButton(key: key)
            row.addArrangedSubview(button)
        }
        
        return row
    }
    
    private func createSecondRow() -> UIStackView {
        let row = createRowStackView()
        
        let leftSpacer = UIView()
        leftSpacer.widthAnchor.constraint(equalToConstant: 15).isActive = true
        row.addArrangedSubview(leftSpacer)
        
        let keys = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
        for key in keys {
            let button = createKeyButton(key: key)
            row.addArrangedSubview(button)
        }
        
        let rightSpacer = UIView()
        rightSpacer.widthAnchor.constraint(equalToConstant: 15).isActive = true
        row.addArrangedSubview(rightSpacer)
        
        return row
    }
    
    private func createThirdRow() -> UIStackView {
        let row = createRowStackView()
        
        // Shift 키
        let shiftButton = createSpecialButton(title: nil, systemImage: "shift", width: 42)
        shiftButton.tag = 999 // Shift 식별용
        shiftButton.addTarget(self, action: #selector(shiftTapped), for: .touchUpInside)
        row.addArrangedSubview(shiftButton)
        
        let keys = ["Z", "X", "C", "V", "B", "N", "M"]
        for key in keys {
            let button = createKeyButton(key: key)
            row.addArrangedSubview(button)
        }
        
        // Delete 키
        let deleteButton = createSpecialButton(title: nil, systemImage: "delete.left", width: 42)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        row.addArrangedSubview(deleteButton)
        
        return row
    }
    
    private func createFourthRow() -> UIStackView {
        let row = createRowStackView()
        
        // 123 키
        let numberButton = createSpecialButton(title: "123", systemImage: nil, width: 70)
        row.addArrangedSubview(numberButton)
        
        // Space 키
        let spaceButton = createKeyButton(key: "space")
        spaceButton.backgroundColor = .white
        spaceButton.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)
        row.addArrangedSubview(spaceButton)
        
        // Return 키
        let returnButton = createSpecialButton(title: "return", systemImage: nil, width: 70)
        returnButton.addTarget(self, action: #selector(returnTapped), for: .touchUpInside)
        row.addArrangedSubview(returnButton)
        
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
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 1
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.tag = key.unicodeScalars.first?.value.hashValue ?? 0
        button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func createSpecialButton(title: String?, systemImage: String?, width: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        
        if let title = title {
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16)
        } else if let imageName = systemImage {
            let config = UIImage.SymbolConfiguration(pointSize: 16)
            button.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        }
        
        button.setTitleColor(.label, for: .normal)
        button.tintColor = .label
        button.backgroundColor = UIColor.systemGray4
        button.layer.cornerRadius = 5
        button.widthAnchor.constraint(equalToConstant: width).isActive = true
        return button
    }
    
    // MARK: - Actions
    
    @objc private func keyTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        viewModel.handleKeyTap(title.uppercased())
    }
    
    @objc private func shiftTapped() {
        viewModel.handleShiftTap()
    }
    
    @objc private func deleteTapped() {
        viewModel.handleDeleteTap()
    }
    
    @objc private func spaceTapped() {
        viewModel.handleSpaceTap()
    }
    
    @objc private func returnTapped() {
        viewModel.handleReturnTap()
    }
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        // Shift/Caps Lock 상태 변경 감지
        viewModel.$isShiftEnabled
            .combineLatest(viewModel.$isUppercase)
            .sink { [weak self] isShift, isCaps in
                self?.updateKeyboardCase(isShift: isShift, isCaps: isCaps)
                self?.updateShiftButton(isShift: isShift, isCaps: isCaps)
            }
            .store(in: &cancellables)
    }
    
    private func updateKeyboardCase(isShift: Bool, isCaps: Bool) {
        let isUppercase = isShift || isCaps
        
        // 모든 문자 키 업데이트
        for subview in keyboardStackView.arrangedSubviews {
            guard let rowStack = subview as? UIStackView else { continue }
            for button in rowStack.arrangedSubviews.compactMap({ $0 as? UIButton }) {
                if button.tag != 999, // Shift 버튼 제외
                   let title = button.title(for: .normal) {
                    button.setTitle(isUppercase ? title.uppercased() : title.lowercased(), for: .normal)
                }
            }
        }
    }
    
    private func updateShiftButton(isShift: Bool, isCaps: Bool) {
        // Shift 버튼 찾기 (tag 999)
        for subview in keyboardStackView.arrangedSubviews {
            guard let rowStack = subview as? UIStackView else { continue }
            if let shiftButton = rowStack.arrangedSubviews.compactMap({ $0 as? UIButton }).first(where: { $0.tag == 999 }) {
                let imageName = isCaps ? "arrow.up.circle.fill" : (isShift ? "shift.fill" : "shift")
                let config = UIImage.SymbolConfiguration(pointSize: 16)
                shiftButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
            }
        }
    }
}
