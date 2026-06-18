//
//  OnboardingViewController.swift
//  TranslatorKeyboard
//
//  Created by 장주진 on 6/18/26.
//

import UIKit

class OnboardingViewController: UIViewController {

    // MARK: - Properties

    private let steps = OnboardingStep.steps
    private var currentIndex = 0
    var onComplete: (() -> Void)?

    // MARK: - Subviews

    private lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        vc.dataSource = self
        vc.delegate = self
        return vc
    }()

    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = .systemBlue
        pc.pageIndicatorTintColor = .systemGray4
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    private let nextButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "다음"
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let skipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("건너뛰기", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupPageViewController()
        setupControls()

        pageControl.numberOfPages = steps.count
        pageControl.currentPage = 0

        if let first = makeStepVC(at: 0) {
            pageViewController.setViewControllers([first], direction: .forward, animated: false)
        }
    }

    // MARK: - Setup

    private func setupPageViewController() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupControls() {
        view.addSubview(skipButton)
        view.addSubview(pageControl)
        view.addSubview(nextButton)

        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -16),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
    }

    // MARK: - Helpers

    private func makeStepVC(at index: Int) -> OnboardingStepViewController? {
        guard index >= 0 && index < steps.count else { return nil }
        return OnboardingStepViewController(step: steps[index], index: index)
    }

    private func updateUI(for index: Int) {
        pageControl.currentPage = index
        var config = nextButton.configuration
        config?.title = index == steps.count - 1 ? "시작하기" : "다음"
        nextButton.configuration = config
        skipButton.isHidden = index == steps.count - 1
    }

    // MARK: - Actions

    @objc private func nextTapped() {
        if currentIndex < steps.count - 1 {
            currentIndex += 1
            if let vc = makeStepVC(at: currentIndex) {
                pageViewController.setViewControllers([vc], direction: .forward, animated: true)
                updateUI(for: currentIndex)
            }
        } else {
            complete()
        }
    }

    @objc private func skipTapped() {
        complete()
    }

    private func complete() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        onComplete?()
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let current = viewController as? OnboardingStepViewController else { return nil }
        return makeStepVC(at: current.stepIndex - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let current = viewController as? OnboardingStepViewController else { return nil }
        return makeStepVC(at: current.stepIndex + 1)
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let current = pageViewController.viewControllers?.first as? OnboardingStepViewController else { return }
        currentIndex = current.stepIndex
        updateUI(for: currentIndex)
    }
}
