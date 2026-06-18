//
//  SceneDelegate.swift
//  TranslatorKeyboard
//
//  Created by 장주진 on 5/27/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        if hasSeenOnboarding {
            window?.rootViewController = MainViewController()
        } else {
            showOnboarding()
        }

        window?.makeKeyAndVisible()
    }

    private func showOnboarding() {
        let onboarding = OnboardingViewController()
        onboarding.onComplete = { [weak self] in
            self?.window?.rootViewController = MainViewController()
        }
        window?.rootViewController = onboarding
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
