//
//  OnboardingStep.swift
//  TranslatorKeyboard
//
//  Created by 장주진 on 6/18/26.
//

import Foundation
import UIKit

struct OnboardingStep {
    let imageName: String
    let isAnimated: Bool
    let title: String
    let description: String
    let note: String?
    let actionTitle: String?
    let actionURL: String?

    static let steps: [OnboardingStep] = [
        OnboardingStep(
            imageName: "onboarding_keyboard_setup",
            isAnimated: false,
            title: "키보드 활성화하기",
            description: "아래 버튼을 누른 뒤\n앱 → TranslatorKeyboard → 키보드를 탭하면\n2개의 토글이 보입니다. 모두 켜주세요.",
            note: "🔒 키보드 입력 내용은 기기 외부로 전송되지 않으며\n개발자가 접근할 수 없습니다.",
            actionTitle: "키보드 설정 열기",
            actionURL: UIApplication.openSettingsURLString
        ),
        OnboardingStep(
            imageName: "onboarding_translate_app",
            isAnimated: false,
            title: "번역 앱 설치 및 언어 설정",
            description: "번역 앱을 설치한 후\n설정 → 앱 → 번역 → 언어에서\n사용할 언어쌍을 다운로드해 주세요.",
            note: "⚡ 언어쌍을 미리 받아두면\n번역 시 네트워크 없이도 즉시 동작합니다.",
            actionTitle: "번역 앱 다운로드",
            actionURL: "https://apps.apple.com/kr/app/translate/id1514844618"
        ),
        OnboardingStep(
            imageName: "onboarding_how_to_use",
            isAnimated: true,
            title: "번역하는 방법",
            description: "번역할 텍스트를 선택한 후\n키보드 상단의 번역 버튼을 탭하면\n선택한 텍스트가 바로 번역됩니다.",
            note: nil,
            actionTitle: nil,
            actionURL: nil
        )
    ]
}
