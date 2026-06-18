//
//  OnboardingPageView.swift
//  TranslatorKeyboard
//
//  Created by 장주진 on 6/18/26.
//

import UIKit
import ImageIO

final class OnboardingPageView: UIView {

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .clear
        iv.layer.cornerRadius = 16
        iv.clipsToBounds = true
        iv.tintColor = .systemGray3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let actionButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isHidden = true
        return btn
    }()

    private let noteLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    private var actionURL: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with step: OnboardingStep) {
        titleLabel.text = step.title
        descriptionLabel.text = step.description

        imageView.stopAnimating()
        if step.isAnimated {
            imageView.loadGIF(named: step.imageName)
        } else {
            imageView.animationImages = nil
            imageView.image = UIImage(named: step.imageName) ?? UIImage(systemName: "photo")
        }

        if let title = step.actionTitle, let url = step.actionURL {
            var config = actionButton.configuration
            config?.title = title
            actionButton.configuration = config
            actionButton.isHidden = false
            actionURL = url
        } else {
            actionButton.isHidden = true
            actionURL = nil
        }

        if let note = step.note {
            noteLabel.text = note
            noteLabel.isHidden = false
        } else {
            noteLabel.isHidden = true
        }
    }

    @objc private func actionTapped() {
        guard let urlString = actionURL, let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    private func setupUI() {
        backgroundColor = .systemBackground
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(actionButton)
        addSubview(noteLabel)

        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.40),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            actionButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),

            noteLabel.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 14),
            noteLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            noteLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
        ])
    }
}

// MARK: - GIF Support

private extension UIImageView {
    func loadGIF(named name: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let path = Bundle.main.path(forResource: name, ofType: "gif"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                  let source = CGImageSourceCreateWithData(data as CFData, nil) else {
                DispatchQueue.main.async { self?.image = UIImage(named: name) ?? UIImage(systemName: "photo") }
                return
            }

            let count = CGImageSourceGetCount(source)
            var frames: [UIImage] = []
            var totalDuration: Double = 0

            for i in 0..<count {
                guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }
                frames.append(UIImage(cgImage: cgImage))
                totalDuration += Self.extractFrameDelay(source: source, index: i)
            }

            DispatchQueue.main.async { [weak self] in
                guard !frames.isEmpty else {
                    self?.image = UIImage(systemName: "photo")
                    return
                }
                self?.animationImages = frames
                self?.animationDuration = totalDuration
                self?.animationRepeatCount = 0
                self?.startAnimating()
            }
        }
    }

    static func extractFrameDelay(source: CGImageSource, index: Int) -> Double {
        let defaultDelay = 0.1
        guard let props = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any],
              let gifProps = props[kCGImagePropertyGIFDictionary as String] as? [String: Any] else {
            return defaultDelay
        }
        let delay = gifProps[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double
                 ?? gifProps[kCGImagePropertyGIFDelayTime as String] as? Double
                 ?? defaultDelay
        return delay < 0.011 ? defaultDelay : delay
    }

}
