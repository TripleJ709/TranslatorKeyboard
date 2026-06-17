//
//  MainView.swift
//  TranslatorKeyboard
//
//  Created by 장주진 on 5/27/26.
//

import UIKit

final class MainView: UIView {

    // MARK: - Header

    let appIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "keyboard")
        iv.tintColor = .systemBlue
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "TranslatorKeyboard"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let appDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "키보드에서 바로 번역하세요"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Test Area

    let testSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "키보드 테스트"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let testTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "여기를 탭해서 키보드를 테스트해보세요"
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let testFieldContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Onboarding

    let showGuideButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "사용방법 다시보기"
        config.image = UIImage(systemName: "questionmark.circle")
        config.imagePadding = 6
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Support

    let supportButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "개발자에게 커피 사주기"
        config.image = UIImage(systemName: "cup.and.saucer.fill")
        config.imagePadding = 8
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(red: 0.4, green: 0.24, blue: 0.07, alpha: 1)
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .systemBackground
        testFieldContainer.addSubview(testTextField)
        addSubview(appIconImageView)
        addSubview(appNameLabel)
        addSubview(appDescriptionLabel)
        addSubview(testSectionLabel)
        addSubview(testFieldContainer)
        addSubview(showGuideButton)
        addSubview(supportButton)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            appIconImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 48),
            appIconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            appIconImageView.widthAnchor.constraint(equalToConstant: 72),
            appIconImageView.heightAnchor.constraint(equalToConstant: 72),

            appNameLabel.topAnchor.constraint(equalTo: appIconImageView.bottomAnchor, constant: 16),
            appNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            appDescriptionLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 6),
            appDescriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            testSectionLabel.topAnchor.constraint(equalTo: appDescriptionLabel.bottomAnchor, constant: 48),
            testSectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),

            testFieldContainer.topAnchor.constraint(equalTo: testSectionLabel.bottomAnchor, constant: 8),
            testFieldContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            testFieldContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            testTextField.topAnchor.constraint(equalTo: testFieldContainer.topAnchor, constant: 14),
            testTextField.bottomAnchor.constraint(equalTo: testFieldContainer.bottomAnchor, constant: -14),
            testTextField.leadingAnchor.constraint(equalTo: testFieldContainer.leadingAnchor, constant: 16),
            testTextField.trailingAnchor.constraint(equalTo: testFieldContainer.trailingAnchor, constant: -16),

            showGuideButton.bottomAnchor.constraint(equalTo: supportButton.topAnchor, constant: -20),
            showGuideButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            showGuideButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            showGuideButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            supportButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12),
            supportButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            supportButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            supportButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }
}
