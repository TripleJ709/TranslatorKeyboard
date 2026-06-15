//
//  Language.swift
//  KeyboardExtension
//
//  Created by 장주진 on 6/6/26.
//

import Foundation

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

// Extension용 경량화된 Manager (Combine 제거, @MainActor 제거)
class AvailableLanguagesManager {
    var availableLanguages: [Language] = []
    var isLoading: Bool = false
    
    static let shared = AvailableLanguagesManager()
    
    private var hasFetchedFromSystem = false
    private let cacheKey = "CachedLanguages"
    
    private init() {
        if let cached = loadCachedLanguages() {
            availableLanguages = cached
        } else {
            availableLanguages = defaultLanguages()
        }
    }
    
    func fetchAvailableLanguages() async {
        guard !hasFetchedFromSystem else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let languages = await Task.detached(priority: .userInitiated) {
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
                return self.defaultLanguages()
            } else {
                return Array(uniqueLanguages).sorted { $0.displayName < $1.displayName }
            }
        }.value
        
        availableLanguages = languages
        hasFetchedFromSystem = true
        cacheLanguages(languages)
    }
    
    private func defaultLanguages() -> [Language] {
        let defaultLanguageCodes = ["en", "ko", "ja", "zh"]
        return defaultLanguageCodes.map { Language(languageCode: $0) }
    }
    
    // MARK: - Cache
    
    private func loadCachedLanguages() -> [Language]? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let codes = try? JSONDecoder().decode([String].self, from: data) else {
            return nil
        }
        return codes.map { Language(languageCode: $0) }
    }
    
    private func cacheLanguages(_ languages: [Language]) {
        let codes = languages.map { $0.languageCode }
        if let data = try? JSONEncoder().encode(codes) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }
    
    func resetCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        hasFetchedFromSystem = false
        availableLanguages = defaultLanguages()
    }
}
