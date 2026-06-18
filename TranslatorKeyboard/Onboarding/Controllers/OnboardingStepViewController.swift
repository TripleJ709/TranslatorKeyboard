//
//  OnboardingStepViewController.swift
//  TranslatorKeyboard
//
//  Created by 장주진 on 6/18/26.
//

import UIKit

final class OnboardingStepViewController: UIViewController {

    let stepIndex: Int
    private let step: OnboardingStep
    private let pageView = OnboardingPageView()

    init(step: OnboardingStep, index: Int) {
        self.step = step
        self.stepIndex = index
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = pageView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pageView.configure(with: step)
    }
}
