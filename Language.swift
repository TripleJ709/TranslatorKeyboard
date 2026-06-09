//
//  Language.swift
//  KeyboardExtension
//
//  Created by 장주진 on 6/6/26.
//

import Foundation
import Combine

struct Language: Identifiable, Hashable {
    let id: String
    let locale: Locale
    
    var displayName: String {
        let currentLocale = Locale.current
        return currentLocale.localizedString(forLanguageCode: locale.language.languageCode?.identifier ?? id) ?? id
    }
    
    var shortCode: String {
        (locale.language.languageCode?.identifier ?? id).uppercased().prefix(2).description
    }
    
    var languageCode: String {
        locale.language.languageCode?.identifier ?? id
    }
    
    init(locale: Locale) {
        self.locale = locale
        self.id = locale.identifier
    }
    
    init(languageCode: String) {
        self.locale = Locale(identifier: languageCode)
        self.id = languageCode
    }
}

@MainActor
class AvailableLanguagesManager: ObservableObject {
    @Published var availableLanguages: [Language] = []
    @Published var isLoading: Bool = false
    
    static let shared = AvailableLanguagesManager()
    
    private init() {
        availableLanguages = defaultLanguages()
    }
    
    func fetchAvailableLanguages() async {
        isLoading = true
        defer { isLoading = false }
        
        let preferredLanguages = Locale.preferredLanguages
        var uniqueLanguages: Set<Language> = []
        
        for languageIdentifier in preferredLanguages {
            let locale = Locale(identifier: languageIdentifier)
            if let languageCode = locale.language.languageCode?.identifier {
                let language = Language(languageCode: languageCode)
                uniqueLanguages.insert(language)
            }
        }
        
        if uniqueLanguages.isEmpty {
            availableLanguages = defaultLanguages()
        } else {
            availableLanguages = Array(uniqueLanguages).sorted { $0.displayName < $1.displayName }
        }
    }
    
    private func defaultLanguages() -> [Language] {
        let defaultLanguageCodes = ["en", "ko", "ja", "zh"]
        return defaultLanguageCodes.map { Language(languageCode: $0) }
    }
}
